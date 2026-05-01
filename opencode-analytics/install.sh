#!/usr/bin/env bash
set -euo pipefail

# 1. Install a shell function that sets REQUESTY_* env vars before launching opencode
# 2. Ensure opencode.json exists (create if missing)
# 3. Add requesty provider if missing
# 4. Merge Requesty tracking headers into the requesty provider

MARKER_START="# --- Requesty header injection (opencode) ---"
MARKER_END="# --- End Requesty header injection (opencode) ---"

# --- Part 1: Shell wrapper ---

shell_name=$(basename "$SHELL" 2>/dev/null || echo "unknown")

case "$shell_name" in
  zsh)  rc_file="$HOME/.zshrc" ;;
  bash) rc_file="$HOME/.bashrc" ;;
  fish) rc_file="$HOME/.config/fish/config.fish" ;;
  *)    echo "Unsupported shell: $shell_name"; exit 1 ;;
esac

if [[ -f "$rc_file" ]] && grep -q "$MARKER_START" "$rc_file"; then
  echo "Shell wrapper already installed in $rc_file — skipping"
else
  if [[ "$shell_name" == "fish" ]]; then
    cat >> "$rc_file" <<'FISHEOF'

# --- Requesty header injection (opencode) ---
function opencode
  set -gx REQUESTY_BRANCH (git branch --show-current 2>/dev/null; or echo "none")
  set -l repo_url (git remote get-url origin 2>/dev/null; or echo "")
  if test -n "$repo_url"
    set -gx REQUESTY_REPO (echo "$repo_url" | sed -E 's#^(https?://[^/]+/|git@[^:]+:)##; s#\.git$##')
  else
    set -gx REQUESTY_REPO "none"
  end
  set v (opencode --version 2>/dev/null; or echo "opencode")
  set -gx REQUESTY_AI_AGENT "$v (OpenCode)"
  set -gx REQUESTY_USER "$USER"
  command opencode $argv
end
# --- End Requesty header injection (opencode) ---
FISHEOF
  else
    cat >> "$rc_file" <<'SHEOF'

# --- Requesty header injection (opencode) ---
opencode() {
  export REQUESTY_BRANCH="$(git branch --show-current 2>/dev/null || echo "none")"
  local repo_url="$(git remote get-url origin 2>/dev/null || echo "")"
  if [[ -n "$repo_url" ]]; then
    export REQUESTY_REPO="$(echo "$repo_url" | sed -E 's#^(https?://[^/]+/|git@[^:]+:)##; s#\.git$##')"
  else
    export REQUESTY_REPO="none"
  fi
  export REQUESTY_AI_AGENT="$(command opencode --version 2>/dev/null || echo "opencode") (OpenCode)"
  export REQUESTY_USER="${USER:-none}"
  command opencode "$@"
}
# --- End Requesty header injection (opencode) ---
SHEOF
  fi
  echo "Installed shell wrapper in $rc_file"
fi

# --- Part 2: Ensure opencode.json exists ---

config=""
[[ -f "./opencode.json" ]] && config="./opencode.json"
[[ -z "$config" && -f "$HOME/.config/opencode/opencode.json" ]] && config="$HOME/.config/opencode/opencode.json"

if [[ -z "$config" ]]; then
  config_dir="$HOME/.config/opencode"
  mkdir -p "$config_dir"
  config="$config_dir/opencode.json"
  
  cat > "$config" <<'CONFIGEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "requesty": {
      "options": {
        "headers": {}
      }
    }
  }
}
CONFIGEOF
  echo "Created opencode.json at $config"
fi

if ! command -v jq &>/dev/null; then
  echo "jq is required but not installed"
  exit 1
fi

# --- Part 3: Ensure requesty provider exists ---

if ! jq -e '.provider.requesty' "$config" >/dev/null 2>&1; then
  jq '.provider.requesty = {
    "npm": "@ai-sdk/openai-compatible",
    "name": "Requesty",
    "options": {
      "baseURL": "http://localhost:8080/v1",
      "headers": {}
    }
  }' "$config" > "$config.tmp" && mv "$config.tmp" "$config"
  echo "Added requesty provider to $config"
fi

# --- Part 4: Merge headers into requesty provider ---

existing=$(jq -r '.provider.requesty.options.headers // {} | keys[]' "$config" 2>/dev/null)
if echo "$existing" | grep -q "X-Requesty-Branch"; then
  echo "Requesty headers already present — skipping"
else
  requesty_headers='{
    "X-Requesty-Branch": "{env:REQUESTY_BRANCH}",
    "X-Requesty-Repo": "{env:REQUESTY_REPO}",
    "X-Requesty-Ai-Agent": "{env:REQUESTY_AI_AGENT}",
    "X-Requesty-User": "{env:REQUESTY_USER}"
  }'
  
  jq --argjson rh "$requesty_headers" \
    '.provider.requesty.options.headers = ((.provider.requesty.options.headers // {}) * $rh)' \
    "$config" > "$config.tmp" && mv "$config.tmp" "$config"
  echo "Merged Requesty headers into $config"
fi

echo ""
echo "Done! Run 'source $rc_file' or open a new terminal to activate."
