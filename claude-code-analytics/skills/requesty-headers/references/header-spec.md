# Requesty Custom Headers Specification

## Overview

Requesty's gateway captures any HTTP header with the `X-Requesty-` prefix and stores it in the interaction's `extra` field in ClickHouse. This allows customers to attach arbitrary metadata to every API request for cost attribution, debugging, and analytics.

## Standard Headers

These are the headers injected by the Requesty Headers skill:

### `X-Requesty-Branch`
- **Type**: string
- **Source**: `git branch --show-current`
- **Fallback**: `"none"` when not in a git repo
- **Use case**: Cost attribution by feature branch

### `X-Requesty-Repo`
- **Type**: string (format: `org/repo-name`)
- **Source**: `git remote get-url origin`, parsed to strip protocol/host
- **Fallback**: `"none"` when no remote configured
- **Use case**: Multi-repo cost attribution

### `X-Requesty-Pr`
- **Type**: string (numeric PR number or `"none"`)
- **Source**: `gh pr view --json number -q .number`
- **Fallback**: `"none"` when no PR exists or `gh` not installed
- **Use case**: PR-level spend tracking

### `X-Requesty-Ai-Agent`
- **Type**: string
- **Source**: `claude --version` (e.g. `2.1.123 (Claude Code)`)
- **Fallback**: `"none"` when Claude Code version cannot be detected
- **Use case**: Track which agent version generated the cost

### `X-Requesty-User`
- **Type**: string
- **Source**: `USER` environment variable
- **Fallback**: `"none"` when unset
- **Use case**: Per-developer cost tracking

## Custom Headers

Customers can add their own `X-Requesty-*` headers beyond the standard set. Any header with the prefix will be captured and stored. Examples:

- `X-Requesty-Team: platform`
- `X-Requesty-Environment: staging`
- `X-Requesty-Sprint: 2026-Q2-S3`

## Backend Implementation

Headers are captured by `client_meta.FromRequestyHeaders()` in the router:
1. All `X-Requesty-*` headers are popped from the incoming request
2. Merged into `requesty.Extra.Extra` map via `mergeIntoExtra()`
3. Stored in ClickHouse `chat_interactions.extra` as JSON
4. Headers are NOT forwarded to upstream providers (stripped before proxying)

## Format in ANTHROPIC_CUSTOM_HEADERS

Claude Code reads `ANTHROPIC_CUSTOM_HEADERS` as newline-separated `Name: Value` pairs:

```
X-Requesty-Branch: feat/my-feature
X-Requesty-Repo: myorg/myrepo
X-Requesty-Pr: 42
X-Requesty-Ai-Agent: 2.1.123 (Claude Code)
X-Requesty-User: alice
```
