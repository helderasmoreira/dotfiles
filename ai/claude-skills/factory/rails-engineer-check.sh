#!/usr/bin/env bash
# Run by the factory after each carwow-rails-engineer dispatch, from the repo root:
# everything committed, RuboCop clean on the Ruby files the branch touches, and the spec
# files the branch touches green. Exits 2 with the problems on stderr. Also accepts hook
# JSON on stdin (cwd, agent_type) so it can be wired to a hook again if that ever works.
set -o pipefail

input=$(cat 2>/dev/null)
[[ -z "$input" ]] && input='{}'
agent_type=$(jq -r '.agent_type // ""' <<<"$input")
branch=""
trap 'rc=$?; echo "$(date +%FT%T) agent=${agent_type:-cli} branch=$branch exit=$rc" >> "$HOME/.claude/rails-engineer-check.log"' EXIT
[[ -z "$agent_type" || "$agent_type" == *carwow-rails-engineer* ]] || exit 0

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
