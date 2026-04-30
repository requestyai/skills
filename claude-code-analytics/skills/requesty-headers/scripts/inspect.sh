#!/usr/bin/env bash
set -euo pipefail

# Collect environment context for Requesty headers and output as valid JSON.

sanitize() { printf '%s' "$1" | tr -d '\r\n"'; }

branch=$(sanitize "$(git branch --show-current 2>/dev/null || echo "none")")

repo="none"
repo_url=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -n "$repo_url" ]]; then
  repo=$(sanitize "$(echo "$repo_url" | sed -E 's#^(https?://[^/]+/|git@[^:]+:)##; s#\.git$##')")
fi

ai_agent="none"
cc_version=$(sanitize "$(command claude --version 2>/dev/null || echo "")")
if [[ -n "$cc_version" ]]; then
  ai_agent="$cc_version"
fi

shell_name=$(basename "$SHELL" 2>/dev/null || echo "unknown")

rc_file=""
case "$shell_name" in
  zsh)  rc_file="$HOME/.zshrc" ;;
  bash) rc_file="$HOME/.bashrc" ;;
  fish) rc_file="$HOME/.config/fish/config.fish" ;;
  *)    rc_file="unknown" ;;
esac

os_user=$(sanitize "${USER:-none}")

cat <<EOF
{
  "context": {
    "branch": "$branch",
    "repo": "$repo",
    "ai_agent": "$ai_agent",
    "user": "$os_user",
    "shell": "$shell_name",
    "rc_file": "$rc_file"
  }
}
EOF
