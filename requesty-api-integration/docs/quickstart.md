# Requesty Quickstart

## 1. Get an API key

Sign up at https://app.requesty.ai/sign-up (includes $10 free credits).
Create an API key in the dashboard. Keys start with `rqy_`.

## 2. Make your first request

### Python (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_your_api_key"
)

response = client.chat.completions.create(
    model="openai/gpt-4.1",
    messages=[{"role": "user", "content": "Hello"}]
)
print(response.choices[0].message.content)
```

### TypeScript (OpenAI SDK)

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://router.requesty.ai/v1",
  apiKey: "rqy_your_api_key",
});

const response = await client.chat.completions.create({
  model: "anthropic/claude-sonnet-4-20250514",
  messages: [{ role: "user", content: "Hello" }],
});
```

### Python (Anthropic SDK)

```python
import anthropic

client = anthropic.Anthropic(
    base_url="https://router.requesty.ai",
    api_key="rqy_your_api_key"
)

message = client.messages.create(
    model="anthropic/claude-sonnet-4-20250514",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)
```

### cURL

```bash
curl https://router.requesty.ai/v1/chat/completions \
  -H "Authorization: Bearer rqy_your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-4.1",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

## 3. Enable streaming

```python
stream = client.chat.completions.create(
    model="openai/gpt-4.1",
    messages=[{"role": "user", "content": "Write a haiku"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")
```

## 4. Use function calling

```python
response = client.chat.completions.create(
    model="openai/gpt-4.1",
    messages=[{"role": "user", "content": "What's the weather in Paris?"}],
    tools=[{
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {"type": "string"}
                },
                "required": ["location"]
            }
        }
    }]
)
```

## 5. Enable prompt caching

```python
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-20250514",
    messages=[{"role": "user", "content": "Summarize this document..."}],
    extra_body={"requesty": {"auto_cache": True}}
)
```

## 6. EU data residency

For GDPR compliance, use the EU base URL:

```python
client = OpenAI(
    base_url="https://router.eu.requesty.ai/v1",
    api_key="rqy_your_api_key"
)
```

## Next steps

- Browse models: https://app.requesty.ai/model-library
- Set up routing policies: https://docs.requesty.ai/features/fallback-policies
- Configure spend limits: https://docs.requesty.ai/features/api-limits
- Full docs: https://docs.requesty.ai
