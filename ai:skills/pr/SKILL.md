---
name: pr
description: >-
  Create a GitHub pull request for the current branch. Trigger on "/pr",
  "create a PR", "open a PR", "make a pull request". Reads the diff and
  commits, picks a template (extended or short), asks for the Kanbanize
  card ID, drafts the title and body for validation, then runs gh pr create.
---

# PR creator

Create a well-formed GitHub pull request for the current branch, following Hélder's conventions.

## Step 1 — Read the branch

Run these in parallel:
- `git log origin/master...HEAD --oneline` — list commits on this branch
- `git diff origin/master...HEAD --stat` — get a sense of size and files changed

Use this to form an initial judgement: is this an **extended** or **short** PR?

**Extended** — feature work, non-trivial bug fixes, A/B test setup/cleanup, anything with meaningful context to explain.

**Short** — small fixes, reverts, dependency bumps, trivial cleanup (one clear thing, no real context needed).

## Step 2 — Choose the template

Tell the user which template you'd suggest and why (one sentence), then ask:

> "I'd suggest the **extended** template — go with that, or switch to short?"

Wait for their answer before continuing.

## Step 3 — Get the card ID

Always ask:

> "Kanbanize card ID? (leave blank if none)"

If they provide an ID, the card URL is:
`https://carwow.kanbanize.com/ctrl_board/48/cards/<id>/details/`

If they leave it blank, omit the card link entirely.

## Step 4 — Draft title and body

**Title:**
- If a card ID was given: `[OPTIMUS-<id>] <short imperative description>`
- If no card ID: `<short imperative description>`

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

## Step 5 — Validate

Show the full proposed title and body to the user. Ask:

> "Happy with this? (yes to create, or tell me what to change)"

Iterate on feedback until they approve. Do not run `gh pr create` until they explicitly say yes.

## Step 6 — Create the PR

Run:
```
gh pr create --title "<title>" --body "<body>"
```

Return the PR URL.
