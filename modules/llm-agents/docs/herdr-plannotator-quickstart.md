# Herdr Plannotator Quickstart

Herdr's default prefix is `Ctrl+B`. Press the prefix first, release it, then
press the action key.

## Keymaps

| Keys | Action |
| --- | --- |
| `Ctrl+B`, `A` | Annotate selected terminal text |
| `Ctrl+B`, `Shift+A` | Copy all annotations as Markdown context |
| `Ctrl+B`, `M` | Manage saved and archived annotations |
| `Ctrl+B`, `O` | Review a Markdown document in the current folder |
| `Ctrl+B`, `Shift+O` | Review the agent's latest reply |

## Annotate Terminal Text

1. Select text in a Herdr pane with the mouse.
2. Press `Ctrl+B`, then `A`.
3. Write your comment in the annotation popup.
4. Press `Ctrl+S` to save.

To send the accumulated annotations to an agent:

1. Press `Ctrl+B`, then `Shift+A`.
2. Paste the copied Markdown into the agent pane.

## Manage Annotations

Press `Ctrl+B`, then `M`.

| Key | Action |
| --- | --- |
| `y` | Copy the selected annotation |
| `c` | Copy all active annotations |
| `Shift+C` | Copy all active annotations and archive them |
| `Tab` | Switch between active and archived annotations |
| `u` | Restore the selected archived annotation |
| `d`, `d` | Permanently delete the selected archived annotation |
| `q` | Close the manager |

## Review A Document

1. Focus the agent pane whose working directory contains the document.
2. Press `Ctrl+B`, then `O`.
3. Select a Markdown file from the file tree.
4. Add comments in Plannotator.
5. Choose `Send`, or press `E`, to deliver the review as the agent's next message.
6. Press `q` to close without sending.

You can also `Ctrl`-click a `file://` link ending in `.md`, `.markdown`, or
`.mdx` to open that document directly.

## Review The Latest Reply

1. Focus the agent pane.
2. Press `Ctrl+B`, then `Shift+O`.
3. Annotate the agent's latest reply.
4. Choose `Send`, or press `E`, to return the feedback to that agent.

## Agent-Requested Reviews

The `plannotator-tui` skill lets OpenCode request a review while running inside
Herdr. Ask the agent to write a plan or document and open it for review. The
agent should open Plannotator and end its turn. Your submitted comments arrive
as the next user message.

## Troubleshooting

Check the generated configuration and plugin registration:

```sh
herdr config check
herdr plugin list
herdr plugin action list --plugin annotate
```

Reload Herdr after changing its configuration:

```sh
herdr server reload-config
```
