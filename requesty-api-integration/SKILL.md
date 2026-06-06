---
name: requesty-api-integration
description: Comprehensive guide for AI agents to integrate with the Requesty API gateway. Covers discovery, authentication, and usage of all endpoints including Chat Completions (OpenAI format), Messages API (Anthropic format), and Responses API (with web search, PDF, file input). Use this skill when the user asks to call LLMs through Requesty, set up a Requesty API client, route requests to multiple AI providers, compare Requesty endpoints, or build applications using the Requesty gateway. Also use when the user mentions requesty.ai, router.requesty.ai, or asks about model routing, prompt caching, or failover policies through Requesty.
---

# Requesty API Integration

Requesty is a unified AI gateway routing requests to 400+ models from 30+ providers through a single API. OpenAI SDK-compatible. Two lines to switch from OpenAI.

## Authentication

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_your_api_key"  # Get key at https://app.requesty.ai/api-keys
)
```

Keys start with `rqy_`. New accounts get $10 in free credits.

## Base URLs

| Region | URL |
|--------|-----|
| Global | `https://router.requesty.ai/v1` |
| EU (Frankfurt) | `https://router.eu.requesty.ai/v1` |

## Model naming

Format: `provider/model`. Examples: `openai/gpt-4.1`, `anthropic/claude-sonnet-4-20250514`, `google/gemini-2.5-pro`.

## Core endpoints

### Chat Completions (OpenAI format)
```
POST /v1/chat/completions
```

### Responses API (OpenAI format)
```
POST /v1/responses
```
Supports web search (`web_search_preview`), PDF/file input (`input_file`), and computer use.

### Messages API (Anthropic format)
```
POST /v1/messages
```
Supports PDF analysis (base64 and URL), extended thinking (`budget_tokens`), and web search via tools.

### Other endpoints
- `POST /v1/embeddings` - text embeddings
- `POST /v1/images/generations` - image generation
- `POST /v1/images/edits` - image editing
- `POST /v1/audio/speech` - text to speech
- `POST /v1/audio/transcriptions` - speech to text
- `GET /v1/models` - list available models

## Key features

- **Routing policies**: `model="policy/your-policy-name"` for fallback, load balancing, latency routing
- **Prompt caching**: `extra_body={"requesty": {"auto_cache": True}}`
- **Analytics headers**: `X-Requesty-Branch`, `X-Requesty-User`, `X-Requesty-Repo`
- **Spend limits**: Per-key and per-group budget caps
- **BYOK**: Use your own provider API keys through the gateway

## Detailed reference

For full request/response examples, error handling, management API, and advanced features, see:
- `docs/api-reference.md` - all endpoints with examples
- `docs/quickstart.md` - getting started in Python, TypeScript, cURL
- `docs/features.md` - routing, caching, observability, governance

## Links

- Docs: https://docs.requesty.ai
- API Reference: https://docs.requesty.ai/api-reference/inference-apis
- OpenAPI Spec: https://docs.requesty.ai/api-reference/requesty_inference-openapi.json
- Status: https://status.requesty.ai
