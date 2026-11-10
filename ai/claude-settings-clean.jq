.hooks |= with_entries(
  .value |= map(
    .hooks |= map(select((.command // "") | contains(".orca/agent-hooks") | not))
    | select(.hooks | length > 0)
  )
  | select(.value | length > 0)
)
| if (.theme // "") == "custom:orca" then .theme = "dark" else . end
