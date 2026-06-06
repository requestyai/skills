# Requesty API Reference

## Base URLs

| Region | Base URL |
|--------|----------|
| Global | `https://router.requesty.ai/v1` |
| EU (Frankfurt) | `https://router.eu.requesty.ai/v1` |

## Authentication

All requests require a Bearer token in the `Authorization` header.

```
Authorization: Bearer rqy_your_api_key
```

Get your API key at https://app.requesty.ai/api-keys. New accounts receive $10 in free credits.

## Model naming

Models use the format `provider/model`. Examples:
- `openai/gpt-4.1`
- `anthropic/claude-sonnet-4-20250514`
- `google/gemini-2.5-pro`
- `deepseek/deepseek-chat`

Call `GET /v1/models` for the current list of available models.

## Inference Endpoints

### Chat Completions
```
POST /v1/chat/completions
```
OpenAI-compatible chat completions. Supports streaming, function calling, structured outputs.

```json
{
  "model": "openai/gpt-4.1",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello"}
  ],
  "stream": true
}
```

### Responses API
```
POST /v1/responses
```
OpenAI Responses API format.

```json
{
  "model": "openai/gpt-4.1",
  "input": "Tell me a joke"
}
```

### Messages API
```
POST /v1/messages
```
Anthropic Messages API format.

```json
{
  "model": "anthropic/claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "messages": [
    {"role": "user", "content": "Hello"}
  ]
}
```

### Embeddings
```
POST /v1/embeddings
```

```json
{
  "model": "openai/text-embedding-3-small",
  "input": "The quick brown fox"
}
```

### Image Generation
```
POST /v1/images/generations
```

```json
{
  "model": "openai/dall-e-3",
  "prompt": "A sunset over mountains",
  "size": "1024x1024"
}
```

### Text to Speech
```
POST /v1/audio/speech
```

```json
{
  "model": "openai/tts-1",
  "input": "Hello world",
  "voice": "alloy"
}
```

### Transcription
```
POST /v1/audio/transcriptions
```
Multipart form data with an audio file.

### List Models
```
GET /v1/models
```
No authentication required. Returns all available models.

## Management Endpoints

Base URL: `https://api-v2.requesty.ai`

### API Keys
- `GET /v1/manage/apikey` - List all API keys
- `POST /v1/manage/apikey` - Create a new API key
- `GET /v1/manage/apikey/{id}` - Get API key details
- `DELETE /v1/manage/apikey/{id}` - Delete an API key
- `GET /v1/manage/apikey/{id}/usage` - Get usage statistics
- `POST /v1/manage/apikey/{id}/limit` - Update spending limit
- `POST /v1/manage/apikey/{id}/label` - Update labels
- `POST /v1/manage/apikey/{id}/expiry` - Update expiration

### Groups
- `GET /v1/manage/group` - List all groups
- `POST /v1/manage/group` - Create a group
- `GET /v1/manage/group/{id}` - Get group details
- `DELETE /v1/manage/group/{id}` - Delete a group
- `POST /v1/manage/group/{id}/member` - Add member
- `PUT /v1/manage/group/{id}/member` - Update member
- `DELETE /v1/manage/group/{id}/member` - Remove member

### Organization
- `GET /v1/manage/org` - Get organization details
- `GET /v1/manage/org/usage` - Get organization usage
- `GET /v1/manage/org/member` - List organization members

## Error Handling

All errors return JSON:

```json
{
  "error": {
    "origin": "router",
    "message": "Human-readable description"
  }
}
```

`origin` is `"router"` for Requesty errors or `"provider"` for upstream LLM errors.

| Status | Meaning | Retryable |
|--------|---------|-----------|
| 400 | Bad request | No |
| 401 | Missing/empty Authorization header | No |
| 402 | Insufficient balance | No |
| 403 | Invalid token or model blocked by policy | No |
| 404 | Provider/model not supported | No |
| 412 | Monthly spend limit reached | No |
| 429 | Rate limit exceeded | Yes |
| 502 | Upstream provider error | Yes |
| 503 | Provider timeout | Yes |
| 529 | Provider overloaded | Yes |

### Retry strategy

For retryable errors, use exponential backoff with jitter:

```python
import time, random

def call_with_retry(fn, max_retries=3, base_delay=1.0):
    for attempt in range(max_retries + 1):
        try:
            return fn()
        except Exception as e:
            status = getattr(e, 'status_code', 0)
            if status not in (429, 502, 503, 529) or attempt == max_retries:
                raise
            delay = base_delay * (2 ** attempt) + random.uniform(0, 0.5)
            retry_after = getattr(e, 'headers', {}).get('Retry-After')
            if retry_after:
                delay = max(delay, float(retry_after))
            time.sleep(delay)
```

## Routing Policies

Route requests through multiple models with automatic failover:

1. Create a routing policy at https://app.requesty.ai/routing-policies
2. Use `model="policy/your-policy-name"` in requests

Supported strategies:
- **Fallback**: Try models in order, failover on error
- **Load balancing**: Distribute traffic with weighted routing
- **Latency-based**: Route to the fastest available model
- **Cost-based**: Route to the cheapest model for the task

## Cost Optimization

- **Prompt caching**: `extra_body={"requesty": {"auto_cache": True}}` reduces token costs by up to 90%
- **Smart routing**: Automatically sends simple tasks to cheaper models
- **Spend limits**: Set per-key or per-group budget caps
- **BYOK**: Use your own provider keys while keeping Requesty's routing

## Pricing

5% markup on model costs. All features included. $10 free credits on signup.
