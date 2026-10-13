#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$DOTFILES/$1" dest="$2"

  if [ "$(readlink "$dest" 2>/dev/null)" = "$src" ]; then
    echo "ok      $dest"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -f "$dest" ] && [ ! -L "$dest" ] && cmp -s "$src" "$dest"; then
      rm "$dest"
    else
      mv "$dest" "$dest.bak"
      echo "backup  $dest.bak"
    fi
  fi

  ln -s "$src" "$dest"
  echo "linked  $dest"
}

link zsh/.zshrc ~/.zshrc
link zsh/.zprofile ~/.zprofile
link ssh/config ~/.ssh/config
link git/.gitconfig ~/.gitconfig
link git/.gitignore_global ~/.gitignore_global
link vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
link ai/claude.md ~/.claude/CLAUDE.md
link ai/claude-skills ~/.claude/skills
link ai/claude-agents ~/.claude/agents
link ai/opencode.json ~/.config/opencode/opencode.json
link ai/carwow.md ~/Work/Carwow/CLAUDE.md
