# Personal preferences

## Git & GitHub

- Commit messages: imperative headline only; add a body only when the change
  is big enough to justify it.
- No team/ticket prefixes ([OPTIMUS], [NITRO], …) in commit subjects.
- End commits with `Co-Authored-By: Claude <noreply@anthropic.com>` — never
  include the model name/version.
- Don't run `gh pr create` unprompted — go through the /pr skill flow or ask
  first.
- Never post comments, replies, or reviews on GitHub conversations unless I
  explicitly ask — don't offer or draft replies proactively.

## Claude config

- Personal skills/agents live in my dotfiles: `~/Work/dotfiles/ai:<thing>`,
  symlinked to `~/.claude/<thing>`. Write new ones there, not into project
  repos.

## Testing

- When writing or rewriting RSpec specs, follow existing repository
  conventions for mocking/stubbing — read a similar existing spec first
  before writing new test code.

## Verification

- Always read the actual source file before claiming it needs changes or
  describing its behavior — do not trust subagent claims, stale copies, or assumptions. Verify file paths and branches
  before editing.

## Writing & voice

Applies to anything drafted for me: cards, briefs, PR descriptions, docs,
messages, review copy.

- No em dashes. Use colons, commas, parentheses, or split sentences.
- Write "AB test", never "A/B" or "A-B".
- Start leaner than feels natural: state the outcome, the real constraints,
  and precise code/doc references. Cut benefit/justification prose, restated
  decisions, and anything derivable from a linked doc or the code.
- Leave room for the implementer: no suggested class names, field
  enumerations, or testing instructions in cards and briefs.
- Express preferences qualitatively; don't invent numeric thresholds
  (e.g. "~70 lines") unless I supplied the number.
- For long drafts, offer one section at a time for review rather than the
  full text at once.

## Plans & scratch docs

- Write plans/scratch to `~/Work/Carwow/claude-docs/<project>/`, never
  inside a repo.
- Keep architecture/shaping/kanban docs concise and decision-focused, not
  long and implementation-heavy. Lead with the decision, not the
  exploration.
