#!/bin/sh
set -eu

exec >>"$HOME/Library/Logs/claude-docs-snapshot.log" 2>&1
cd "$HOME/Work/Carwow/claude-docs"

if [ -z "$(git status --porcelain)" ]; then
  echo "$(date '+%F %T') nothing to commit"
  exit 0
fi

git add -A
git commit -q -m "Automatic commit $(date +%F)"
echo "$(date '+%F %T') committed $(git rev-parse --short HEAD)"
