---
name: requesty-observability
description: Set up full-stack LLM observability with Requesty — usage analytics, cost tracking, performance monitoring, session reconstruction, and tool call analytics. Use this skill when the user asks about monitoring AI usage, tracking LLM performance, setting up analytics dashboards, debugging AI conversations, understanding latency, analyzing tool call patterns, exporting analytics data, or tagging requests with metadata. Also use when the user mentions analytics headers, X-Requesty headers, request metadata, performance monitoring, P50/P90/P99 latency, cache hit rates, or session replay through Requesty.
---

# Requesty Observability

Full-stack LLM observability: real-time usage analytics, per-request cost tracking, latency percentiles, tool call analytics, session reconstruction, and CSV exports — all built into the gateway with zero SDK changes.

## Prerequisites

- Requesty API key (`rqy_...`) — https://app.requesty.ai/api-keys
- Analytics dashboard: https://app.requesty.ai/analytics

## What You Get Out of the Box

Every request through Requesty is automatically tracked. No additional setup needed for basic analytics:

| Metric | Description |
|--------|-------------|
| **Cost** | Per-request USD cost in `usage.cost` (every response) |
| **Tokens** | Input, output, cached, reasoning tokens per request |
| **Latency** | TTFT, total latency, generation speed |
| **Model** | Which model/provider handled the request |
| **Cache** | Hit/miss, tokens saved, dollars saved |
| **Status** | Success, error codes, rate limits |

## Tagging Requests for Granular Analytics

### Analytics Headers

Add `X-Requesty-*` HTTP headers to tag requests with arbitrary metadata. Headers are captured by Requesty, stripped before forwarding to the AI provider, and available as dimensions in dashboards.

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_...",
    default_headers={
        "HTTP-Referer": "https://yourapp.com",       # identifies your app
        "X-Title": "My App",                          # human-readable app name
        "X-Requesty-Agent": "support-bot",            # custom: which agent
        "X-Requesty-Environment": "production",       # custom: env
        "X-Requesty-Team": "platform",                # custom: team
    }
)
```

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://router.requesty.ai/v1",
  apiKey: "rqy_...",
  defaultHeaders: {
    "HTTP-Referer": "https://yourapp.com",
    "X-Title": "My App",
    "X-Requesty-Agent": "support-bot",
    "X-Requesty-Environment": "production",
    "X-Requesty-Team": "platform",
  },
});
```

```bash
curl https://router.requesty.ai/v1/chat/completions \
  -H "Authorization: Bearer $REQUESTY_API_KEY" \
  -H "HTTP-Referer: https://yourapp.com" \
  -H "X-Title: My App" \
  -H "X-Requesty-Agent: support-bot" \
  -H "X-Requesty-Environment: production" \
  -H "X-Requesty-Team: platform" \
  -H "Content-Type: application/json" \
  -d '{"model": "anthropic/claude-sonnet-4-5", "messages": [{"role": "user", "content": "Hello"}]}'
```

**Auto-detected sources**: Cline, Roo Code, Claude Code, and Open WebUI automatically send `HTTP-Referer` and `X-Title` headers — you can filter by tool in your dashboards without any configuration.

### Request Metadata (Body-Level)

For more structured metadata, use the `requesty` field in the request body:

```python
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",
    messages=[...],
    extra_body={
        "requesty": {
            "tags": ["code-review", "production"],
            "user_id": "user_1234",
            "trace_id": "session_abc123",
            "extra": {
                "feature": "code-review",
                "ticket": "ENG-1234",
                "environment": "staging",
                "tier": "premium"
            }
        }
    }
)
```

| Field | Type | Description |
|-------|------|-------------|
| `tags` | `string[]` | Filterable labels for grouping requests |
| `user_id` | `string` | Associate request with a specific user |
| `trace_id` | `string` | Group related requests into a session/trace |
| `extra` | `object` | Arbitrary key-value pairs for custom analytics dimensions |

## Dashboard Views

### Usage Analytics (https://app.requesty.ai/analytics)

| View | What it shows |
|------|--------------|
| **Cost Over Time** | Daily/weekly/monthly spend with trend lines |
| **Requests Over Time** | Request volume and patterns |
| **Tokens Over Time** | Input, output, cached, reasoning token usage |
| **Group By** | Slice by model, provider, user, API key, or any custom field |

### Performance Monitoring

| Metric | Description |
|--------|-------------|
| **P50/P90/P95/P99 latency** | Latency percentiles across all requests |
| **TTFT** | Time-to-first-token for streaming requests |
| **Error rates** | 4xx, 5xx, timeouts by model/provider |
| **Throughput** | Tokens/sec output generation speed |
| **CSV export** | Download raw performance data |

### Cost & Savings

| Metric | Description |
|--------|-------------|
| **Total spend** | Current period cost |
| **Projected spend** | Estimated end-of-period cost |
| **Cache savings ($)** | Dollars saved through prompt caching |
| **Cache savings (%)** | Percentage saved vs uncached cost |
| **Cache hit rate** | What % of requests hit cache |
| **Token cache rate** | What % of tokens served from cache |
| **Per-model savings** | Which models benefit most from caching |

### Tool Call Analytics

| Metric | Description |
|--------|-------------|
| **Tool call frequency** | Which tools/functions are called most |
| **Tool call cost** | Cost attributed to tool-using requests |
| **Tool call latency** | Time spent in tool execution |

### Session Reconstruction

Replay full conversation sessions for debugging — see the exact sequence of messages, tool calls, and model responses in a session:

https://app.requesty.ai/analytics → Session view

## Coding Agent Analytics Setup

For Claude Code, OpenCode, and similar agents, use the dedicated analytics skills that inject per-session metadata (branch, repo, agent, user) automatically:

- Claude Code: see `requesty-headers` skill
- OpenCode: see `requesty-opencode-analytics` skill

These inject `X-Requesty-*` headers per session so you can track cost per branch, per repo, per developer.

## Per-Request Cost in Your Code

```python
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",
    messages=[{"role": "user", "content": "Hello"}]
)

# Access cost directly
cost = response.usage.cost
print(f"This request: ${cost:.6f}")
print(f"Tokens: {response.usage.prompt_tokens} in, {response.usage.completion_tokens} out")
```

For streaming with cost:

```python
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",
    messages=[{"role": "user", "content": "Hello"}],
    stream=True,
    stream_options={"include_usage": True}
)

for chunk in response:
    if chunk.choices:
        print(chunk.choices[0].delta.content or "", end="")
    if chunk.usage:
        print(f"\nCost: ${chunk.usage.cost:.6f}")
```

## Request Feedback

Submit quality feedback on responses for tracking:

```python
# After getting a response, submit feedback
import requests
requests.post(
    "https://router.requesty.ai/v1/feedback",
    headers={"Authorization": "Bearer rqy_..."},
    json={
        "request_id": response.id,
        "rating": "thumbs_up"  # or "thumbs_down"
    }
)
```

## Links

- Analytics dashboard: https://app.requesty.ai/analytics
- Usage analytics docs: https://docs.requesty.ai/features/usage-analytics
- Cost tracking docs: https://docs.requesty.ai/features/cost-tracking
- Performance monitoring: https://docs.requesty.ai/features/performance-monitoring
- Analytics headers: https://docs.requesty.ai/features/analytics-headers
- Request metadata: https://docs.requesty.ai/features/request-metadata
- Tool call analytics: https://docs.requesty.ai/features/tool-call-analytics
- Session reconstruction: https://docs.requesty.ai/features/session-reconstruction
- Request feedback: https://docs.requesty.ai/features/request-feedback
