---
name: experiment-status
description: >-
  Use when the user wants to know whether an A/B test / experiment is live. Trigger on "/experiment-status", "is X live?", "is the X test running?". The user passes the exact test name (the experiment NAME constant, no suffix). Reports live/not from the `-enter` flag in production and links to relevant flags. Read-only — never modifies flags.
# Read-only by construction: auto-approve the one LD read, and remove every mutating tool.
# Note: there is only an "allow only X" — disallowed-tools is an explicit denylist, so new LD write tools could be added later here too.
allowed-tools: mcp__launchdarkly__get-flag
disallowed-tools: [Bash, Edit, Write, NotebookEdit, mcp__launchdarkly__toggle-flag, mcp__launchdarkly__update-rollout, mcp__launchdarkly__update-targeting-rules, mcp__launchdarkly__update-flag-settings, mcp__launchdarkly__update-individual-targets, mcp__launchdarkly__update-prerequisites, mcp__launchdarkly__create-flag, mcp__launchdarkly__delete-flag, mcp__launchdarkly__archive-flag, mcp__launchdarkly__copy-flag-config, mcp__launchdarkly__create-experiment, mcp__launchdarkly__update-experiment, mcp__launchdarkly__start-experiment-iteration, mcp__launchdarkly__save-and-start-experiment-iteration, mcp__launchdarkly__stop-experiment-iteration, mcp__launchdarkly__start-guarded-rollout, mcp__launchdarkly__stop-guarded-rollout, mcp__launchdarkly__create-approval-request, mcp__launchdarkly__apply-approval-request]
---

# Experiment status reporter

The user passes the **exact test name** (the experiment `NAME` constant, e.g. `gyc-configurator-pre-configured-derivatives-optimus-apr-26`, with no suffix). You report **whether it's live** and link to its flags.

**Read-only.** Never call a LaunchDarkly write/toggle tool. If a read fails or two reads disagree, say so rather than guessing.

## What you need to know

- The two flags are `<test-name>-enter` and `<test-name>-variants`. **`-enter` is what decides "live?"** — `-variants` only controls the split among entered users.
- **Front-end tests (done using the A/B test library in www) have only `-enter` — there is no `-variants` flag** (the split is assigned client-side). A missing `-variants` flag is expected, not an error: report `-enter` as normal and note the variants flag doesn't exist.
- LaunchDarkly project is `default`; report from the `production` environment.
- A flag only serves its rules/fallthrough when **`on: true`**. If `on: false` it serves the off-variation → **not live**, regardless of the rollout shown.

## Steps

1. Read `<test-name>-enter` in `production` via the LD MCP (`get-flag`). If the connector isn't authenticated/reachable, say so and stop.
2. Decide live:
   - `on: false` → **NOT LIVE**.
   - `on: true` → **LIVE**; state what enters from the fallthrough/rules (e.g. "100% enter", or a `groups`/segment rule).
3. Read `<test-name>-variants` in `production` (same `get-flag`) to report the split among entered users — the fallthrough weights per variation (e.g. 50/50 control/variant). If `on: false`, note the split isn't being served. If the flag doesn't exist, it's a front-end test → say `variants: none (front-end test)` and skip the split.
4. Print the result + the split + both flag links.

## Output

```
<test-name>
LIVE in production — 100% enter · split 50/50 control/variant   (or: NOT LIVE — enter is off)

Flags
  enter:    https://app.launchdarkly.com/projects/default/flags/<test-name>-enter/targeting?env=production
  variants: https://app.launchdarkly.com/projects/default/flags/<test-name>-variants/targeting?env=production
```

For a front-end test, drop the variants line and note it: `variants: none (front-end test)`.
