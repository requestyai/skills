---
name: requesty-model-discovery
description: Discover, search, compare, and select from 500+ AI models available through Requesty's unified gateway. Use this skill when the user asks about available models, model pricing, context windows, capabilities, provider regions, or wants to compare models side-by-side. Also use when the user says "which model should I use", "cheapest model for X", "find a model that supports vision", "compare Claude vs GPT", "list all Anthropic models", or asks about model availability, EU-hosted models, coding models, or vision/reasoning/tool-calling capabilities through Requesty.
---

# Requesty Model Discovery

Query, search, compare, and select from 500+ AI models across 23+ providers — all accessible through a single OpenAI-compatible API at `https://router.requesty.ai/v1`.

## Prerequisites

A Requesty API key (`rqy_...`). Get one free at https://app.requesty.ai/api-keys — new accounts include $10 in credits.

## Model Object Schema

Every model returned by `GET /v1/models` has these fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | `provider/model-name` (e.g. `anthropic/claude-sonnet-4-5`) |
| `api` | string | API type — currently `chat` for all models |
| `context_window` | int | Maximum input+output tokens |
| `max_output_tokens` | int | Maximum output tokens (0 = provider default) |
| `input_price` | float | Cost per input token in USD |
| `output_price` | float | Cost per output token in USD |
| `cached_price` | float | Cost per cached input token in USD |
| `caching_price` | float | Cost to write to cache per token in USD (only some providers) |
| `supports_vision` | bool | Accepts image inputs |
| `supports_tool_calling` | bool | Function/tool calling support |
| `supports_reasoning` | bool | Extended thinking / chain-of-thought |
| `supports_caching` | bool | Prompt caching support |
| `supports_computer_use` | bool | Computer use / browser control |
| `supports_web_search` | bool | Built-in web search |
| `supports_image_generation` | bool | Can generate images |
| `supports_output_json_object` | bool | JSON mode output |
| `supports_output_json_schema` | bool | Structured output with schema |
| `supports_role_developer` | bool | Developer/system role support |
| `geolocation` | string | `global`, `eu`, `us`, or `sg` |
| `description` | string | Model description |
| `privacy_comments` | string | Data retention notes from provider |
| `data_retention` | bool | Whether provider retains data |
| `data_retention_days` | int | Days of data retention (if applicable) |

**Pricing is per-token in USD.** Multiply by 1,000,000 for per-million-token pricing.

## Providers (23+)

| Provider prefix | Example model | Notes |
|----------------|---------------|-------|
| `anthropic` | `anthropic/claude-sonnet-4-5` | Direct Anthropic API |
| `openai` | `openai/gpt-5.5` | Direct OpenAI API |
| `google` | `google/gemini-2.5-pro` | Direct Google API |
| `bedrock` | `bedrock/claude-sonnet-4-5@us-east-1` | AWS Bedrock (regional `@region` suffix) |
| `vertex` | `vertex/gemini-2.5-pro` | Google Cloud Vertex AI |
| `azure` | `azure/gpt-4.1@swedencentral` | Azure OpenAI (regional `@region` suffix) |
| `deepseek` | `deepseek/deepseek-chat` | DeepSeek direct |
| `xai` | `xai/grok-4` | xAI Grok models |
| `mistral` | `mistral/mistral-large-latest` | Mistral AI |
| `coding` | `coding/claude-sonnet-4-20250514` | Coding-optimized endpoint with regional variants |
| `deepinfra` | `deepinfra/meta-llama/Llama-3.3-70B-Instruct-Turbo` | DeepInfra hosted OSS models |
| `novita` | `novita/meta-llama/llama-3.2-1b-instruct` | Novita AI hosted models |
| `fireworks` | `fireworks/...` | Fireworks AI |
| `groq` | `groq/...` | Groq (ultra-fast inference) |
| `alibaba` | `alibaba/qwen3-max` | Alibaba Qwen models |
| `perplexity` | `perplexity/...` | Perplexity (search-augmented) |
| `nebius` | `nebius/...` | Nebius AI |
| `parasail` | `parasail/...` | ParaSail |
| `minimaxi` | `minimaxi/...` | MiniMaxi |

Models with `@region` suffixes (e.g. `bedrock/claude-sonnet-4-5@eu-central-1`) are hosted in that specific region.

## List All Models

```bash
curl -s https://router.requesty.ai/v1/models \
  -H "Authorization: Bearer $REQUESTY_API_KEY" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for m in sorted(data['data'], key=lambda x: x['id']):
    if not m['id'].startswith('policy/'):
        print(m['id'])
"
```

## Search & Filter Models

```python
from openai import OpenAI
client = OpenAI(base_url="https://router.requesty.ai/v1", api_key="rqy_...")

models = client.models.list()

# Filter by provider
anthropic = [m for m in models.data if m.id.startswith("anthropic/")]

# Filter by capability — access raw dict via model.model_extra or fetch JSON directly
import json, urllib.request
req = urllib.request.Request(
    "https://router.requesty.ai/v1/models",
    headers={"Authorization": "Bearer rqy_..."}
)
data = json.loads(urllib.request.urlopen(req).read())
all_models = [m for m in data["data"] if not m["id"].startswith("policy/")]

# Vision models
vision = [m for m in all_models if m.get("supports_vision")]

# Reasoning models
reasoning = [m for m in all_models if m.get("supports_reasoning")]

# Tool-calling models
tools = [m for m in all_models if m.get("supports_tool_calling")]

# EU-geolocated models
eu = [m for m in all_models if m.get("geolocation") == "eu"]

# Models with caching support
cacheable = [m for m in all_models if m.get("supports_caching")]
```

## Compare Models Side-by-Side

```python
import json, urllib.request

api_key = "rqy_..."
req = urllib.request.Request(
    "https://router.requesty.ai/v1/models",
    headers={"Authorization": f"Bearer {api_key}"}
)
data = json.loads(urllib.request.urlopen(req).read())

targets = ["anthropic/claude-sonnet-4-5", "openai/gpt-5.5", "google/gemini-2.5-pro", "deepseek/deepseek-chat"]
for model in data["data"]:
    if model["id"] in targets:
        inp = (model.get("input_price") or 0) * 1e6
        out = (model.get("output_price") or 0) * 1e6
        cached = (model.get("cached_price") or 0) * 1e6
        ctx = model.get("context_window", 0)
        max_out = model.get("max_output_tokens", 0)
        vision = model.get("supports_vision", False)
        reasoning = model.get("supports_reasoning", False)
        print(f"{model['id']:40s}  in=${inp:>8.3f}/M  out=${out:>8.3f}/M  "
              f"cached=${cached:>7.3f}/M  ctx={ctx:>9,}  max_out={max_out:>6,}  "
              f"vision={vision}  reasoning={reasoning}")
```

## Decision Tree — Picking the Right Model

```
What's your priority?
├── Lowest cost?
│   ├── Need tool calling? → deepseek/deepseek-chat ($0.14/M in, $0.28/M out)
│   ├── Smallest possible? → novita/meta-llama/llama-3.2-1b-instruct ($0.02/M)
│   └── OpenAI ecosystem? → openai/gpt-5-nano ($0.05/M in, $0.40/M out)
├── Best coding quality?
│   ├── Budget OK → anthropic/claude-sonnet-4-5 ($3/M in, $15/M out)
│   ├── Need EU hosting? → coding/claude-sonnet-4-20250514 or bedrock/... @eu-central-1
│   └── Maximum quality → anthropic/claude-opus-4 ($15/M in, $75/M out)
├── Fastest inference?
│   └── Use a latency routing policy (see requesty-routing-policies skill)
├── EU data residency?
│   ├── Azure EU → azure/gpt-4.1@francecentral, azure/gpt-4.1@swedencentral
│   ├── Bedrock EU → bedrock/claude-sonnet-4-5@eu-central-1
│   ├── Vertex EU → vertex/gemini-2.5-pro@europe-west4
│   └── Also use EU base URL: https://router.eu.requesty.ai/v1
└── Need specific capabilities?
    ├── Vision → anthropic/claude-*, openai/gpt-*, google/gemini-*, xai/grok-4
    ├── Web search → anthropic/claude-sonnet-4-5, google/gemini-*
    ├── Computer use → anthropic/claude-sonnet-4-5, anthropic/claude-opus-4
    ├── Reasoning → anthropic/claude-*, openai/o4-mini, google/gemini-2.5-pro
    └── Long context (1M+) → anthropic/claude-sonnet-4-5 (1M), google/gemini-2.5-pro (1M), deepseek/* (1M)
```

> **Prices change frequently.** Always query `GET /v1/models` for current pricing.

## Quick Test

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_..."
)

response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",
    messages=[{"role": "user", "content": "Say hello in one sentence."}],
    max_tokens=50
)
print(response.choices[0].message.content)
# Cost is included in usage object
print(f"Cost: ${response.usage.cost:.6f}")
```

## Links

- Model Library (visual browser): https://app.requesty.ai/model-library
- API Reference: https://docs.requesty.ai/api-reference/endpoint/models-list
- Full Documentation: https://docs.requesty.ai
