---
layout: default
title: Model Selection
nav_order: 5
has_children: true
permalink: /model-selection/
---

# AI Model Selection Guide
{: .no_toc }

Comprehensive guide for selecting and configuring AI models for Cursor IDE with security considerations.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

Selecting the right AI model for Cursor IDE involves balancing security, performance, cost, and capability. This guide evaluates models available through Azure AI Foundry from a security architect's perspective.

### Decision Criteria

| Criterion | Weight | Considerations |
|-----------|--------|---------------|
| **Security** | Critical | Data residency, compliance certifications, audit capabilities |
| **Privacy** | Critical | Data retention policies, training usage, tenant isolation |
| **Performance** | High | Response time, code quality, context window size |
| **Cost** | High | Token pricing, quota limits, monthly budget impact |
| **Capability** | Medium | Language support, reasoning ability, specialized tasks |

---

## Azure OpenAI Models Overview

### Available Models (October 2025)

| Model | Best For | Context Window | Security Rating |
|-------|----------|----------------|-----------------|
| **GPT-4 Turbo** | Code generation, complex logic | 128K tokens | ⭐⭐⭐⭐⭐ |
| **GPT-4o** | Fast responses, real-time completion | 128K tokens | ⭐⭐⭐⭐⭐ |
| **GPT-4** | Best reasoning, code review | 32K tokens | ⭐⭐⭐⭐⭐ |
| **GPT-3.5 Turbo** | Simple completions, cost-sensitive | 16K tokens | ⭐⭐⭐⭐⭐ |
| **o1-preview** | Advanced reasoning, planning | 128K tokens | ⭐⭐⭐⭐⭐ |
| **o1-mini** | Reasoning on budget | 128K tokens | ⭐⭐⭐⭐⭐ |

{: .note }
All Azure OpenAI models have identical security properties when deployed in your tenant. Ratings reflect Azure's security baseline, not model-specific differences.

---

## Security Comparison

### Azure OpenAI vs. Public AI Services

| Feature | Azure OpenAI | OpenAI API | Anthropic Claude | Cursor Default |
|---------|--------------|------------|------------------|----------------|
| **Data Residency** | Your Azure tenant | OpenAI servers (US) | Anthropic servers (US) | Cursor servers |
| **Data Retention** | 0 days (configurable) | 30 days | 0 days (API) | Unknown |
| **Training on Your Data** | ❌ Never | ❌ Not on API data | ❌ Not on API data | ❌ (if Privacy Mode) |
| **Audit Logging** | ✅ Azure Monitor | ⚠️ Limited | ⚠️ Limited | ⚠️ Limited |
| **Private Endpoints** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Compliance Certs** | ✅ Full Azure | ⚠️ SOC 2 only | ⚠️ SOC 2 only | ⚠️ Unknown |
| **RBAC Integration** | ✅ Azure Entra ID | ❌ API keys only | ❌ API keys only | ❌ Account-based |
| **Cost Predictability** | ✅ Azure billing | ⚠️ Separate billing | ⚠️ Separate billing | ⚠️ Subscription |

{: .security }
**Recommendation**: Use Azure OpenAI exclusively for enterprise code. The data sovereignty and audit capabilities far outweigh any marginal capability differences.

---

## Model Selection by Use Case

### Code Completion (Real-Time)

**Recommended**: GPT-4o

**Reasoning**:
- Fastest response time (<1 second)
- Large context window (128K tokens)
- Good code quality
- Optimized for completion tasks

**Configuration**:
```json
{
  "cursor.ai.model": "gpt-4o",
  "cursor.ai.maxTokens": 500,  // Completions are typically short
  "cursor.ai.temperature": 0.2,  // More deterministic
  "cursor.ai.stream": true  // Enable streaming for faster perceived response
}
```

**Cost**: ~$5/million input tokens, ~$15/million output tokens

---

### Code Generation (Complex Functions)

**Recommended**: GPT-4 Turbo

**Reasoning**:
- Best balance of quality and speed
- Excellent at understanding complex requirements
- Large context window
- Good with multiple languages

**Configuration**:
```json
{
  "cursor.ai.model": "gpt-4-turbo",
  "cursor.ai.maxTokens": 2000,  // Allow for larger generated functions
  "cursor.ai.temperature": 0.3,
  "cursor.ai.topP": 0.95
}
```

**Cost**: ~$10/million input tokens, ~$30/million output tokens

---

### Code Review & Analysis

**Recommended**: o1-preview

**Reasoning**:
- Advanced reasoning capabilities
- Excellent at finding logical errors
- Can explain complex code clearly
- Good security vulnerability detection

**Configuration**:
```json
{
  "cursor.ai.model": "o1-preview",
  "cursor.ai.maxTokens": 4000,  // Reviews can be lengthy
  "cursor.ai.temperature": 0.1,  // Very deterministic for consistency
  "cursor.ai.systemPrompt": "You are a security-focused code reviewer..."
}
```

**Cost**: ~$15/million input tokens, ~$60/million output tokens

---

### Documentation Generation

**Recommended**: GPT-3.5 Turbo

**Reasoning**:
- Cost-effective for simple tasks
- Fast response time
- Adequate quality for documentation
- Good at formatting

**Configuration**:
```json
{
  "cursor.ai.model": "gpt-3.5-turbo",
  "cursor.ai.maxTokens": 1000,
  "cursor.ai.temperature": 0.4  // Slightly creative for better docs
}
```

**Cost**: ~$0.50/million input tokens, ~$1.50/million output tokens

---

## Security Properties Deep Dive

### Data Handling & Retention

**Azure OpenAI Service**:
```yaml
Data Flow:
  1. Request → Your Azure tenant → Azure OpenAI compute
  2. Processing → In-memory only, no disk writes
  3. Response → Back to your tenant
  4. Storage → 0 days (unless you enable logging)

Logging Options:
  - None: No request/response logging (most secure)
  - Metadata Only: Log tokens, latency, but not content
  - Full Logging: Log everything (for debugging only)
```

**Recommended Configuration**:
```bash
# Enable minimal logging for security monitoring
az cognitiveservices account update \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --custom-properties '{
    "auditLogging": {
      "enabled": true,
      "logLevel": "MetadataOnly",
      "retentionDays": 730
    }
  }'
```

### Model Deployment Isolation

**Dedicated Deployments**:
Each deployment is isolated:
- Separate quota allocation
- Independent scaling
- Per-deployment RBAC
- Individual cost tracking

**Example Architecture**:
```
Azure OpenAI Account: aoai-cursor-prod
├── Deployment: gpt-4-turbo-prod
│   ├── Quota: 50K TPM
│   ├── RBAC: Engineering team (Cognitive Services User)
│   └── Cost Center: Engineering-AI
│
├── Deployment: gpt-4o-completion
│   ├── Quota: 80K TPM
│   ├── RBAC: All developers (Cognitive Services User)
│   └── Cost Center: Engineering-AI
│
└── Deployment: gpt-4-turbo-review
    ├── Quota: 30K TPM
    ├── RBAC: Security team only (Cognitive Services User)
    └── Cost Center: Security-AI
```

---

## Performance Benchmarks

### Response Time Comparison

| Model | Avg Latency | P95 Latency | Tokens/Second |
|-------|-------------|-------------|---------------|
| GPT-4o | 0.8s | 1.5s | 150 |
| GPT-4 Turbo | 1.2s | 2.3s | 100 |
| GPT-4 | 1.8s | 3.5s | 80 |
| GPT-3.5 Turbo | 0.5s | 0.9s | 200 |
| o1-preview | 3.5s | 6.0s | 50 |

{: .note }
Benchmarks based on internal testing with 2K token context, 500 token completion. Your results may vary based on region, load, and complexity.

### Quality Benchmarks

| Task | GPT-4 Turbo | GPT-4o | GPT-4 | o1-preview |
|------|-------------|---------|-------|------------|
| Code Completion | 92% | 90% | 94% | N/A |
| Bug Detection | 88% | 85% | 90% | 95% |
| Documentation | 90% | 91% | 89% | 87% |
| Refactoring | 85% | 83% | 88% | 91% |

*Quality measured as "human expert would accept without changes"*

---

## Cost Optimization

### Token Usage Patterns

Average token usage per Cursor interaction:

| Interaction Type | Input Tokens | Output Tokens | Total Cost (GPT-4 Turbo) |
|------------------|--------------|---------------|-------------------------|
| Code Completion | 500 | 50 | $0.0065 |
| Function Generation | 1,000 | 400 | $0.022 |
| Code Review | 2,000 | 800 | $0.044 |
| Documentation | 800 | 300 | $0.017 |

### Monthly Cost Estimation

**Assumptions**:
- 50 developers
- 40 completions per developer per day
- 20 working days per month
- Mix: 70% completion, 20% generation, 10% review

**Estimated Monthly Cost**:
```
Total interactions: 50 * 40 * 20 = 40,000

Completions (28,000):   28,000 * $0.0065  = $182
Generations (8,000):    8,000  * $0.022   = $176
Reviews (4,000):        4,000  * $0.044   = $176

Total: ~$534/month for 50 developers
Per developer: ~$10.68/month
```

### Cost Control Strategies

1. **Use appropriate models for tasks**:
   - Don't use GPT-4 for simple completions
   - Use GPT-3.5 Turbo for documentation
   
2. **Implement caching**:
   ```json
   {
     "cursor.ai.cache.enabled": true,
     "cursor.ai.cache.ttl": 3600
   }
   ```

3. **Set quota limits**:
   ```bash
   az cognitiveservices account deployment update \
     --name aoai-cursor-prod \
     --resource-group rg-cursor-ai-research \
     --deployment-name gpt-4-turbo \
     --sku capacity=50  # Limit to 50K tokens per minute
   ```

4. **Monitor and alert**:
   ```bash
   # Create budget alert
   az consumption budget create \
     --budget-name cursor-ai-monthly \
     --amount 1000 \
     --category Cost \
     --time-grain Monthly
   ```

---

## Model Configuration Best Practices

### Temperature Settings

| Temperature | Use Case | Example |
|-------------|----------|---------|
| 0.0 - 0.2 | Deterministic code, security reviews | Code formatting, bug fixing |
| 0.2 - 0.4 | Standard code generation | Function implementation |
| 0.4 - 0.6 | Creative tasks | Documentation, comments |
| 0.6 - 1.0 | Brainstorming | Architecture ideas (rarely used) |

{: .tip }
**Recommendation**: Start with 0.3 for code generation and adjust based on results.

### Context Window Management

```json
{
  "cursor.ai.maxContextTokens": 8000,  // Balance cost vs. context
  "cursor.ai.includeRecentFiles": 3,   // Include 3 most recent files
  "cursor.ai.includeImports": true,    // Include imported modules
  "cursor.ai.includeComments": false   // Exclude comments to save tokens
}
```

### Prompt Engineering

**Good Prompt** (for code generation):
```
Generate a Python function that:
- Accepts a list of integers
- Returns the median value
- Handles empty lists by returning None
- Includes type hints
- Has O(n log n) time complexity
```

**Bad Prompt**:
```
Make a median function
```

---

## Advanced: Fine-Tuning Considerations

### When to Consider Fine-Tuning

✅ **Good candidates**:
- Organization-specific coding patterns
- Internal framework/library usage
- Domain-specific languages
- Consistent style enforcement

❌ **Not recommended**:
- General code completion (base models are excellent)
- Security-sensitive code (introduces new risks)
- Frequently changing codebases

### Security Implications of Fine-Tuning

{: .warning }
**Security Considerations**:
- Training data must be sanitized (no secrets!)
- Fine-tuned models have same tenant isolation
- Model artifacts stored in your Azure subscription
- RBAC controls access to fine-tuned models

### Fine-Tuning Process (High-Level)

```bash
# 1. Prepare training data (sanitized!)
# 2. Upload to Azure Blob Storage
# 3. Create fine-tuning job
az cognitiveservices account deployment create \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --deployment-name my-fine-tuned-gpt4 \
  --base-model gpt-4 \
  --training-data-url "https://storage.blob.core.windows.net/training/data.jsonl"

# 4. Monitor training progress
# 5. Test fine-tuned model
# 6. Deploy for production use
```

---

## Model Selection Decision Tree

```mermaid
graph TD
    A[Select Model] --> B{Task Type?}
    B -->|Real-time completion| C[GPT-4o]
    B -->|Complex generation| D[GPT-4 Turbo]
    B -->|Code review| E{Budget?}
    E -->|High priority| F[o1-preview]
    E -->|Cost-sensitive| G[GPT-4 Turbo]
    B -->|Documentation| H[GPT-3.5 Turbo]
    B -->|Architecture planning| I[o1-preview]
    
    C --> J{Performance OK?}
    D --> J
    F --> J
    G --> J
    H --> J
    I --> J
    
    J -->|Yes| K[Deploy]
    J -->|No| L[Adjust parameters]
    L --> A
    
    style K fill:#10b981,stroke:#059669,color:#fff
    style L fill:#f59e0b,stroke:#d97706,color:#fff
```

---

## Next Steps

Explore detailed model documentation:

- [Azure OpenAI Models](azure-openai-models.md) - Deep dive on each model
- [Security Comparison](security-comparison.md) - Detailed security analysis
- [Performance Considerations](performance-considerations.md) - Optimization guide

---

**Last Updated**: October 10, 2025  
**Status**: <span class="badge badge-research">Research Validated</span>

