#!/usr/bin/env bash
# SubagentStop gate for carwow-rails-engineer: everything committed, RuboCop clean on the
# Ruby files the branch touches, and the spec files the branch touches green. Blocks once;
# the second stop is let through so a stubborn failure ends up in the report, not in a loop.
set -o pipefail

input=$(cat)
agent_type=$(jq -r '.agent_type // ""' <<<"$input")
[[ "$agent_type" == *carwow-rails-engineer* ]] || exit 0
[[ "$(jq -r '.stop_hook_active // false' <<<"$input")" == "true" ]] && exit 0

cd "$(jq -r '.cwd // "."' <<<"$input")" || exit 0
[[ -f Gemfile ]] || exit 0
branch=$(git branch --show-current 2>/dev/null)
[[ -z "$branch" || "$branch" == "master" || "$branch" == "main" ]] && exit 0

base=origin/master
git rev-parse --verify -q "$base" >/dev/null || base=master

changed=$( { git diff --name-only "$base"...HEAD; git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u )
ruby=()
specs=()
while IFS= read -r f; do
  [[ -n "$f" && -f "$f" ]] || continue
  [[ "$f" =~ \.(rb|rake)$ ]] && ruby+=("$f")
  [[ "$f" =~ ^spec/.*_spec\.rb$ ]] && specs+=("$f")
done <<<"$changed"

problems=""
if [[ -n "$(git status --porcelain)" ]]; then
  problems+="Uncommitted changes remain. Commit them, or say in your report why they are not committed."$'\n'
fi
if (( ${#ruby[@]} )); then
  if ! out=$(carwow run bundle exec rubocop "${ruby[@]}" 2>&1); then
    problems+="RuboCop is not clean on the files this branch touches:"$'\n'"$(tail -40 <<<"$out")"$'\n'
  fi
fi
if (( ${#specs[@]} )); then
  if ! out=$(carwow run bundle exec rspec "${specs[@]}" 2>&1); then
    problems+="Specs this branch touches are failing:"$'\n'"$(tail -40 <<<"$out")"$'\n'
  fi
fi

[[ -z "$problems" ]] && exit 0
printf '%s' "$problems" >&2
exit 2
