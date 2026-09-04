---
name: pr
description: >-
  Create a GitHub pull request for the current branch. Trigger on "/pr",
  "create a PR", "open a PR", "make a pull request".
---

# PR creator

Create a GitHub pull request for the current branch, following Hélder's conventions.

The body tells the reviewer what the diff cannot: why the change exists, what was decided, and where it stops. Its length tracks how much of that there is, not how big the diff is. A one-line change with a real story gets two paragraphs; a 300-line content swap gets one sentence and a link.

## Step 1 — Read the branch

Two guards first:
- `git branch --show-current` — if on `master`, stop and ask the user to create a branch first; there's no PR to make from master.
- `git status --porcelain` — if the working tree is dirty, ask whether to commit those changes first or proceed without them. The PR only includes what's pushed — silently leaving edits behind means the body you validate won't match the diff.

Then run `git fetch origin master` — a stale local `origin/master` makes the diff include already-merged commits.

Then run these in parallel:
- `git log origin/master...HEAD` with full messages, not `--oneline`: commit bodies often carry the rationale
- `git diff origin/master...HEAD --stat` for size and files touched
- `git diff origin/master...HEAD` and read it; you need it to check the body against later

Collect every link and reference in the commit messages: PR numbers, Bugsnag errors, Honeycomb queries, Notion docs, Slack threads, spreadsheets. They belong in the body as evidence.

## Step 2 — Find the card and its context

If the **Kanbanize MCP** is connected, try to find the card yourself: `search_cards` on board "GYC - Optimus" (board 48) using keywords from the branch name and commit subjects. If the search found a plausible match, read it before asking: `get_card_details_batch` for the description and `get_card_comments_batch` for anything decided along the way. The card is the primary source for why the change exists.

Then ask one question:

- If the search found a match, name the card and state the trigger as you understood it in one sentence:
  > "Looks like this is card <id> — '<card title>': <one-sentence trigger>. Right card and right reading? (or give me another ID / blank for none)"
- If the MCP isn't connected or the search found nothing convincing:
  > "Kanbanize card ID? (leave blank if none)"

Once you have an ID, the card URL is:
`https://carwow.kanbanize.com/ctrl_board/48/cards/<id>/details/`

If they leave it blank, omit the card link entirely.

If, after the card and the commits, you still cannot say what was wrong or missing before this change, ask one more question about that. Do not guess the why; the diff does not contain it.

## Step 3 — Draft title and body

**Title:**
- If a card ID was given: `[OPTIMUS-<id>] <short imperative description>`
- If no card ID: `[OPTIMUS] <short imperative description>`

Keep the title concise and imperative (e.g. "Add location links block to Model Hub pages", not "Added" or "Adding").

**Body.** The why in prose, then an optional **Approach** list, then anything a reviewer or deployer must know. No markdown headings in the prose; the list gets a bold lead-in, and the only heading is the screenshots section at the end.

```
Kanbanize card [here](<url>).

<Why: what was wrong or missing and how you know it, with the concrete evidence (the symptom as seen, the numbers, the linked Bugsnag error, Honeycomb query, Notion doc, Slack thread or spreadsheet), and the cause. When an obvious alternative was rejected, a second paragraph says why.>

**Approach:**
- <A decision the reviewer should know before opening the diff, with its reason in the same bullet.>
- <Another decision, or a boundary: what this deliberately does not do, what is deferred to a follow-up.>

<What a reviewer or deployer must know: stacked on #<n>, supersedes #<n>, seed with a rake task, flag to flip, hold the merge until <x>.>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

The why is always there. The Approach list exists only when there are decisions beyond the one the why already states; a fix whose whole story fits in one paragraph gets that paragraph and nothing else. The closing notes are omitted when there are none. Every paragraph and every bullet is a single line with no manual wrapping: GitHub re-wraps the body at 72 columns when it squashes, and hand-wrapped lines land in `git log` as orphan fragments.

An Approach bullet is a decision with its reason in the same bullet, or a boundary. The test is whether a reviewer should know it before opening the diff and would not learn it from the diff alone: a choice between two ways of doing it, a consequence not visible in the code, an edge case handled a particular way, something deliberately left undone. A value that changed or a method that moved is the diff's job. The label is "Approach", never "Changes" or "Behaviour".

Example (#38615, trimmed):

```
The configurator recommender calls Gemini on a shared pay-as-you-go capacity pool (the `global` endpoint), which rejects a small share of requests with a 429 when the pool runs hot (~2% on 16-17 July, mostly in one short flare). With `max_retries: 0` every rejection currently becomes a lost recommendation, even though in most cases we'd have enough time to retry ([Honeycomb](<url>)).

The gem's own retry middleware isn't used because it also re-runs timeouts and can't be scoped per status: two 12s attempts would blow past Fastly's 15s `first_byte_timeout` and users would get a Fastly error instead of the app's fallback.

**Approach:**
- Rate-limited calls are retried once on a fresh agent instance; a second 429 falls back and notifies Bugsnag as before.
- Retried requests are flagged on the Honeycomb span (`configuration_recommender.rate_limit_retried`) so the retry rate and payoff are queryable.
- During the hottest seconds of a capacity flare the retry may be rejected too; behaviour then is unchanged (empty result, fallback screen).
- Timeouts are deliberately not retried.
```

Sources, in order: the card description and comments, the commit bodies, the links collected in Step 1, and the answer to the trigger question. Then read the diff and check every claim in the body against it. The diff is for accuracy, not for generating content.

Then re-read with two cuts. Would this sentence still be true and obvious after reading the diff? Then it narrates the mechanism; the reviewer reads the files anyway, so cut it. Is this the immediate reason for this change, or context about the wider initiative that the card already holds? Then it belongs to the card link; cut it, leaving at most one line of shared context when the PR is one slice of something larger.

Outside the Approach list, bullets only for a genuine enumeration (the states a job cleans, the flags created, the pairs swapped), introduced by what they enumerate.

Keep the tone natural and direct, not bureaucratic. State what was wrong, what was decided and where it stops; do not narrate implementation choices (naming, which class a method went in). Concrete beats general: "484 vs 500 litres", "roughly 115px on mobile", "57 loose jobs".

UI changes get screenshots after the prose under a `## Before / after` or `## Screenshots` heading, desktop and mobile where the layout differs. Capture them into `tmp/pr_screenshots/` (gitignored); Step 5 attaches them.

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

With screenshots, reference each one in the body as `![alt](./tmp/pr_screenshots/<file>.png)` and pass one `--attach ./tmp/pr_screenshots/<file>.png` per image; `gh` 2.99+ uploads them and rewrites the references. Run from the repo root so the paths match, and delete the folder once the PR is up.

Return the PR URL.
