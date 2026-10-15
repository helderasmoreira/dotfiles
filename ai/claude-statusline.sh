#!/usr/bin/env bash
input=$(cat)

model=$(jq -r '.model.display_name' <<<"$input")
effort=$(jq -r '.effort.level // empty' <<<"$input")
context=$(jq -r '.context_window.used_percentage // 0 | floor' <<<"$input")
dir=$(jq -r '.workspace.current_dir' <<<"$input")
repo=$(jq -r --arg dir "$dir" '.workspace.repo.name // ($dir | split("/") | last)' <<<"$input")
branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)

line="$model"
[ -n "$effort" ] && line+=" ($effort)"
line+=" · ${context}% context · $repo"
[ -n "$branch" ] && line+=" · $branch"

echo "$line"
