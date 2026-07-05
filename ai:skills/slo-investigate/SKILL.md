---
name: slo-investigate
description: >-
  Investigate a breaching SLO via Honeycomb. Trigger on "/slo-investigate", "what's causing the
  X SLO breach", "investigate the CLS breach", "why is the latency SLO red". Read-only.
allowed-tools:
  - mcp__claude_ai_Honeycomb__get_workspace_context
  - mcp__claude_ai_Honeycomb__get_slos
  - mcp__claude_ai_Honeycomb__get_triggers
  - mcp__claude_ai_Honeycomb__find_columns
  - mcp__claude_ai_Honeycomb__run_query
  - mcp__claude_ai_Honeycomb__run_bubbleup
  - mcp__claude_ai_Honeycomb__list_spans
  - mcp__claude_ai_Honeycomb__get_span_details
  - mcp__claude_ai_Slack__slack_search_public_and_private
  - Bash(git log:*)
  - Bash(git show:*)
  - Bash(git -C:*)
disallowed-tools:
  - Edit
  - Write
  - NotebookEdit
---

# SLO investigator

**Read-only.** Triage a breaching SLO by pulling Honeycomb data, identifying the worst offenders,
and cross-referencing recent changes. Output a Slack-pasteable investigation block the team can
act on immediately.

## What the user passes

- **SLO name** (optional, e.g. `CLS`, `latency`, `jobs`). If omitted, list all currently-breaching
  SLOs and ask which to investigate.
- **Time window** (optional, default `24h`). Accepts natural language: `1h`, `7d`, `last week`.

## Steps

### 1. Orient

Call `get_workspace_context` to get the environment slug (almost always `production`).

### 2. Find the SLO

Call `get_slos` (list mode) to fetch all SLOs.

- If the user named one: match by case-insensitive substring. If ambiguous, list the matches and
  ask. If not found, say so and stop.
- If no name was given: filter to SLOs where `budget_remaining < 100%` (i.e. actively burning).
  Show a brief table and ask which one to dig into.

### 3. Get SLO detail

Call `get_slos` with the `slo_id` to fetch: current compliance %, target %, budget remaining %,
burn rate, the dataset it's defined on, and the SLI expression. Note the dataset slug — you'll
need it for the query steps.

### 4. Discover breakdown dimensions

Call `find_columns` on the SLO's dataset with a broad intent like `page path component type name`.
Look for columns that represent the *what* (page, route, component, job class, etc.) — these will
be your breakdown axes. Pick the 2–3 most useful ones (prefer specific ones like `page_type` or
`request.path` over generic ones like `name`).

### 5. Find the worst offenders

Run a `run_query` on the SLO's dataset that:
- **Time range**: the user's window (default `24h`).
- **Filters**: match the SLI failure condition (derive it from the SLI expression — e.g. if the
  SLI is "CLS < 0.1", filter to `CLS >= 0.1`; if it's a success-rate SLI, filter to error spans).
  If you can't derive the filter from the expression, use a broad failure signal (e.g. `error=true`
  or a status-code filter) and note the assumption.
- **Breakdowns**: the 2–3 columns you identified.
- **Calculations**: `COUNT` (alias `failures`).
- **Order**: descending by `failures`.
- **Limit**: 10.

This surfaces the pages/components responsible for most failures.

### 6. Check for recent context in Slack

Search `#product-optimus-private` for the SLO name in the last 48h to see if someone already
started a thread: `in:#product-optimus-private <slo-name> after:<48h-ago-date>`.
If a thread exists, link to it in the output rather than duplicating.

### 7. Cross-reference recent deploys

Fetch first — a stale local clone silently shows no recent deploys and makes the investigation look clean when it isn't:

```
git -C ~/Work/Carwow/quotes_site fetch origin
git -C ~/Work/Carwow/quotes_site log origin/master --oneline --since="<window> ago" --no-merges
```

Flag any commits that touch code related to the top offenders (e.g. a component name appears in
the commit message or changed files). Use `git show --stat <hash>` to check changed files for
the most suspicious commits.

### 8. Present findings

Produce a Slack-pasteable block. See output format below. Be concise — engineers want to act, not
read an essay. If data is thin or Honeycomb returned no results, say so explicitly rather than
speculating.

## Output format

```
:rotating_light: [SLO] <SLO name> — <BREACHING / AT RISK / HEALTHY>

*Compliance:* X% (target: Y%) | *Budget remaining:* Z% | *Burn rate:* N×
*Dataset:* <dataset> | *Window:* last 24h

:bar_chart: *Worst offenders*
• <component/page> — N failures (X% of total)
• <component/page> — N failures (X% of total)
• <component/page> — N failures (X% of total)

:git: *Recent deploys that may be relevant*
• `<hash>` <message> — <author> (<time ago>)
  → touches: <file or component>

:bulb: *Hypothesis*
<1–2 sentences connecting the data. Only write this if the data supports a clear candidate.
If nothing stands out, write "No clear culprit yet — worth checking X and Y manually.">

:link: <Honeycomb SLO detail link>
<Slack thread link if one exists>
```

If Honeycomb is unreachable (503/502), say so clearly and still run the recent-deploys step so
the output is partially useful.
