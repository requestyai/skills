#!/usr/bin/env bash
set -euo pipefail

# Install the Requesty header-injection wrapper into the user's shell rc file.

MARKER_START="# --- Requesty header injection ---"
MARKER_END="# --- End Requesty header injection ---"

shell_name=$(basename "$SHELL" 2>/dev/null || echo "unknown")

generate_wrapper() {
  if [[ "$shell_name" == "fish" ]]; then
    cat <<'FISHEOF'
# --- Requesty header injection ---
function __requesty_sanitize
  string replace -ra '[\r\n]' '' -- $argv
end

function claude
  set -l branch (__requesty_sanitize (git branch --show-current 2>/dev/null; or echo "none"))
  set -l repo_url (git remote get-url origin 2>/dev/null; or echo "")
  set -l repo "none"
  if test -n "$repo_url"
    set repo (__requesty_sanitize (echo "$repo_url" | sed -E 's#^(https?://[^/]+/|git@[^:]+:)##; s#\.git$##'))
  end
  set -l ai_agent (__requesty_sanitize (command claude --version 2>/dev/null; or echo "none"))
  set -l cc_user (__requesty_sanitize "$USER")
  if test -z "$cc_user"; set cc_user "none"; end

  set -l headers "X-Requesty-Branch: $branch
X-Requesty-Repo: $repo
X-Requesty-Ai-Agent: $ai_agent
X-Requesty-User: $cc_user"
  ANTHROPIC_CUSTOM_HEADERS="$headers" command claude $argv
end
# --- End Requesty header injection ---
FISHEOF
    return
  fi

  cat <<'WRAPEOF'
# --- Requesty header injection ---
__requesty_sanitize() { printf '%s' "$1" | tr -d '\r\n'; }

claude() {
  local branch repo repo_url ai_agent cc_user headers

  branch=$(__requesty_sanitize "$(git branch --show-current 2>/dev/null || echo "none")")
  repo_url=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ -n "$repo_url" ]]; then
    repo=$(__requesty_sanitize "$(echo "$repo_url" | sed -E 's#^(https?://[^/]+/|git@[^:]+:)##; s#\.git$##')")
  else
    repo="none"
  fi

  ai_agent=$(__requesty_sanitize "$(command claude --version 2>/dev/null || echo "none")")
  cc_user=$(__requesty_sanitize "${USER:-none}")

  headers="X-Requesty-Branch: $branch
X-Requesty-Repo: $repo
X-Requesty-Ai-Agent: $ai_agent
X-Requesty-User: $cc_user"

  ANTHROPIC_CUSTOM_HEADERS="$headers" command claude "$@"
}
# --- End Requesty header injection ---
WRAPEOF
}

rc_file=""
case "$shell_name" in
  zsh)  rc_file="$HOME/.zshrc" ;;
  bash) rc_file="$HOME/.bashrc" ;;
  fish) rc_file="$HOME/.config/fish/config.fish" ;;
  *)
    echo "Unsupported shell: $shell_name"
    echo "Add this function to your shell config manually:"
    echo ""
    generate_wrapper
    exit 0
    ;;
esac

if [[ -f "$rc_file" ]]; then
  if grep -q "^claude()" "$rc_file" 2>/dev/null && ! grep -q "$MARKER_START" "$rc_file" 2>/dev/null; then
    echo "WARNING: Found an existing 'claude' function in $rc_file that wasn't installed by this script."
    echo "Please review and remove it manually before running this installer."
    exit 1
  fi
fi

if [[ -f "$rc_file" ]] && grep -q "$MARKER_START" "$rc_file" 2>/dev/null; then
  sed -i.bak "/$MARKER_START/,/$MARKER_END/d" "$rc_file"
  rm -f "${rc_file}.bak"
  echo "Replaced existing Requesty header block in $rc_file"
fi

echo "" >> "$rc_file"
generate_wrapper >> "$rc_file"
echo "" >> "$rc_file"

echo "Installed Requesty header wrapper in $rc_file"
echo ""
echo "Headers that will be sent:"
echo "  X-Requesty-Branch:   current git branch"
echo "  X-Requesty-Repo:     org/repo from git origin"
echo "  X-Requesty-Ai-Agent: Claude Code version"
echo "  X-Requesty-User:     OS username"
echo ""
echo "Run 'source $rc_file' or open a new terminal to activate."
