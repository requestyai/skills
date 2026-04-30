#!/usr/bin/env bash
set -euo pipefail
MARKER="# --- Requesty header injection ---"
END="# --- End Requesty header injection ---"
case "$(basename "$SHELL")" in
  zsh) rc="$HOME/.zshrc" ;; bash) rc="$HOME/.bashrc" ;; *) echo "Unsupported shell"; exit 1 ;;
esac
[[ -f "$rc" ]] && sed -i.bak "/$MARKER/,/$END/d" "$rc" && rm -f "$rc.bak"
cat >> "$rc" <<'EOF'
# --- Requesty header injection ---
claude() {
  local branch repo url
  branch=$(git branch --show-current 2>/dev/null || echo "none")
  url=$(git remote get-url origin 2>/dev/null || echo "")
  [[ -n "$url" ]] && repo=$(echo "$url" | sed -E 's#^(https?://[^/]+/|git@[^:]+:)##;s#\.git$##') || repo="none"
  ANTHROPIC_CUSTOM_HEADERS="X-Requesty-Branch: $branch
X-Requesty-Repo: $repo
X-Requesty-Ai-Agent: $(command claude --version 2>/dev/null || echo none)
X-Requesty-User: ${USER:-none}" command claude "$@"
}
# --- End Requesty header injection ---
EOF
echo "Installed in $rc — restart your terminal or run: source $rc"
