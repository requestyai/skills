---
name: requesty-headers
description: Configures Claude Code to automatically attach branch, repo, PR, agent, and user headers to every API request when routing through Requesty's gateway. Use this skill whenever the user asks to set up Requesty cost tracking, install Requesty headers, configure per-branch attribution, tag Claude Code sessions, or wire up custom headers via ANTHROPIC_CUSTOM_HEADERS. Also use when the user wants to verify their existing Requesty header setup or when they say things like "make Claude Code send my git context to Requesty" or "tag my sessions with the branch I'm on".
allowed-tools: [Read, Bash, Grep, Glob]
---

# Requesty Headers

Installs a shell wrapper around `claude` that injects per-session metadata into `ANTHROPIC_CUSTOM_HEADERS` so Requesty's gateway can attribute cost to the right branch, repo, PR, agent, and user.

## What this produces

Every Claude Code request will carry these headers, computed at session launch:

| Header | What it tracks |
|--------|---------------|
| `X-Requesty-Branch` | Current git branch — see cost per feature branch |
| `X-Requesty-Repo` | `org/repo` from origin — break down spend across repos |
| `X-Requesty-Pr` | PR number — know exactly what a pull request cost |
| `X-Requesty-Ai-Agent` | Claude Code version (e.g. `2.1.123 (Claude Code)`) |
| `X-Requesty-User` | OS username — per-developer spend tracking |

All data is available in your Requesty dashboards. For the full schema, see `references/header-spec.md`.

## Workflow

Walk through these steps in order.

### Step 1 — Inspect the environment

Run the inspect script to see what context will be captured:

```bash
bash scripts/inspect.sh
```

The output is JSON showing the branch, repo, PR, shell, rc file, ai_agent, and user that will be sent.

Show the user the JSON and confirm values look right. If `repo` or `branch` is `none`, ask whether they're in the right directory.

### Step 2 — Install the wrapper

```bash
bash scripts/install.sh
```

This appends a shell function called `claude` to the user's rc file. The function reads git state and runs `claude --version` at every invocation, builds the header string, and execs the real claude binary with `ANTHROPIC_CUSTOM_HEADERS` set.

If the function is already installed, the script replaces it cleanly (markers `# --- Requesty header injection ---` bracket the block).

### Step 3 — Verify

Tell the user to either run `source <rcfile>` or open a new terminal, then in any git repo:

```bash
type claude  # should show the function definition, not the binary
```

If `type claude` returns the binary path, the rc file wasn't sourced.

## When something goes wrong

- **`gh` not installed** — PR detection falls back to `none`. Other headers still work. Suggest `brew install gh`.
- **Not in a git repo** — git fields fall back to `none`. Wrapper still works, requests still route, just untagged.
- **Existing `claude` shell function** — don't overwrite blindly. Show the existing function and ask before replacing.
- **Unknown shell** — install script writes the function to stdout for manual install.

## What this skill does NOT do

- Does not handle authentication (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` are separate).
- Does not refresh headers mid-session. `ANTHROPIC_CUSTOM_HEADERS` is read once at launch.
- Does not modify `~/.claude/settings.json`. All state lives in the shell rc file.
