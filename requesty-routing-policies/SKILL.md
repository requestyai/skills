---
name: requesty-routing-policies
description: Build intelligent routing policies for LLM requests — fallback chains, load balancing, and latency-based routing through Requesty's gateway. Use this skill when the user asks about model failover, automatic retries, load balancing AI requests, A/B testing models, latency optimization, routing traffic across providers, creating a fallback chain, or making their AI application more reliable. Also use when the user mentions "policy/", routing policies, provider redundancy, multi-model strategies, or wants to avoid downtime from provider outages.
---

# Requesty Routing Policies

Build intelligent routing that automatically handles failover, load balancing, and latency optimization across 500+ models — no code changes needed beyond swapping the model string to `policy/your-policy-name`.

## Prerequisites

- Requesty API key (`rqy_...`) — https://app.requesty.ai/api-keys
- Policies are created in the dashboard: https://app.requesty.ai/routing-policies

## How Policies Work

Instead of hardcoding a model name, reference a policy:

```python
# Before: single point of failure
model="anthropic/claude-sonnet-4-5"

# After: resilient routing
model="policy/my-policy-name"
```

The router handles retries, failover, and provider selection transparently. Your code sees a normal response — it never knows about the failures.

## Policy Types

### 1. Fallback Chain

Tries models in priority order. If one fails (timeout, rate limit, 5xx), automatically tries the next.

**When to use**: Maximum reliability, cost-tiered strategies, regional failover.

```
Policy: "sonnet-reliable" (Fallback Chain)
1. anthropic/claude-sonnet-4-5            (1 retry)
2. bedrock/claude-sonnet-4-5@eu-central-1 (1 retry)
3. openai/gpt-5.5                         (1 retry)
```

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_..."
)

response = client.chat.completions.create(
    model="policy/sonnet-reliable",
    messages=[{"role": "user", "content": "Hello!"}]
)
# response.model shows which model actually handled the request
```

**Retry mechanics**: Exponential backoff (500ms → 1s → 2s → 4s). Each model gets 0–10 retries. Rate-limit errors (429) get longer delays. Requesty's fallback policies achieve 99.25% eventual success rate vs 85% direct (see https://www.requesty.ai/data/policy-eventual-success-trend-jan-april-2026).

### 2. Load Balancing

Distributes traffic by weight. Ideal for A/B testing, gradual rollouts, cost optimization.

**When to use**: Comparing models with real traffic, gradual migration, spreading rate limits.

```
Policy: "ab-test-coding" (Load Balancing)
- anthropic/claude-sonnet-4-5: 70%
- openai/gpt-5.5:              20%
- google/gemini-2.5-pro:        10%
```

```python
response = client.chat.completions.create(
    model="policy/ab-test-coding",
    messages=[{"role": "user", "content": "Write a Python function..."}]
)
print(response.model)  # shows which model was selected
```

**Sticky routing**: Requests with the same `trace_id` or `user_id` always go to the same model — no mid-conversation model switches.

### 3. Latency-Based Routing

Automatically routes to the fastest provider using real-time performance data.

**When to use**: Latency-sensitive applications, real-time chat, coding agents.

```
Policy: "fastest-sonnet" (Latency)
- anthropic/claude-sonnet-4-5
- bedrock/claude-sonnet-4-5@us-east-1
- bedrock/claude-sonnet-4-5@eu-central-1
```

```python
response = client.chat.completions.create(
    model="policy/fastest-sonnet",
    messages=[{"role": "user", "content": "Quick answer needed!"}]
)
```

**How it works**: Requesty measures both time-to-first-token (TTFT) and output generation speed across all gateway traffic. Uses Thompson Sampling with LogNormal distributions for Bayesian provider selection. Input-size bucketing ensures heavy requests don't skew stats for light ones. Exponential decay weighting (~10 min half-life) adapts within minutes when a provider slows down or recovers.

## Decision Tree

```
What's your goal?
├── Reliability / uptime?
│   └── Fallback Chain
│       ├── Same model, different providers → Regional Failover
│       ├── Cheap first, premium backup → Cost-Tiered
│       └── Cross-provider redundancy → Multi-Provider
├── Compare models with real traffic?
│   └── Load Balancing
│       ├── A/B testing quality → 50/50 split
│       └── Gradual migration → 90/10 → 70/30 → 50/50
└── Fastest response time?
    └── Latency-Based
        ├── Same model across providers → Provider Latency
        └── Any fast model OK → Multi-Model Latency
```

## Common Patterns

### Coding Agent — Maximum Reliability

```
Fallback Chain "coding-agent":
1. anthropic/claude-sonnet-4-5     (1 retry)
2. openai/gpt-5.5                  (1 retry)
3. google/gemini-2.5-pro           (1 retry)
```

### Cost-Optimized Chat

```
Fallback Chain "chat-budget":
1. deepseek/deepseek-chat          (2 retries)  — $0.14/M in
2. openai/gpt-5-nano               (1 retry)    — $0.05/M in
3. anthropic/claude-haiku-4-5      (1 retry)    — $0.80/M in
```

### EU-Compliant

```
Fallback Chain "eu-sonnet":
1. bedrock/claude-sonnet-4-5@eu-central-1  (2 retries)
2. azure/gpt-4.1@swedencentral             (1 retry)
```

Use with `base_url="https://router.eu.requesty.ai/v1"` for full EU data path.

### Model Evaluation

```
Load Balancing "eval-frontier":
- anthropic/claude-sonnet-4-5: 34%
- openai/gpt-5.5:              33%
- google/gemini-2.5-pro:        33%
```

Compare results in analytics: https://app.requesty.ai/analytics (group by model).

## Creating a Policy (Step by Step)

1. Go to https://app.requesty.ai/routing-policies
2. Click **Create Policy**
3. Select type: Fallback Chain, Load Balancing, or Latency
4. Add models and configure (retries for fallback, weights for load balancing)
5. Copy the policy reference: `policy/your-policy-name`
6. Use `model="policy/your-policy-name"` in your code

## Combining with Other Features

Policies compose with every other Requesty feature:

```python
response = client.chat.completions.create(
    model="policy/my-policy",
    messages=[...],
    extra_body={
        "requesty": {"auto_cache": True}  # caching works with policies
    }
)
```

Analytics headers (`X-Requesty-*`) track which model the policy actually selected. Budget limits apply regardless of which model the policy routes to.

## Verifying Your Policy

```python
for i in range(5):
    r = client.chat.completions.create(
        model="policy/your-policy",
        messages=[{"role": "user", "content": "Hello"}],
        max_tokens=10
    )
    print(f"Request {i+1}: model={r.model}, cost=${r.usage.cost:.6f}")
```

For load balancing you'll see different models. For latency routing the fastest provider wins.

## Links

- Create policies: https://app.requesty.ai/routing-policies
- Fallback docs: https://docs.requesty.ai/features/fallback-policies
- Load balancing docs: https://docs.requesty.ai/features/load-balancing-policies
- Latency routing docs: https://docs.requesty.ai/features/latency-routing
- Reliability data: https://www.requesty.ai/data/policy-eventual-success-trend-jan-april-2026
