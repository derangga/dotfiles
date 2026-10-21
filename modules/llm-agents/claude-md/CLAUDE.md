## Tools Search
For any file search or grep in the current git-indexed directory, use fff mcp tools.

## Plans
Before writing a plan or calling ExitPlanMode, load the plan-playbook skill.

## Commits

**Commit only when explicitly told to.** I review the working tree first; committing is not
a step in finishing a task.

- **No trailers.** No `Co-Authored-By`, no `Claude-Session`. Nothing after the body.
- Before writing the message, run `git log --oneline -10` and match its subject style, including any
  `feat:`/`fix:`/`chore:` prefix. Use no prefix only when the log has none.
- Subject: imperative, one line.
- Body: why it was done, what it cost, what it invalidated.
