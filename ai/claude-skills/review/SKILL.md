---
name: review
description: >-
  Review a PR, a branch, or the working tree with parallel carwow-code-reviewer agents (the full review, a claims audit of the description against the diff, and the same review on a second model), then return one ranked list. Trigger on "/review", "review this PR", "review #40155", "review my branch before I push". Read-only: never edits, commits, pushes, or posts to GitHub.
allowed-tools:
  - Agent
  - Bash(git fetch:*)
  - Bash(git branch:*)
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(gh pr view:*)
  - Bash(gh pr diff:*)
disallowed-tools:
  - Edit
  - Write
  - NotebookEdit
---

# Parallel review

Orchestrate the `carwow-code-reviewer` agent instead of reviewing in this conversation. The agent holds the mandate, the Carwow checklist and the report shape. This skill resolves the target, runs the agent several times at once with different focuses, and merges what comes back into one list the user can act on.

**Read-only.** Never edit files, commit, push, or post anything to GitHub. Findings go to the user in chat; they decide what to do with them.

## Step 1: Resolve the target

The argument is one of:

- **A PR number or URL** (`40155`, `#40155`, a `github.com/.../pull/40155` link). Run `gh pr view <n> --json number,title,headRefName,baseRefName,url` to confirm it exists and learn the base branch. The agents fetch the diff, description and comments themselves.
- **A branch name.** Run `git fetch origin master` so the base is fresh. The agents run `git diff origin/master...<branch>` for the code and `git log origin/master..<branch>` for the commit messages.
- **Nothing.** Review the working tree: `git diff origin/master...HEAD`, plus `git diff HEAD` for uncommitted changes and `git status --porcelain` for untracked files. On master with a clean tree, say there is nothing to review and stop.

Write down the exact commands the agents should run so every one of them looks at the same thing. Do not paste the diff into the prompts.

## Step 2: Launch the reviewers in parallel

One message, all Agent calls together, each with `subagent_type: carwow-code-reviewer`. Wait for all of them. Do not start a review of your own in the meantime.

**Reviewer A: full review.** The agent's own mandate, unchanged. The prompt gives the target (the commands to run, and for a PR the number so it can read the description and comments) and says "Review as your definition describes."

**Reviewer B: claims audit.** Same agent, narrowed. The prompt gives the same target and then:

> Focus only on the claims made about this change, not on code quality. Read the PR description and the commit messages. Extract every factual claim about behaviour: "behaves the same", "no functional change", "equivalent", "already covered by specs", "only affects X", "backwards compatible", and any number or measurement. For each, trace the diff and the surrounding code and classify it as VERIFIED (with the file:line or command output that proves it), FALSE (with the evidence), or UNVERIFIABLE from the code alone. Then list OMISSIONS: behaviour the diff changes that the description does not mention and a reviewer would want to know. Propose corrected wording for every FALSE and UNVERIFIABLE claim. Return those four sections instead of the usual report shape.

Skip Reviewer B when there is no description and no commit message to audit, and say so in the output.

**Reviewer C: second model.** The same prompt as A, word for word, with the Agent tool's `model` override set to a model this session is not running on: `opus` by default, `fable` if the session is already on Opus. The prompt must be identical so a disagreement comes from the model, not the wording.

## Step 3: Merge

Read B first. Its VERIFIED evidence settles questions A and C could only ask, and corrects facts they got wrong; when it does, say so and cite the evidence rather than listing the question as open. Then build one list from A and C, deduplicated by file and issue, ranked as:

- **Blocking**: would break production, leak data, or drop behaviour the change was not meant to drop.
- **Should fix**: real, not blocking.
- **Ignore**: raised but not worth acting on, with a one-line reason each.

Then two short sections:

- **Disagreements**: findings only one of A and C raised, and severities they disagree on. Name which reviewer raised what. Do not pick a side silently; if you checked one side yourself, say how.
- **Claims**, from B: FALSE first with the proposed wording, then UNVERIFIABLE, then OMISSIONS. Leave VERIFIED out unless the user asks for it.

Each item is one or two lines with a `file:line`. A clean PR gets a short output that says so. End with one line: would you block merge, and on what.

## What not to do

- Do not re-run a reviewer because you dislike its answer. Report it under Disagreements.
- Do not fix anything, even a one-liner. The user asks for fixes separately.
- Do not post to GitHub. The user pastes what they want to keep.
