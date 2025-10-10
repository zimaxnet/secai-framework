---
layout: default
title: LaunchDarkly Feature Flags
parent: DevOps & Testing Tools
nav_order: 3
---

# LaunchDarkly - Feature Flag Management Platform
{: .no_toc }

Analysis of LaunchDarkly and its role in safe deployment of Cursor + Azure AI Foundry features.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

**LaunchDarkly** is a feature management platform that enables teams to deploy code separately from feature releases using feature flags. This allows safe, gradual rollouts and instant kill switches for problematic features.

### Company Information

| | |
|---|---|
| **Company** | LaunchDarkly, Inc. |
| **Founded** | 2014 |
| **Headquarters** | Oakland, CA |
| **Founders** | Edith Harbaugh (CEO), John Kodumal (CTO) |
| **Website** | [https://launchdarkly.com](https://launchdarkly.com) |
| **Status** | Private (unicorn, $2B+ valuation) |
| **Notable** | Pioneer in feature flag SaaS |

---

## Core Capabilities

### 1. Feature Flags

**Gradual Rollout Example**:
```typescript
// Gradually enable Azure OpenAI GPT-4o
import { LDClient } from 'launchdarkly-node-server-sdk';

const ldClient = LDClient.init(process.env.LAUNCHDARKLY_SDK_KEY);

async function getAIModel(user) {
  const useGPT4o = await ldClient.variation(
    'use-gpt4o-model',  // Flag key
    { key: user.id, email: user.email },  // User context
    false  // Default (if flag service down)
  );
  
  if (useGPT4o) {
    return 'gpt-4o';  // New, faster model
  } else {
    return 'gpt-4-turbo';  // Stable, proven model
  }
}

// Rollout strategy in LaunchDarkly dashboard:
rollout = {
  week_1: "5% of users (engineering team)",
  week_2: "25% of users",
  week_3: "50% of users",
  week_4: "100% of users (if no issues)"
}

// If issues detected: Instant rollback (click button)
```

### 2. Kill Switches

**Emergency Feature Disable**:
```javascript
// Azure OpenAI integration with kill switch
const aiEnabled = await ldClient.variation('azure-openai-enabled', user, true);

if (!aiEnabled) {
  // Fall back to manual code completion
  return { suggestion: null, source: 'disabled' };
}

// If Azure OpenAI has issues:
// 1. Security team disables flag in LaunchDarkly
// 2. All users immediately fall back to non-AI mode
// 3. No code deployment needed
// 4. Fix issue
// 5. Re-enable flag

Time to disable: 10 seconds (vs hours for code deployment)
```

### 3. Targeting & Segmentation

**User-Based Feature Control**:
```yaml
# LaunchDarkly targeting rules
flag: "enable-cursor-ai-chat"

rules:
  - name: "Enable for internal employees only"
    clauses:
      - attribute: email
        op: endsWith
        values: ["@company.com"]
    variation: true
    
  - name: "Disable for contractors"
    clauses:
      - attribute: user_type
        op: equals
        values: ["contractor"]
    variation: false
    
  - name: "Enable for security team (testing)"
    clauses:
      - attribute: department
        op: equals
        values: ["Security"]
    variation: true
    rollout:
      percentage: 100

default: false  # Default to disabled
```

### 4. Experimentation

**A/B Testing AI Models**:
```typescript
// Test which AI model performs better
const modelVariation = await ldClient.variation(
  'ai-model-experiment',
  user,
  'control'
);

const metrics = {
  'control': { model: 'gpt-4-turbo', cost: 0.03 },
  'variant-a': { model: 'gpt-4o', cost: 0.015 },
  'variant-b': { model: 'gpt-3.5-turbo', cost: 0.002 }
};

const selectedModel = metrics[modelVariation];

// LaunchDarkly tracks:
// - Completion quality (user accepts rate)
// - Cost per completion
// - Response time
// - Error rate

// After 2 weeks, data shows:
// - gpt-4o: 15% faster, same quality, 50% cheaper
// - Decision: Roll out gpt-4o to everyone
```

---

## Security Benefits

### 1. Safe Deployment of Risky Changes

**Progressive Rollout**:
```
Deploying Azure Private Endpoint (risky change):

Traditional Deployment:
├── Deploy to all users at once
├── If misconfigured: All users broken
├── Rollback: 30+ minutes
└── Impact: 50 developers blocked

With LaunchDarkly:
Week 1: 5% of users (1 flag change)
├── Monitor: Connection success, latency
├── If issues: Disable flag (10 seconds)
└── Impact: 2-3 developers max

Week 2-4: Gradually increase
└── 100% rollout only after validation

Result: Zero production incidents
```

### 2. Compliance & Audit

**Feature Flag Audit Log**:
```json
// LaunchDarkly records every flag change
{
  "timestamp": "2024-10-10T14:32:15Z",
  "user": "security-architect@company.com",
  "action": "flag_updated",
  "flag": "azure-openai-enabled",
  "change": {
    "before": { "enabled": true, "rollout": "100%" },
    "after": { "enabled": false, "rollout": "0%" }
  },
  "reason": "Security incident - temporary disable",
  "approver": "ciso@company.com",
  "ticket": "INC-2024-5678"
}

// Feeds into Chronicle for compliance
```

### 3. Emergency Response

**Instant Feature Disable**:
```
Security Incident: Azure OpenAI Compromise Suspected
Time: 14:32 UTC

Actions:
T+0 min: Security team notified
T+2 min: Disable LaunchDarkly flag: "azure-openai-enabled"
T+2 min: All Cursor instances stop using Azure OpenAI
T+5 min: Investigate compromise
T+30 min: Rotate API keys
T+35 min: Re-enable flag
T+40 min: Validate functionality

Downtime: 38 minutes (vs 2+ hours for code deployment)
```

---

## Pricing

```
LaunchDarkly Pricing:
├── Starter: $50-75/seat/month (10 seats minimum)
├── Pro: $100-125/seat/month
└── Enterprise: $200+/seat/month (custom)

Customer (10 engineering seats):
10 × $100/month = $1,000/month = $12K/year

ROI:
- Prevented production incidents: $500K/year
- Faster feature delivery: $200K/year (efficiency)
- A/B testing optimization: $100K/year
└── ROI: 67x return
```

---

## Resources

- **Website**: [https://launchdarkly.com](https://launchdarkly.com)
- **Documentation**: [https://docs.launchdarkly.com](https://docs.launchdarkly.com)
- **GitHub**: [https://github.com/launchdarkly](https://github.com/launchdarkly)

---

**Last Updated**: October 10, 2025  
**Review Status**: <span class="badge badge-updated">Production Validated</span>

