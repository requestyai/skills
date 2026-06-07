---
name: requesty-cost-optimization
description: Reduce AI costs by up to 90% with Requesty's caching, budget controls, and cost tracking. Use this skill when the user asks about reducing LLM costs, enabling prompt caching, setting budget limits, tracking AI spend, comparing model pricing, or optimizing token usage. Also use when the user mentions auto_cache, spend limits, cost per request, BYOK savings, cache hit rates, or wants to understand where their AI budget is going through Requesty.
---

# Requesty Cost Optimization

Reduce AI spending by up to 90% through automatic prompt caching, real-time cost tracking, budget controls, and smart model selection — all without changing your application code.

## Prerequisites

- Requesty API key (`rqy_...`) — https://app.requesty.ai/api-keys
- Analytics dashboard: https://app.requesty.ai/analytics

## How Requesty Tracks Costs

Every API response includes the USD cost in the `usage` object:

```json
{
  "usage": {
    "prompt_tokens": 13,
    "completion_tokens": 17,
    "total_tokens": 30,
    "cost": 0.0000935
  }
}
```

- **Non-streaming**: `usage.cost` returned by default
- **Streaming**: pass `stream_options: {"include_usage": true}` to get a final chunk with `usage.cost`

## 1. Auto Caching — Biggest Cost Saver

Requesty automatically caches long system prompts and repeated content. Cache hits cost a fraction of normal input tokens.

### Enable Auto Cache

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_..."
)

response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",
    messages=[
        {"role": "system", "content": "YOUR LARGE SYSTEM PROMPT / KNOWLEDGEBASE"},
        {"role": "user", "content": "Answer my question"}
    ],
    extra_body={
        "requesty": {
            "auto_cache": True
        }
    }
)
```

```typescript
const response = await client.chat.completions.create({
  model: "anthropic/claude-sonnet-4-5",
  messages: [
    { role: "system", content: "YOUR LARGE SYSTEM PROMPT / KNOWLEDGEBASE" },
    { role: "user", content: "Answer my question" }
  ],
  requesty: {
    auto_cache: true
  }
});
```

### Cache Pricing (from live API data)

| Model | Normal Input | Cached Input | Savings |
|-------|-------------|-------------|---------|
| `anthropic/claude-sonnet-4-5` | $3.00/M | $0.30/M | **90%** |
| `openai/gpt-5.5` | $5.00/M | $0.50/M | **90%** |
| `google/gemini-2.5-pro` | $1.25/M | $0.31/M | **75%** |
| `deepseek/deepseek-chat` | $0.14/M | $0.028/M | **80%** |

> Cache pricing from `cached_price` field in `GET /v1/models`. Some providers also charge a `caching_price` for cache writes (e.g. Anthropic: $3.75/M for writes, $0.30/M for reads).

### When Auto Cache Helps Most

- Large system prompts (>1000 tokens) sent repeatedly
- Knowledge bases, documentation, or few-shot examples in every request
- Multi-turn conversations with long message histories
- Applications making many requests with the same context

### Defaults

| Source | Default behavior |
|--------|-----------------|
| Cline, Roo Code | Auto cache ON by default |
| Direct API calls | OFF unless `auto_cache: true` is set |
| `auto_cache: false` | Explicitly disables caching (useful when cache writes have extra costs) |

## 2. Budget Controls

### Per-Key Spend Limits

Set maximum monthly spend per API key in the dashboard:

https://app.requesty.ai/api-keys → Edit key → Set spend limit

### Per-Project Limits

Each project (including each user's Private project) can have its own monthly budget:

https://app.requesty.ai/settings → Projects → Set limit

### Spending Alerts

Configure alerts at custom thresholds with email or webhook notifications:

https://app.requesty.ai/alerts

## 3. Cost-Aware Model Selection

### Decision Tree by Budget

```
What's your monthly budget?
├── <$10/month
│   ├── Text only → deepseek/deepseek-chat ($0.14/M in, $0.28/M out)
│   ├── Need tools → deepseek/deepseek-v4-flash ($0.14/M in, $0.28/M out)
│   └── OpenAI ecosystem → openai/gpt-5-nano ($0.05/M in, $0.40/M out)
├── $10–$100/month
│   ├── General purpose → google/gemini-2.5-flash ($0.15/M in, $0.60/M out)
│   ├── Coding → anthropic/claude-haiku-4-5 ($0.80/M in, $4.00/M out)
│   └── With caching → anthropic/claude-sonnet-4-5 + auto_cache
└── $100+/month
    ├── Best quality → anthropic/claude-sonnet-4-5 ($3/M in, $15/M out)
    ├── Frontier reasoning → openai/gpt-5.5 ($5/M in, $30/M out)
    └── Cost-tiered fallback → policy/ with cheap→expensive chain
```

> Prices from live `GET /v1/models` response. Always verify current pricing.

### Compare Cost Per Request

```python
import json, urllib.request

api_key = "rqy_..."
req = urllib.request.Request(
    "https://router.requesty.ai/v1/models",
    headers={"Authorization": f"Bearer {api_key}"}
)
data = json.loads(urllib.request.urlopen(req).read())

# Estimate cost for a typical request (1000 input, 500 output tokens)
input_tokens, output_tokens = 1000, 500
print(f"{'Model':45s} {'Cost/request':>12s}")
for model in sorted(data["data"], key=lambda x: (x.get("input_price") or 0)):
    if model["id"].startswith("policy/"):
        continue
    inp = model.get("input_price") or 0
    out = model.get("output_price") or 0
    cost = inp * input_tokens + out * output_tokens
    if cost > 0:
        print(f"{model['id']:45s} ${cost:.6f}")
```

## 4. BYOK (Bring Your Own Keys) Savings

Use your own provider API keys through Requesty to potentially get volume discounts while keeping routing, caching, and analytics:

https://app.requesty.ai/settings → Provider Keys

The analytics dashboard splits costs into **Requesty Cost** vs **Provider Cost** for easy comparison.

## 5. Cost Tracking Dashboard

### Real-Time Breakdowns

The analytics dashboard at https://app.requesty.ai/analytics shows:

| View | What it shows |
|------|--------------|
| **Cost Over Time** | Daily/weekly/monthly spend trends |
| **By Model** | Which models cost the most |
| **By User** | Per-user spending across your org |
| **By API Key** | Per-application cost attribution |
| **By Custom Field** | Group by any `X-Requesty-*` header or request metadata field |
| **Savings** | Dollars saved through caching, cache hit rate, per-model savings |
| **Projected Spend** | Estimated end-of-period costs |

### Programmatic Cost Attribution

Tag requests with metadata for granular tracking:

```python
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",
    messages=[...],
    extra_body={
        "requesty": {
            "auto_cache": True
        }
    },
    extra_headers={
        "X-Requesty-Agent": "support-bot",
        "X-Requesty-Environment": "production",
        "X-Requesty-Team": "platform"
    }
)
# Cost is in the response
print(f"This request cost: ${response.usage.cost:.6f}")
```

## Quick Wins Checklist

- [ ] Enable `auto_cache: true` on all requests with large system prompts
- [ ] Set per-key spend limits to prevent runaway costs
- [ ] Use `deepseek/deepseek-chat` or `openai/gpt-5-nano` for non-critical tasks
- [ ] Create a cost-tiered fallback policy (cheap model first → premium backup)
- [ ] Check the Savings tab — if savings < 20%, you're missing caching opportunities
- [ ] Add `X-Requesty-*` headers to identify which agents/features cost the most
- [ ] Review the "By Model" breakdown monthly and switch expensive low-value models

## Links

- Analytics dashboard: https://app.requesty.ai/analytics
- Auto caching docs: https://docs.requesty.ai/features/auto-caching
- Cost tracking docs: https://docs.requesty.ai/features/cost-tracking
- Spend limits docs: https://docs.requesty.ai/features/api-limits
- BYOK docs: https://docs.requesty.ai/features/bring-your-own-keys
- Analytics headers docs: https://docs.requesty.ai/features/analytics-headers
