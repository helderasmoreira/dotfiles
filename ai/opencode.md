# OpenCode preferences

Shared preferences live in `~/Work/dotfiles/ai/shared.md`. This file adds
OpenCode / personal-project rules.

## Git & GitHub

- End commits with `Co-Authored-By: OpenCode (<model>) <noreply@opencode.ai>`,
  replacing `<model>` with the model you're running as (e.g. kimi-k3).

## OpenCode config

- Global OpenCode config lives at `~/.config/opencode/opencode.json`.
- Personal instructions live in my dotfiles: `~/Work/dotfiles/ai/opencode.md`,
  referenced from `opencode.json`. Write new ones there, not into project
  repos.

## Plans & scratch docs

- Write plans/scratch to `~/Work/opencode-docs/<project>/`, never inside a
  repo.
- Keep architecture/shaping/kanban docs concise and decision-focused, not
  long and implementation-heavy. Lead with the decision, not the
  exploration.
