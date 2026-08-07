// Command ghost-watch drives a Ghostty face shader from herdr's agent state.
//
// Asks herdr what the focused pane is doing, and points Ghostty's custom-shader
// at a matching pre-built variant when the answer changes.
//
// Why swap paths instead of rewriting one shader file: Ghostty does not watch
// shader contents. Upstream src/cli/edit_config.zig says outright there is "no
// CLI reload command and no automatic file watching", so changing the configured
// path and reloading is the only route.
//
// Why poll instead of subscribing to events: herdr's events carry a focused pane
// id that is not the user's focus. herdr probes panes by focusing them, so
// layout.updated and pane.focused both flap between panes and across workspaces
// several times a second -- measured against herdr 0.8.0, a stream that reported
// w3K:p6 while the session's real focus sat on w3K:p1 throughout. Queried state
// has no such problem: 6198 consecutive polls of pane.layout returned the same
// answer while the event stream was flapping. Subscribing would not even save
// wakeups, since pane.updated fires ~3.6/s whether or not anything happened.
//
// Run with a state name to apply it once and exit -- the only practical way to
// eyeball face placement without driving a real Claude session:
//
//	ghost-watch idle
package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"syscall"
	"time"
)

// herdr's agent_status vocabulary is idle/working/blocked/done/unknown. It has
// no error state, so the shader's red "worry" face goes unused. "blocked" means
// the agent is sitting on a permission prompt, which is what the yellow
// question-mark face already means, so it lands there.
var statusMap = map[string]string{
	"idle":    "idle",
	"working": "working",
	"blocked": "thinking",
	"done":    "done",
}

// Every herdr integration normalises its own events down to the vocabulary
// above before reporting (opencode's plugin maps active/busy/pending/retry/
// running/streaming all onto "working"), so adding an agent is just naming it.
// `herdr integration status` lists which ones are actually installed; an agent
// without its integration reports "unknown" forever and shows no face.
var agents = map[string]bool{
	"claude":   true,
	"opencode": true,
}

const (
	off = "off"

	// herdr reports the terminal area's left edge in columns. Anything this
	// small means the sidebar is collapsed, and the face -- pinned at a fixed
	// pixel offset inside the sidebar -- would otherwise sit on terminal text.
	collapsedX = 4

	pollInterval  = 250 * time.Millisecond
	retryInterval = 2 * time.Second
	dialTimeout   = 2 * time.Second
)

var (
	socketPath = env("HERDR_SOCKET_PATH", filepath.Join(home(), ".config/herdr/herdr.sock"))
	variants   = os.Getenv("GHOST_VARIANTS")
	fragment   = env("GHOST_FRAGMENT", filepath.Join(home(), ".local/state/ghost-in-the-machine/ghostty.conf"))
	psPath     = env("GHOST_PS", "/bin/ps")

	// Swapped out by selfcheck.
	request = herdrRequest
)

func home() string {
	dir, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	return dir
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func logf(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "%s %s\n", time.Now().Format("15:04:05"), fmt.Sprintf(format, args...))
}

// herdrRequest sends one request and reads one response: herdr closes the
// connection after replying, so every call needs its own connect.
func herdrRequest(method string, params map[string]string) (json.RawMessage, error) {
	conn, err := net.DialTimeout("unix", socketPath, dialTimeout)
	if err != nil {
		return nil, err
	}
	defer conn.Close()
	if err := conn.SetDeadline(time.Now().Add(dialTimeout)); err != nil {
		return nil, err
	}
	if params == nil {
		params = map[string]string{}
	}
	body, err := json.Marshal(map[string]any{
		"id":     "ghost:" + method,
		"method": method,
		"params": params,
	})
	if err != nil {
		return nil, err
	}
	if _, err := conn.Write(append(body, '\n')); err != nil {
		return nil, err
	}
	line, err := bufio.NewReader(conn).ReadBytes('\n')
	if len(line) == 0 {
		return nil, fmt.Errorf("%s: herdr closed without replying (%v)", method, err)
	}
	var message struct {
		Result json.RawMessage `json:"result"`
		Error  json.RawMessage `json:"error"`
	}
	if err := json.Unmarshal(line, &message); err != nil {
		return nil, fmt.Errorf("%s: %w", method, err)
	}
	if len(message.Error) > 0 && string(message.Error) != "null" {
		return nil, fmt.Errorf("%s: %s", method, message.Error)
	}
	return message.Result, nil
}

// currentState asks herdr what face to show. Errors mean herdr is unreachable.
func currentState() (string, error) {
	raw, err := request("pane.layout", nil)
	if err != nil {
		return "", err
	}
	var layout struct {
		Layout struct {
			FocusedPaneID string `json:"focused_pane_id"`
			Area          *struct {
				X *float64 `json:"x"`
			} `json:"area"`
		} `json:"layout"`
	}
	if err := decode(raw, &layout); err != nil {
		return "", err
	}
	if a := layout.Layout.Area; a != nil && a.X != nil && *a.X <= collapsedX {
		return off, nil
	}
	paneID := layout.Layout.FocusedPaneID
	if paneID == "" {
		return off, nil
	}

	raw, err = request("pane.get", map[string]string{"pane_id": paneID})
	if err != nil {
		return "", err
	}
	var pane struct {
		Pane struct {
			Agent  string `json:"agent"`
			Status string `json:"agent_status"`
		} `json:"pane"`
	}
	if err := decode(raw, &pane); err != nil {
		return "", err
	}
	if !agents[pane.Pane.Agent] {
		return off, nil
	}
	if state, ok := statusMap[pane.Pane.Status]; ok {
		return state, nil
	}
	return off, nil
}

// decode tolerates a missing result, which unmarshals as the zero value.
func decode(raw json.RawMessage, into any) error {
	if len(raw) == 0 {
		return nil
	}
	return json.Unmarshal(raw, into)
}

// ghosttyPIDs returns Ghostty PIDs. pi used `pgrep -x ghostty`; ps is used here
// because pgrep failed to match anything at all during testing on this machine
// while ps worked everywhere.
func ghosttyPIDs() []int {
	out, err := exec.Command(psPath, "-Ao", "pid,ucomm").Output()
	if err != nil {
		logf("ps failed: %v", err)
		return nil
	}
	var pids []int
	// The header line is dropped for free: "PID" does not parse as an int.
	for line := range strings.SplitSeq(string(out), "\n") {
		fields := strings.Fields(line)
		if len(fields) != 2 || fields[1] != "ghostty" {
			continue
		}
		if pid, err := strconv.Atoi(fields[0]); err == nil {
			pids = append(pids, pid)
		}
	}
	return pids
}

func reloadGhostty() {
	pids := ghosttyPIDs()
	if len(pids) == 0 {
		// Loud on purpose. pi swallowed this with `|| true`, which makes a
		// reload that never fires look identical to a working install that
		// happens to do nothing.
		logf("no ghostty process found; shader not reloaded")
		return
	}
	for _, pid := range pids {
		if err := syscall.Kill(pid, syscall.SIGUSR2); err != nil {
			logf("signalling %d failed: %v", pid, err)
		}
	}
}

func writeFragment(state string) error {
	if err := os.MkdirAll(filepath.Dir(fragment), 0o755); err != nil {
		return err
	}
	// OFF is empty of shader directives, so Ghostty is left with whatever the
	// main config sets (cursor_blaze) and nothing of ours.
	text := "# ghost-in-the-machine: off\n"
	if state != off {
		text = fmt.Sprintf("custom-shader = %s\n", filepath.Join(variants, state+".glsl"))
	}
	temporary := fmt.Sprintf("%s.%d.tmp", fragment, os.Getpid())
	if err := os.WriteFile(temporary, []byte(text), 0o644); err != nil {
		return err
	}
	return os.Rename(temporary, fragment)
}

func apply(state, applied string) string {
	if state == applied {
		return applied
	}
	if err := writeFragment(state); err != nil {
		logf("writing fragment failed: %v", err)
		return applied
	}
	reloadGhostty()
	logf("applied %s", state)
	return state
}

func knownStates() []string {
	seen := map[string]bool{"error": true, off: true}
	for _, state := range statusMap {
		seen[state] = true
	}
	names := make([]string, 0, len(seen))
	for name := range seen {
		names = append(names, name)
	}
	slices.Sort(names)
	return names
}

// selfcheck exercises state resolution against canned herdr replies.
func selfcheck() {
	panes := map[string]map[string]string{
		"p1": {"agent": "claude", "agent_status": "working"},
		"p2": {"agent": "claude", "agent_status": "blocked"},
		"p3": {"agent": "opencode", "agent_status": "idle"},
		"p4": {},
		"p5": {"agent": "codex", "agent_status": "working"},
	}
	var layout map[string]any

	real := request
	defer func() { request = real }()
	request = func(method string, params map[string]string) (json.RawMessage, error) {
		var payload any
		if method == "pane.layout" {
			payload = map[string]any{"layout": layout}
		} else {
			payload = map[string]any{"pane": panes[params["pane_id"]]}
		}
		return json.Marshal(payload)
	}

	focus := func(paneID string, x float64) {
		layout = map[string]any{"focused_pane_id": paneID, "area": map[string]any{"x": x}}
	}
	want := func(expected string) {
		got, err := currentState()
		if err != nil {
			panic(err)
		}
		if got != expected {
			panic(fmt.Sprintf("want %q, got %q", expected, got))
		}
	}

	focus("p1", 26)
	want("working")
	// blocked is a permission prompt: the question-mark face.
	focus("p2", 26)
	want("thinking")
	// opencode drives the same faces as claude.
	focus("p3", 26)
	want("idle")
	// Bare shells and agents we do not claim are off.
	focus("p4", 26)
	want(off)
	focus("p5", 26)
	want(off)
	// Collapsed sidebar wins over everything.
	focus("p1", 0)
	want(off)
	focus("p1", 26)
	want("working")
	// An unknown status is not a face.
	panes["p1"]["agent_status"] = "unknown"
	want(off)
	// No focused pane at all.
	focus("", 26)
	want(off)

	fmt.Println("selfcheck ok")
}

func main() {
	if len(os.Args) > 1 {
		state := os.Args[1]
		if state == "--selfcheck" {
			selfcheck()
			return
		}
		if !slices.Contains(knownStates(), state) {
			fmt.Fprintf(os.Stderr, "usage: ghost-watch [--selfcheck|%s]\n", strings.Join(knownStates(), "|"))
			os.Exit(2)
		}
		if err := writeFragment(state); err != nil {
			logf("writing fragment failed: %v", err)
			os.Exit(1)
		}
		reloadGhostty()
		return
	}

	// Before anything else. The fragment is a file on disk, so a crash or a
	// power cut mid-"working" would otherwise resurrect that face at next login
	// and keep it across reboots.
	applied := apply(off, "")
	down := false
	for {
		state, err := currentState()
		if err != nil {
			// No herdr, no face -- this is what makes "only while herdr is
			// open" literally true rather than usually true.
			if !down {
				logf("herdr unreachable: %v", err)
				down = true
			}
			state = off
		} else if down {
			logf("herdr back")
			down = false
		}
		applied = apply(state, applied)
		if down {
			time.Sleep(retryInterval)
		} else {
			time.Sleep(pollInterval)
		}
	}
}
