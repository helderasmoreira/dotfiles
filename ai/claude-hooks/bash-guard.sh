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

scope=staged
add_paths=()
while IFS= read -r segment; do
  read -ra words <<<"${segment#git add}"
  for w in "${words[@]}"; do
    w=${w//[\"\']/}
    case "$w" in
      -A|--all|.|:/) scope=all ;;
      -u|--update) [ "$scope" = all ] || scope=tracked ;;
      -*|"") ;;
      *) add_paths+=("$w") ;;
    esac
  done
done < <(printf '%s\n' "$cmd" | grep -oE 'git add[^;&|]*')
if [ "$scope" = staged ] && printf '%s\n' "$cmd" | grep -qE 'git commit[^;&|]*[[:space:]](-[A-Za-z]*a[A-Za-z]*|--all)([[:space:]]|$)'; then
  scope=tracked
fi

worktree_changes() {
  git status --porcelain --untracked-files=all -- "$@" | grep -vE '^.?D' | awk '{print $NF}'
}

committed_files() {
  case "$scope" in
    all) worktree_changes ;;
    tracked) git diff HEAD --name-only --diff-filter=d ;;
    staged)
      git diff --cached --name-only --diff-filter=d
      [ "${#add_paths[@]}" = 0 ] || worktree_changes "${add_paths[@]}"
      ;;
  esac 2>/dev/null
}

files=()
while IFS= read -r f; do [ -n "$f" ] && files+=("$f"); done < <(committed_files | sort -u)
[ "${#files[@]}" = 0 ] && exit 0
cd "$(git rev-parse --show-toplevel)" || exit 0

spec_comments=$(
  for f in "${files[@]}"; do
    [[ "$f" == spec/*.rb ]] || continue
    if git ls-files --error-unmatch -- "$f" >/dev/null 2>&1; then
      git diff HEAD -U0 -- "$f" | grep -E '^\+\s*#' | sed 's/^+//'
    else
      grep -hE '^\s*#' "$f"
    fi
  done | grep -vE '^\s*#\s*(frozen_string_literal|rubocop:)' | head -5
)
if [ -n "$spec_comments" ]; then
  deny "Specs get no comments. Remove these before committing:
$spec_comments"
fi

ruby_files=()
for f in "${files[@]}"; do [[ "$f" == *.rb ]] && ruby_files+=("$f"); done
[ "${#ruby_files[@]}" = 0 ] && exit 0
out=$(carwow run bundle exec rubocop --force-exclusion --format simple "${ruby_files[@]}" 2>&1)
status=$?
if [ "$status" = 1 ]; then
  deny "Rubocop offences in changed files. Fix them (or run 'carwow run bundle exec rubocop -a' on them) before committing:
$(printf '%s\n' "$out" | grep -v 'Using configured COUNTRY' | tail -25)"
fi
exit 0
