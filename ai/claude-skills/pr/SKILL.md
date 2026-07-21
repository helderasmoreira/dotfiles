---
name: pr
description: >-
  Create a GitHub pull request for the current branch. Trigger on "/pr",
  "create a PR", "open a PR", "make a pull request".
---

# PR creator

Create a well-formed GitHub pull request for the current branch, following Hélder's conventions.

## Step 1 — Read the branch

Two guards first:
- `git branch --show-current` — if on `master`, stop and ask the user to create a branch first; there's no PR to make from master.
- `git status --porcelain` — if the working tree is dirty, ask whether to commit those changes first or proceed without them. The PR only includes what's pushed — silently leaving edits behind means the body you validate won't match the diff.

Then run `git fetch origin master` — a stale local `origin/master` makes the diff include already-merged commits.

Then run these in parallel:
- `git log origin/master...HEAD --oneline` — list commits on this branch
- `git diff origin/master...HEAD --stat` — get a sense of size and files changed

Use this to form an initial judgement: is this an **extended** or **short** PR?

**Extended** — feature work, non-trivial bug fixes, A/B test setup/cleanup, anything with meaningful context to explain.

**Short** — small fixes, reverts, dependency bumps, trivial cleanup (one clear thing, no real context needed).

## Step 2 — Choose the template and the card

If the **Kanbanize MCP** is connected, first try to find the card yourself: `search_cards` on board "GYC - Optimus" (board 48) using keywords from the branch name and commit subjects.

Then ask both questions in a **single round** (one AskUserQuestion call), not two exchanges:

1. **Template** — suggest one and say why in one sentence:
   > "I'd suggest the **extended** template — go with that, or switch to short?"
2. **Card** — if the search found a plausible match:
   > "Looks like this is card <id> — '<card title>'. Right one? (or give me another ID / blank for none)"

   If the MCP isn't connected or the search found nothing convincing:
   > "Kanbanize card ID? (leave blank if none)"

Once you have an ID, the card URL is:
`https://carwow.kanbanize.com/ctrl_board/48/cards/<id>/details/`

If they leave it blank, omit the card link entirely.

## Step 3 — Draft title and body

**Title:**
- If a card ID was given: `[OPTIMUS-<id>] <short imperative description>`
- If no card ID: `[OPTIMUS] <short imperative description>`

Keep the title concise and imperative (e.g. "Add location links block to Model Hub pages", not "Added" or "Adding").

**Body — extended template:**
```
Kanbanize card [here](<url>).

---

## Context

<narrative: what was requested / why this change exists — 1–3 sentences>

**Changes:**
- <bullet per meaningful change>

**Behaviour:** *(omit this section if not relevant)*
- <bullet per behavioural note>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**Body — short template:**
```
Kanbanize card [here](<url>).

<1–2 sentence description of what and why>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

If no card ID was given, drop the card link line (and the `---` separator in the extended template).

Keep the tone natural and direct — not bureaucratic. Write the **Changes** bullets from the diff, not from the commit messages (commit messages are often terse; the diff shows what actually changed).

Keep prose minimal — state the gap and the fix; don't elaborate on implementation choices (naming conventions, sections used). Terse ≠ context-free though: when the change has nuance, the product rationale and an honest list of what the change deliberately does *not* cover are welcome.

## Step 4 — Validate

Show the full proposed title and body to the user. Ask:

> "Happy with this? (yes to create, or tell me what to change)"

Iterate on feedback until they approve. Do not run `gh pr create` until they explicitly say yes.

## Step 5 — Create the PR

Push the branch first — `gh pr create` can't prompt for a push target in a non-interactive run:
```
git push -u origin HEAD
```

Write the body to a temp file (inline `--body` breaks on backticks and quotes), then:
```
gh pr create --title "<title>" --body-file <path-to-body-file>
```

Return the PR URL.
