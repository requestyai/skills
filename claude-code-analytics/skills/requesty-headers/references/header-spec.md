# Requesty Custom Headers Specification

## Overview

Requesty's gateway captures any HTTP header with the `X-Requesty-` prefix and makes it available in your Requesty dashboards. This lets you break down API spend by branch, PR, developer, or any custom dimension — so you can answer questions like "how much did this PR cost?" or "which feature branch is burning the most credits?"

## Standard Headers

These are the headers injected by the Requesty Headers skill:

### `X-Requesty-Branch`
- **Type**: string
- **Source**: `git branch --show-current`
- **Fallback**: `"none"` when not in a git repo
- **Use case**: See cost per feature branch in your Requesty dashboard

### `X-Requesty-Repo`
- **Type**: string (format: `org/repo-name`)
- **Source**: `git remote get-url origin`, parsed to strip protocol/host
- **Fallback**: `"none"` when no remote configured
- **Use case**: Break down spend across multiple repositories

### `X-Requesty-Pr`
- **Type**: string (numeric PR number or `"none"`)
- **Source**: `gh pr view --json number -q .number`
- **Fallback**: `"none"` when no PR exists or `gh` not installed
- **Use case**: Track exactly how much a pull request cost to build

### `X-Requesty-Ai-Agent`
- **Type**: string
- **Source**: `claude --version` (e.g. `2.1.123 (Claude Code)`)
- **Fallback**: `"none"` when Claude Code version cannot be detected
- **Use case**: Track which Claude Code version is generating spend

### `X-Requesty-User`
- **Type**: string
- **Source**: `USER` environment variable
- **Fallback**: `"none"` when unset
- **Use case**: See per-developer spend in your Requesty dashboard

## Custom Headers

You can add your own `X-Requesty-*` headers beyond the standard set. Any header with the prefix will be captured and available in your dashboards. Examples:

- `X-Requesty-Team: platform`
- `X-Requesty-Environment: staging`
- `X-Requesty-Sprint: 2026-Q2-S3`

## How It Works

1. The shell wrapper sets `ANTHROPIC_CUSTOM_HEADERS` before launching Claude Code
2. Claude Code sends these headers with every API request to Requesty's gateway
3. Requesty captures all `X-Requesty-*` headers and stores them with the request
4. Headers are stripped before forwarding to the AI provider — they never leave Requesty

## Format in ANTHROPIC_CUSTOM_HEADERS

Claude Code reads `ANTHROPIC_CUSTOM_HEADERS` as newline-separated `Name: Value` pairs:

```
X-Requesty-Branch: feat/my-feature
X-Requesty-Repo: myorg/myrepo
X-Requesty-Pr: 42
X-Requesty-Ai-Agent: 2.1.123 (Claude Code)
X-Requesty-User: alice
```
