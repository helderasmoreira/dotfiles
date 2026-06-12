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

- Personal skills/agents/output-styles live in my dotfiles:
  `~/Work/dotfiles/ai:<thing>`, symlinked to `~/.claude/<thing>`. Write new
  ones there, not into project repos.

## Plans & scratch docs

- Write plans/scratch to `~/Work/Carwow/claude-docs/<project>/`, never
  inside a repo.
