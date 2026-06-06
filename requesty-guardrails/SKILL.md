---
name: requesty-guardrails
description: Configure enterprise-grade security filters for AI requests — PII detection, secret key scanning, and financial data masking through Requesty's guardrails. Use this skill when the user asks about protecting sensitive data in AI requests, blocking PII from reaching LLMs, detecting API keys or credentials in prompts, masking credit card numbers, GDPR compliance for AI, SOC 2 compliance, or content filtering. Also use when the user mentions guardrails, data masking, prompt security, preventing data leaks through AI, or protecting financial information in LLM requests.
---

# Requesty Guardrails

Enterprise-grade security filters that automatically detect and mask sensitive information in both AI requests and responses — PII, credentials, financial data — before they reach any model.

## Prerequisites

- Requesty account with admin access — https://app.requesty.ai
- Guardrails config: https://app.requesty.ai/guardrails

## How Guardrails Work

```
User request → Input scanning → Mask sensitive data → AI model → Output scanning → Mask response → Clean response
```

Guardrails are **bidirectional** — they scan both what you send to the model AND what the model sends back. Sensitive data is masked before it crosses any boundary.

## What Guardrails Detect

### PII (Personally Identifiable Information)

| Data type | Example | Masked as |
|-----------|---------|-----------|
| Social Security Numbers | 123-45-6789 | [SSN REDACTED] |
| Email addresses | user@company.com | [EMAIL REDACTED] |
| Phone numbers | +1-555-123-4567 | [PHONE REDACTED] |
| Names | John Smith | [NAME REDACTED] |
| Personal identifiers | Driver's license, passport numbers | [PII REDACTED] |

### Credentials & Secrets

| Data type | Example | Masked as |
|-----------|---------|-----------|
| API keys | sk-proj-abc123... | [API KEY REDACTED] |
| Database credentials | postgres://user:pass@... | [CREDENTIAL REDACTED] |
| Authentication tokens | Bearer eyJhbGciOi... | [TOKEN REDACTED] |
| Service account keys | JSON key files | [SECRET REDACTED] |

### Financial Information

| Data type | Example | Masked as |
|-----------|---------|-----------|
| Credit card numbers | 4111-1111-1111-1111 | [CARD REDACTED] |
| CVV codes | 123 (in card context) | [CVV REDACTED] |
| Bank account numbers | Account/routing numbers | [BANK REDACTED] |
| Financial data | Investment details, statements | [FINANCIAL REDACTED] |

## Enabling Guardrails

### Step-by-Step

1. Go to https://app.requesty.ai/guardrails
2. Toggle each guardrail type ON/OFF:
   - **PII Protection** — emails, phones, SSNs, names
   - **Secret Keys Protection** — API keys, tokens, credentials
   - **PCI Protection** — credit cards, CVVs, cardholder data
   - **Banking Protection** — account numbers, routing numbers
   - **Financial Data Protection** — investment details, statements
3. Changes apply **immediately** across all API keys in the organization
4. No code changes needed — guardrails are applied at the gateway level

### Key Properties

| Property | Detail |
|----------|--------|
| **Scope** | Organization-wide — applies to every API key |
| **Direction** | Bidirectional — scans inputs AND outputs |
| **Activation** | Instant — no restart or downtime |
| **Code changes** | None — transparent at the gateway layer |
| **Bypass** | No exceptions or bypass mechanisms |

## No Code Changes Required

Guardrails work transparently. Your existing code doesn't change:

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://router.requesty.ai/v1",
    api_key="rqy_..."
)

# Even if the user message contains PII, it's masked before reaching the model
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4-5",
    messages=[
        {"role": "user", "content": "Process this order for John Smith, card 4111-1111-1111-1111"}
    ]
)
# The model never sees the real card number or name
```

## Compliance Coverage

| Standard | How guardrails help |
|----------|-------------------|
| **GDPR** | PII detection prevents personal data from reaching AI models |
| **PCI DSS** | Credit card and payment data automatically masked |
| **SOC 2** | Credential and secret detection prevents exposure |
| **HIPAA** | Personal health identifiers caught by PII filters |

Combine with **EU routing** (`base_url="https://router.eu.requesty.ai/v1"`) for full GDPR data residency.

## Decision Tree

```
What data are you protecting?
├── Personal data (names, emails, SSNs)?
│   └── Enable PII Protection
├── API keys, passwords, tokens?
│   └── Enable Secret Keys Protection
├── Credit cards, payment data?
│   └── Enable PCI Protection
├── Bank accounts, routing numbers?
│   └── Enable Banking Protection
├── Investment data, financial statements?
│   └── Enable Financial Data Protection
└── All of the above (enterprise)?
    └── Enable all guardrails + EU routing
```

## Links

- Configure guardrails: https://app.requesty.ai/guardrails
- Guardrails docs: https://docs.requesty.ai/features/guardrails
- EU routing docs: https://docs.requesty.ai/features/eu-routing
- Data privacy: https://docs.requesty.ai/features/data-privacy
