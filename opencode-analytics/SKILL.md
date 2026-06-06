---
name: requesty-opencode-analytics
description: Installs a shell wrapper and configures OpenCode to send per-session metadata headers (branch, repo, agent, user) to Requesty's gateway. Use this skill when the user asks to set up Requesty analytics for OpenCode, configure cost tracking per branch or repo in OpenCode, install Requesty headers for OpenCode, or wire up OpenCode to route through Requesty with attribution metadata.
---

# Requesty OpenCode Analytics

Installs a shell wrapper around `opencode` that injects per-session metadata into Requesty tracking headers, and configures `opencode.json` with the requesty provider.

## What this produces

Every OpenCode request routed through Requesty will carry these headers:

| Header | What it tracks |
|--------|---------------|
| `X-Requesty-Branch` | Current git branch for per-feature cost tracking |
| `X-Requesty-Repo` | `org/repo` from origin for per-repo spend breakdown |
| `X-Requesty-Ai-Agent` | OpenCode version identifier |
| `X-Requesty-User` | OS username for per-developer tracking |

## Installation

Run the install script:

```bash
bash install.sh
```

This will:
1. Add a shell function wrapper for `opencode` to your rc file (bash, zsh, or fish)
2. Create `opencode.json` if it does not exist
3. Add the requesty provider configuration
4. Merge tracking headers into the requesty provider config

After installation, run `source ~/.zshrc` (or your shell's rc file) or open a new terminal.

## Verification

```bash
type opencode  # should show the function definition, not the binary
```

## Notes

- If not in a git repo, branch and repo fields fall back to `none`. The wrapper still works.
- The script is idempotent. Running it again skips already-installed components.
- Requires `jq` for JSON config manipulation.
