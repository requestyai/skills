# Requesty Features

## Intelligent Routing

Route requests across 30+ providers through one API endpoint.

- **Fallback policies**: Automatic failover chains. If model A fails, try model B, then C.
- **Load balancing**: Weighted traffic distribution across models.
- **Latency routing**: Automatically picks the fastest available model.
- **Cost routing**: Routes to the cheapest model that meets requirements.

Create policies at https://app.requesty.ai/routing-policies.
Use `model="policy/your-policy-name"` in requests.

## Prompt Caching

Automatic response caching reduces costs by up to 90%.

```python
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-20250514",
    messages=messages,
    extra_body={"requesty": {"auto_cache": True}}
)
```

Caching works by hashing the prompt prefix. Repeated conversations with the same system prompt hit the cache.

## Observability

Real-time dashboards at https://app.requesty.ai/analytics:

- Cost per model, user, team, API key
- Latency percentiles (P50/P90/P95/P99)
- Error rates and status code distribution
- Token usage and cache savings
- Tool call analytics

### Custom analytics headers

Tag requests with metadata for filtering:

```python
response = client.chat.completions.create(
    model="openai/gpt-4.1",
    messages=messages,
    extra_headers={
        "X-Requesty-Branch": "feat/new-feature",
        "X-Requesty-User": "alice",
        "X-Requesty-Team": "platform"
    }
)
```

## Enterprise Governance

- **RBAC**: Role-based access control across all features
- **Approved models**: Organization-level model whitelists
- **Access lists**: Per-key or per-group model restrictions
- **Spend limits**: Budget caps per API key, group, or user
- **Guardrails**: PII detection, prompt injection blocking, content filtering
- **Audit logs**: Full request/response logging with session reconstruction

## MCP Gateway

Connect AI coding tools to MCP servers through Requesty:

- Unified gateway for Claude Code, Cursor, Roo Code
- Per-user API key management for MCP access
- Usage analytics for MCP servers
- Server management dashboard

Docs: https://docs.requesty.ai/features/mcp-gateway

## Supported Capabilities

| Feature | Endpoint | Notes |
|---------|----------|-------|
| Chat completions | POST /v1/chat/completions | OpenAI-compatible |
| Responses API | POST /v1/responses | OpenAI Responses format |
| Messages API | POST /v1/messages | Anthropic-compatible |
| Streaming | All inference endpoints | SSE format |
| Function calling | Chat completions | Tool use support |
| Structured outputs | Chat completions | JSON schema enforcement |
| Embeddings | POST /v1/embeddings | Multiple providers |
| Image generation | POST /v1/images/generations | DALL-E, Stable Diffusion |
| Image editing | POST /v1/images/edits | Inpainting support |
| Text to speech | POST /v1/audio/speech | Multiple voices |
| Transcription | POST /v1/audio/transcriptions | Whisper-compatible |
| Vision | Chat completions | Image input support |
| PDF support | Chat completions | Document analysis |
| Web search | Chat completions | Real-time information |
| Reasoning | Chat completions | Extended thinking tokens |

## Data Privacy

- **Zero Data Retention (ZDR)**: Available for all providers
- **EU routing**: Frankfurt-based endpoints for GDPR compliance
- **SOC2/GDPR/HIPAA**: Compliance certifications
- **BYOK**: Your provider keys, your data policies
