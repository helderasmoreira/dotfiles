# Shared preferences

## Git & GitHub

- Commit messages: imperative headline only; add a body only when the change
  is big enough to justify it.
- Never post comments, replies, or reviews on GitHub conversations unless I
  explicitly ask — don't offer or draft replies proactively.

## Testing

- When writing or rewriting specs, follow existing repository conventions for
  mocking/stubbing — read a similar existing spec first before writing new
  test code.
- Request specs prove the HTTP contract and wiring only: status, redirects
  and URL scheme, headers (cache, robots), auth restrictions, which sections render
  for an input, jobs enqueued, stream sources or structured data present or
  absent. What an input produces (text, titles, meta, links, image URLs,
  lists) is asserted in presenter/unit specs, not request specs, even at one
  assertion per section. Accepted gap: "the view reads the presenter key"
  stays unproven.
- Literal template output (no branch, interpolation or presenter key) gets no
  spec at all, even where the repo has precedent for one.

## Verification

- Always read the actual source file before claiming it needs changes or
  describing its behavior — do not trust subagent claims, stale copies, or
  assumptions. Verify file paths and branches before editing.

## Writing & voice

Applies to chat replies and anything drafted for me: cards, briefs, PR
descriptions, docs, messages, review copy.

- Full sentences, one idea each, active voice. One term per concept, the
  code's name where it has one.
- No AI-speak: contrast-negation ("X was never the problem. Y was."),
  rhetorical questions, slogan headlines, double negatives, filler openers,
  many small sections. Say the thing directly.
- No em dashes. Use colons, commas, parentheses, or split sentences.
- "AB test", never "A/B" or "A-B".
- Lean: outcome, real constraints, precise references. Cut justification,
  restated decisions, anything derivable from the code or a linked doc, and
  numbers I didn't supply.
- Long drafts: one section at a time for review.
