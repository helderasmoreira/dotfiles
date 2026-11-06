#!/usr/bin/env bash

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -z "$cmd" ] && exit 0

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

ask() {
  jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'
  exit 0
}

gh_api_writes() {
  if printf '%s\n' "$cmd" | grep -qE 'gh api[[:space:]]+graphql'; then
    printf '%s\n' "$cmd" | grep -qi 'mutation'
    return
  fi
  if printf '%s\n' "$cmd" | grep -qE '(-X|--method)[[:space:]=]*[A-Za-z]'; then
    printf '%s\n' "$cmd" | grep -qiE '(-X|--method)[[:space:]=]*(POST|PUT|PATCH|DELETE)'
    return
  fi
  printf '%s\n' "$cmd" | grep -qE '[[:space:]](-f|-F|--field|--raw-field|--input)([[:space:]=]|$)'
}

case "$cwd" in
  "$HOME/Work/Carwow"/*) carwow=1 ;;
  *) carwow=0 ;;
esac

at_cmd='(^|[;&|(`])[[:space:]]*'

if [ "$carwow" = 1 ] && printf '%s\n' "$cmd" | grep -qE "${at_cmd}git worktree add"; then
  deny "Use 'carwow worktree add BRANCH' instead of plain 'git worktree add'."
fi

if [ "$carwow" = 1 ] && printf '%s\n' "$cmd" | grep -qE "${at_cmd}bundle exec"; then
  deny "Prefix 'bundle exec' with 'carwow run' in Carwow repos (carwow run bundle exec ...)."
fi

if printf '%s\n' "$cmd" | grep -qE "${at_cmd}gh api" && gh_api_writes; then
  ask "This 'gh api' call writes to GitHub."
fi

printf '%s\n' "$cmd" | grep -qE '(^|[;&|]|\s)git commit' || exit 0

if printf '%s\n' "$cmd" | grep -qE 'Co-Authored-By: Claude [A-Za-z0-9]'; then
  deny "Commit trailer must be exactly 'Co-Authored-By: Claude <noreply@anthropic.com>' with no model name or version."
fi

if printf '%s\n' "$cmd" | grep -qE "^\[[A-Z][A-Z0-9-]*\]|-m ['\"]\[[A-Z][A-Z0-9-]*\]"; then
  deny "No team or ticket prefix ([OPTIMUS], [NITRO-123], ...) in commit subjects."
fi

[ "$carwow" = 1 ] && [ -d "$cwd" ] || exit 0
cd "$cwd" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

spec_comments=$(
  {
    git diff HEAD -U0 -- 'spec/*.rb' 2>/dev/null | grep -E '^\+\s*#' | sed 's/^+//'
    git ls-files --others --exclude-standard -- 'spec/*.rb' 2>/dev/null | xargs -r grep -hE '^\s*#'
  } | grep -vE '^\s*#\s*(frozen_string_literal|rubocop:)' | head -5
)
if [ -n "$spec_comments" ]; then
  deny "Specs get no comments. Remove these before committing:
$spec_comments"
fi

ruby_files=()
while IFS= read -r f; do ruby_files+=("$f"); done < <(git status --porcelain --untracked-files=all 2>/dev/null | grep -vE '^.?D' | awk '{print $NF}' | grep -E '\.rb$')
[ "${#ruby_files[@]}" = 0 ] && exit 0
out=$(carwow run bundle exec rubocop --force-exclusion --format simple "${ruby_files[@]}" 2>&1)
status=$?
if [ "$status" = 1 ]; then
  deny "Rubocop offences in changed files. Fix them (or run 'carwow run bundle exec rubocop -a' on them) before committing:
$(printf '%s\n' "$out" | grep -v 'Using configured COUNTRY' | tail -25)"
fi
exit 0
