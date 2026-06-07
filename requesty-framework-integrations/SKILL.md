---
name: requesty-framework-integrations
description: Integrate Requesty's unified AI gateway with popular frameworks — OpenAI SDK, Anthropic SDK, LangChain, PydanticAI, Vercel AI SDK, LlamaIndex, Haystack, and direct HTTP. Use this skill when the user asks how to connect their framework to Requesty, switch from OpenAI/Anthropic direct to Requesty, use Requesty with LangChain agents, integrate PydanticAI with Requesty, set up Vercel AI SDK with Requesty, or route any OpenAI-compatible SDK through Requesty. Also use when the user asks about base_url configuration, drop-in replacement for OpenAI, or multi-provider access through a single SDK.
---

# Requesty Framework Integrations

Two-line integration with any OpenAI-compatible SDK or framework. Change `base_url` and `api_key` — everything else stays the same. Access 500+ models across 23+ providers through a single endpoint.

## Prerequisites

- Requesty API key (`rqy_...`) — https://app.requesty.ai/api-keys
- Base URL: `https://router.requesty.ai/v1` (global) or `https://router.eu.requesty.ai/v1` (EU)

## Decision Tree — Which Integration?

```
What framework are you using?
├── OpenAI SDK (Python/JS/Go/etc.)
│   └── Change base_url + api_key (2 lines)
├── Anthropic SDK
│   └── Change base_url + api_key (2 lines, use /v1/messages)
├── LangChain
│   └── ChatOpenAI with base_url override
├── PydanticAI
│   └── OpenAIModel with base_url override
├── Vercel AI SDK
│   └── Official @requesty/vercel-ai-sdk-provider
├── LlamaIndex (TypeScript)
│   └── OpenAI class with base_url
├── Haystack
│   └── OpenAIGenerator with base_url
├── Direct HTTP (requests/axios/fetch)
│   └── POST to router.requesty.ai/v1/chat/completions
└── Coding agents (Claude Code, Cursor, Cline, Roo Code, etc.)
    └── See specific integration guides at docs.requesty.ai/integrations
```

## OpenAI SDK (Python)

```python
from openai import OpenAI

# Before (OpenAI direct)
# client = OpenAI(api_key="sk-...")

# After (Requesty — access 500+ models)
client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_..."
)

# Everything works: chat, streaming, tools, structured output, vision, embeddings
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",  # or openai/gpt-5.5, google/gemini-2.5-pro, etc.
    messages=[{"role": "user", "content": "Hello!"}]
)
```

## OpenAI SDK (TypeScript/JavaScript)

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://router.requesty.ai/v1",
  apiKey: "rqy_...",
});

const response = await client.chat.completions.create({
  model: "anthropic/claude-sonnet-4-5",
  messages: [{ role: "user", content: "Hello!" }],
});
```

## Anthropic SDK

```python
import anthropic

client = anthropic.Anthropic(
    base_url="https://router.requesty.ai",  # Note: no /v1 for Anthropic SDK
    api_key="rqy_..."
)

response = client.messages.create(
    model="anthropic/claude-sonnet-4-5",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello!"}]
)
```

## LangChain

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_...",
    model="anthropic/claude-sonnet-4-5",
)

response = llm.invoke("Hello!")

# Works with chains, agents, tools, RAG, etc.
from langchain_core.prompts import ChatPromptTemplate
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("human", "{input}")
])
chain = prompt | llm
result = chain.invoke({"input": "Explain quantum computing"})
```

## PydanticAI

```python
from pydantic_ai import Agent
from pydantic_ai.models.openai import OpenAIModel

model = OpenAIModel(
    "anthropic/claude-sonnet-4-5",
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_...",
)

agent = Agent(model, system_prompt="You are a helpful assistant.")
result = agent.run_sync("Hello!")
print(result.data)
```

## Vercel AI SDK

Requesty has an official Vercel AI SDK provider:

```typescript
import { createRequesty } from "@requesty/vercel-ai-sdk-provider";
import { generateText } from "ai";

const requesty = createRequesty({
  apiKey: "rqy_...",
});

const { text } = await generateText({
  model: requesty("anthropic/claude-sonnet-4-5"),
  prompt: "Hello!",
});
```

Or use the generic OpenAI provider with base URL override:

```typescript
import { createOpenAI } from "@ai-sdk/openai";
import { generateText } from "ai";

const requesty = createOpenAI({
  baseURL: "https://router.requesty.ai/v1",
  apiKey: "rqy_...",
});

const { text } = await generateText({
  model: requesty("anthropic/claude-sonnet-4-5"),
  prompt: "Hello!",
});
```

## LlamaIndex (TypeScript)

```typescript
import { OpenAI } from "llamaindex";

const llm = new OpenAI({
  additionalSessionOptions: {
    baseURL: "https://router.requesty.ai/v1",
  },
  apiKey: "rqy_...",
  model: "anthropic/claude-sonnet-4-5",
});

const response = await llm.chat({
  messages: [{ role: "user", content: "Hello!" }],
});
```

## Haystack

```python
from haystack.components.generators.chat import OpenAIChatGenerator

generator = OpenAIChatGenerator(
    api_base_url="https://router.requesty.ai/v1",
    api_key="rqy_...",
    model="anthropic/claude-sonnet-4-5",
)
```

## Direct HTTP (Python requests)

```python
import requests

response = requests.post(
    "https://router.requesty.ai/v1/chat/completions",
    headers={
        "Authorization": "Bearer rqy_...",
        "Content-Type": "application/json",
    },
    json={
        "model": "anthropic/claude-sonnet-4-5",
        "messages": [{"role": "user", "content": "Hello!"}],
    }
)
data = response.json()
print(data["choices"][0]["message"]["content"])
print(f"Cost: ${data['usage']['cost']:.6f}")
```

## Direct HTTP (JavaScript/Axios)

```javascript
import axios from "axios";

const { data } = await axios.post(
  "https://router.requesty.ai/v1/chat/completions",
  {
    model: "anthropic/claude-sonnet-4-5",
    messages: [{ role: "user", content: "Hello!" }],
  },
  {
    headers: {
      Authorization: "Bearer rqy_...",
      "Content-Type": "application/json",
    },
  }
);
```

## Adding Requesty Features to Any Framework

All features work regardless of which SDK you use:

### Auto Caching

```python
# OpenAI SDK — use extra_body
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",
    messages=[...],
    extra_body={"requesty": {"auto_cache": True}}
)

# Direct HTTP — add to request body
json={"model": "...", "messages": [...], "requesty": {"auto_cache": True}}
```

### Analytics Headers

```python
# Set once on the client, applies to all requests
client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_...",
    default_headers={
        "HTTP-Referer": "https://yourapp.com",
        "X-Title": "My App",
        "X-Requesty-Agent": "my-agent",
    }
)
```

### Routing Policies

```python
# Use policy/ prefix instead of model name — works with any SDK
response = client.chat.completions.create(
    model="policy/my-fallback-chain",
    messages=[...]
)
```

### EU Data Residency

```python
# Switch to EU base URL — everything else stays the same
client = OpenAI(
    base_url="https://router.eu.requesty.ai/v1",
    api_key="rqy_..."
)
```

## Coding Agent Integrations

### Claude Code

```json
// ~/.claude/settings.json (recommended)
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://router.requesty.ai",
    "ANTHROPIC_AUTH_TOKEN": "rqy_...",
    "ANTHROPIC_MODEL": "anthropic/claude-sonnet-4-5"
  }
}
```

Or via environment variables:

```bash
export ANTHROPIC_BASE_URL="https://router.requesty.ai"
export ANTHROPIC_AUTH_TOKEN="rqy_..."
export ANTHROPIC_MODEL="anthropic/claude-sonnet-4-5"
```

Optional analytics wrapper (tracks cost per branch/repo/developer):

```bash
curl -fsSL https://www.requesty.ai/claude/install.sh | bash
```

Guide: https://docs.requesty.ai/integrations/claude-code

### Cline / Roo Code

Select **Requesty** from the API Provider dropdown, paste your API key and model ID. Guide: https://docs.requesty.ai/integrations/cline

### GitHub Copilot (VS Code 1.122+)

Add Requesty as a Custom Endpoint in **Manage Language Models**. BYOK powers chat, tools, and MCP servers. Guide: https://docs.requesty.ai/integrations/github-copilot

### OpenAI Codex

```bash
export OPENAI_BASE_URL="https://router.requesty.ai/v1"
export OPENAI_API_KEY="rqy_..."
codex --model "anthropic/claude-sonnet-4-5"
```

Guide: https://docs.requesty.ai/integrations/openai-codex

## Supported API Endpoints

| Endpoint | Description |
|----------|-------------|
| `POST /v1/chat/completions` | Chat (OpenAI format) — works with all SDKs |
| `POST /v1/messages` | Messages (Anthropic format) |
| `POST /v1/responses` | Responses API (OpenAI Responses format) |
| `POST /v1/embeddings` | Text embeddings |
| `POST /v1/images/generations` | Image generation |
| `POST /v1/images/edits` | Image editing |
| `POST /v1/audio/speech` | Text-to-speech |
| `POST /v1/audio/transcriptions` | Speech-to-text |
| `GET /v1/models` | List all available models |

## Links

- Quickstart: https://docs.requesty.ai/quickstart
- OpenAI SDK guide: https://docs.requesty.ai/frameworks/openai
- LangChain guide: https://docs.requesty.ai/frameworks/langchain
- PydanticAI guide: https://docs.requesty.ai/frameworks/pydantic-ai
- Vercel AI SDK guide: https://docs.requesty.ai/frameworks/vercel-ai-sdk
- LlamaIndex guide: https://docs.requesty.ai/frameworks/llamaindex-ts
- Haystack guide: https://docs.requesty.ai/frameworks/haystack
- Python requests guide: https://docs.requesty.ai/frameworks/requests
- Axios guide: https://docs.requesty.ai/frameworks/axios
- All integrations: https://docs.requesty.ai/integrations
- Claude Code guide: https://docs.requesty.ai/integrations/claude-code
- Cline guide: https://docs.requesty.ai/integrations/cline
- Roo Code guide: https://docs.requesty.ai/integrations/roo-code
- GitHub Copilot guide: https://docs.requesty.ai/integrations/github-copilot
- OpenAI Codex guide: https://docs.requesty.ai/integrations/openai-codex
