---
name: requesty-mcp-gateway
description: Set up and manage MCP (Model Context Protocol) servers through Requesty's unified gateway. Use this skill when the user asks about connecting AI coding tools to MCP servers, setting up MCP for Claude Code or Cursor or Roo Code, managing MCP authentication, registering MCP servers, configuring MCP tools, or monitoring MCP usage. Also use when the user mentions MCP gateway, MCP server management, MCP user keys, MCP analytics, or wants to centralize tool access for their AI coding agents through Requesty.
---

# Requesty MCP Gateway

Connect AI coding tools (Claude Code, Cursor, Roo Code) to any MCP server through a single secure gateway — with centralized authentication, tool whitelisting, and usage analytics.

## Prerequisites

- Requesty account — https://app.requesty.ai
- MCP Gateway enabled: Settings → Integrations → MCP Gateway
- Dashboard: https://app.requesty.ai/mcp-gateway

## What This Solves

Without Requesty MCP Gateway:
- Each developer configures MCP servers individually
- API keys scattered across machines
- No visibility into tool usage or costs
- No access control over which tools are available

With Requesty MCP Gateway:
- One gateway URL for all MCP servers
- Centralized key management (org-wide or per-user)
- Tool whitelisting — expose only approved tools
- Full analytics: who used what, when, how much

## Setup Steps

### 1. Register an MCP Server

Go to https://app.requesty.ai/mcp-gateway → **Add Server**

**From template** (pre-configured for popular services):
- GitHub — repository management, code search
- Notion — workspace and content management
- Linear — issue tracking, project management
- Context7 — AI context management
- Asana — task and project coordination

**Custom server**:

```json
{
  "name": "my-internal-api",
  "url": "https://mcp.internal.company.com",
  "transport": "streamable-http",
  "auth": {
    "type": "header",
    "header_name": "Authorization",
    "header_value": "Bearer <token>"
  }
}
```

### 2. Whitelist Tools

After registering a server, select which specific tools to expose. Only whitelisted tools are available to AI agents — everything else is blocked.

### 3. Configure Authentication

**Standard plan — Org-wide keys**:
- Admin configures API keys for each MCP server once
- All org members share the same authentication
- Best for: internal tools, shared services, org-owned API keys

**Enterprise plan — Per-user keys**:
- Admin registers servers and defines required auth headers
- Each user provides their own keys via dashboard
- Best for: external services requiring personal API keys (GitHub PATs, Linear tokens)

### 4. Connect AI Tools

#### Claude Code

Add to your Claude Code MCP config (`~/.claude/mcp_servers.json` or project `.mcp.json`):

```json
{
  "mcpServers": {
    "requesty": {
      "type": "streamable-http",
      "url": "https://mcp.requesty.ai/v1/mcp",
      "headers": {
        "Authorization": "Bearer rqy_your_api_key"
      }
    }
  }
}
```

#### Cursor

Add to Cursor's MCP settings (Settings → MCP Servers):

```json
{
  "requesty": {
    "type": "streamable-http",
    "url": "https://mcp.requesty.ai/v1/mcp",
    "headers": {
      "Authorization": "Bearer rqy_your_api_key"
    }
  }
}
```

#### Roo Code

Add to Roo Code's MCP configuration:

```json
{
  "mcpServers": {
    "requesty": {
      "type": "streamable-http",
      "url": "https://mcp.requesty.ai/v1/mcp",
      "headers": {
        "Authorization": "Bearer rqy_your_api_key"
      }
    }
  }
}
```

## Monitoring MCP Usage

### Analytics Dashboard

https://app.requesty.ai/mcp-analytics shows:

| Metric | Description |
|--------|-------------|
| **Tool calls by server** | Which MCP servers are used most |
| **Tool calls by user** | Who's using which tools |
| **Latency** | Response times per server/tool |
| **Error rates** | Failed tool calls and error types |
| **Cost** | If the MCP server has associated costs |

### Security Features

| Feature | Description |
|---------|-------------|
| **AES-256 encryption** | All credentials encrypted at rest |
| **Organization isolation** | Complete separation between orgs |
| **Tool whitelisting** | Only explicitly approved tools are accessible |
| **Audit logging** | Full trail of who accessed what |
| **Per-user keys** | Individual authentication (Enterprise) |

## Decision Tree

```
What are you setting up?
├── Internal tools for your team?
│   └── Org-wide keys → admin configures once, team uses immediately
├── External services (GitHub, Linear, Notion)?
│   ├── Shared org account → org-wide keys
│   └── Individual accounts → per-user keys (Enterprise)
├── Custom MCP server?
│   └── Register with URL + auth → whitelist tools → connect agents
└── Monitoring usage?
    └── MCP Analytics → https://app.requesty.ai/mcp-analytics
```

## Links

- MCP Gateway setup: https://app.requesty.ai/mcp-gateway
- MCP Gateway docs: https://docs.requesty.ai/features/mcp-gateway
- Server management: https://docs.requesty.ai/features/mcp-server-management
- User keys: https://docs.requesty.ai/features/mcp-user-keys
- MCP Analytics: https://docs.requesty.ai/features/mcp-analytics
- Agent integration guide: https://docs.requesty.ai/features/mcp-integration
