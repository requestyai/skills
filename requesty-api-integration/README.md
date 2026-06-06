# Requesty API Integration Skill

A comprehensive guide for AI agents to discover, authenticate with, and use the Requesty API gateway.

Requesty is a unified AI gateway and LLM router for 400+ models. It provides a single OpenAI-compatible API with intelligent routing, caching, failover, observability, and enterprise governance.

## What this skill provides

- API discovery and authentication steps
- All available endpoints with request/response examples
- Error handling and retry strategies
- Model naming conventions
- Routing policy configuration
- Cost optimization techniques

## Quick start

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
```

## Resources

- [Full Documentation](https://docs.requesty.ai)
- [API Reference](https://docs.requesty.ai/api-reference/inference-apis)
- [Quickstart](https://docs.requesty.ai/quickstart)
- [OpenAPI Spec (Inference)](https://docs.requesty.ai/api-reference/requesty_inference-openapi.json)
- [OpenAPI Spec (Management)](https://docs.requesty.ai/api-reference/requesty_management-openapi.json)
