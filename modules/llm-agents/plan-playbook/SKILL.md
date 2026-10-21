---
name: plan-playbook
description: Rules for writing an implementation plan, technical design, PRD or proposal before code exists. Use whenever you are about to write a plan, enter plan mode, or call ExitPlanMode.
---

# Plan playbook

A plan is read by someone who has to approve it without asking you questions. Write it so they can.

## Before writing

Read the code the plan touches. Every claim about current behavior must come from a file you read or a command you ran. Cite the path. Label anything you inferred as an inference.

## Structure

1. Goal, current state, desired behavior. Three short parts, in that order.
2. Proposed approach, at the level of decisions. Skip step-by-step edits unless the user asked for them.
3. Options, only where there is a real choice (see below).
4. Failure modes, migration, and backwards compatibility. Write "none" with a reason if there are none. Do not leave the section out.
5. Not covered. What the plan deliberately leaves out, and where to look next. This is a list of things you considered and cut, not a summary.
6. Risks and open questions.

## Options

- Name the decision first.
- Show the concrete shape of each option (the file, the config, the behavior), not abstract pros and cons.
- State the cost of each option as plainly as its benefit.
- Say which assumption would flip the recommendation.
- Recommend one option only when the evidence supports it. If one option is clearly better, say so. Do not present every option as equal.

## Review with plannotator

Every plan goes through plannotator before you act on it.

- In plan mode, call ExitPlanMode. The plannotator plugin hooks it and opens the review in the browser. Do not also run the CLI.
- Outside plan mode, write the plan to a markdown file and run `plannotator annotate <file> --gate --json`. Wait for the decision. Treat the annotations as the user's feedback, revise the plan, and review again until the user approves.
- Do not start implementing until the user approves.

## Check before you finish

- Could another developer implement this from the plan alone?
- Did you plan only the ambiguous parts and forget the actual proposal?
- Are there use cases the user did not mention but the code implies? Callers, tests, config, existing data, other hosts or users. List them under Not covered or handle them.
- Is any open question already resolved? Update the plan to the decision and delete the question.
