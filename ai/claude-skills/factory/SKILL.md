---
name: factory
description: >-
  Take a Kanbanize card from brief to reviewed branch: shape a plan with the user, build it with carwow-rails-engineer one subtask at a time, then critique the branch against the plan until nothing blocking remains. Trigger on "/factory <card id>". Stops before the PR; /pr is a separate step.
disable-model-invocation: true
---

# Factory

Three stages, each a command that already exists. Run them in order and hand the outputs along. Do no engineering in this conversation and never read a diff here: pass paths and commands to the agents, not content.

## 1. Shape

$ARGUMENTS is a Kanbanize card id or URL on board 48. Read the card through the Kanbanize MCP, description and comments, and run /architect with the card as the brief. Always write the handoff doc; do not ask. Put the card URL and the branch name under the first line. Stop when the plan is agreed: that is architect's own stop.

## 2. Build

Create the branch named in the plan from an up-to-date master. Dispatch carwow-rails-engineer once per subtask, in plan order, with the handoff doc path and the subtask number. If the engineer returns questions, put them to the user and stop.

## 3. Critique

Run /review on the branch and give both reviewers the handoff doc path as the stated intent, so the second reviewer checks the branch against the plan instead of a PR description.

Then loop. For each Blocking and Should fix finding, dispatch one carwow-rails-engineer, one after another, told to fix it or say why not. When the last returns, run /review again: Reviewer A blind, full diff, no previous report; Reviewer B with the previous findings and the engineers' replies, to say which were resolved, which were not, and which were declined. Stop when a round leaves no Blocking or Should fix, when a declined finding is re-raised, or after three rounds. Report what is left and stop. The user decides what to do with it and when to run /pr.
