# Personal preferences

Shared preferences are imported from `shared.md`; this file adds
Claude / work-specific rules.

@~/Work/dotfiles/ai/shared.md

## Git & GitHub

- End commits with `Co-Authored-By: Claude <noreply@anthropic.com>` — never
  include the model name/version.
- No team/ticket prefixes ([OPTIMUS], [NITRO], …) in commit subjects.
- Don't run `gh pr create` unprompted — go through the /pr skill flow or ask
  first.

## Claude config

- Personal skills/agents live in my dotfiles: `~/Work/dotfiles/ai/claude-skills/`
  and `~/Work/dotfiles/ai/claude-agents/`, symlinked to `~/.claude/skills` and
  `~/.claude/agents`. Write new ones there, not into project repos.

## Plans & scratch docs

- Write plans/scratch to `~/Work/Carwow/claude-docs/<project>/`, never
  inside a repo.
- Keep architecture/shaping/kanban docs concise and decision-focused, not
  long and implementation-heavy. Lead with the decision, not the
  exploration.

## Code

- No code comments unless essential to understanding the code: a genuine
  landmine the code can't show, or a rubocop directive. Motivation belongs in
  the PR body or the card, not in the code. Specs get no comments at all.
