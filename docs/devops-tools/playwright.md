---
layout: default
title: Playwright Testing
parent: DevOps & Testing Tools
nav_order: 1
---

# Playwright - Modern End-to-End Testing Framework
{: .no_toc }

Analysis of Playwright and its role in testing security controls in Cursor environments.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

**Playwright** is a modern, open-source testing framework from Microsoft that enables reliable end-to-end testing for web applications. It supports multiple browsers and provides powerful automation capabilities.

### Framework Information

| | |
|---|---|
| **Framework** | Playwright |
| **Developer** | Microsoft |
| **Launched** | 2020 |
| **Language Support** | TypeScript, JavaScript, Python, .NET, Java |
| **Website** | [https://playwright.dev](https://playwright.dev) |
| **License** | Apache 2.0 (Open Source) |
| **Notable** | Built by creators of Puppeteer (Google Chrome team) |

---

## Core Capabilities

### 1. Cross-Browser Testing

**Browser Support**:
- Chromium (Chrome, Edge)
- Firefox
- WebKit (Safari)
- Mobile emulation

### 2. Auto-Wait

**Reliability Feature**:
```typescript
// Playwright automatically waits for elements
await page.click('button#login');  // Waits for button to be clickable
await page.fill('#api-key', apiKey);  // Waits for input to be enabled

// No manual waits needed (vs Selenium)
```

### 3. Security Testing Use Cases

**Test Okta SSO Flow**:
```typescript
// Test authentication for Cursor web portal
import { test, expect } from '@playwright/test';

test('Okta SSO login enforces MFA', async ({ page }) => {
  // 1. Navigate to Cursor portal
  await page.goto('https://cursor.company.com');
  
  // 2. Click SSO login
  await page.click('button:has-text("Sign in with SSO")');
  
  // 3. Enter company domain
  await page.fill('#domain', 'company.com');
  await page.click('#next');
  
  // 4. Redirected to Okta
  await expect(page).toHaveURL(/.*okta\.com.*/);
  
  // 5. Enter credentials
  await page.fill('#username', process.env.TEST_USER);
  await page.fill('#password', process.env.TEST_PASSWORD);
  await page.click('#submit');
  
  // 6. MFA challenge should appear
  await expect(page.locator('text=Verify with Okta')).toBeVisible();
  
  // 7. Complete MFA (using test account)
  await page.click('#push-notification');
  
  // Wait for approval (in test, auto-approve)
  await page.waitForURL('https://cursor.company.com/dashboard');
  
  // 8. Verify logged in
  await expect(page.locator('text=Welcome')).toBeVisible();
});

test('Cannot bypass Okta MFA', async ({ page }) => {
  // Attempt to access dashboard directly
  await page.goto('https://cursor.company.com/dashboard');
  
  // Should redirect to login
  await expect(page).toHaveURL(/.*okta\.com.*/);
  
  // Even with valid session cookie manipulation
  await page.context().addCookies([{
    name: 'session',
    value: 'fake-session-token',
    domain: 'cursor.company.com',
    path: '/'
  }]);
  
  await page.goto('https://cursor.company.com/dashboard');
  
  // Should still redirect (MFA required)
  await expect(page).toHaveURL(/.*okta\.com.*/);
});
```

**Test DLP Blocking**:
```typescript
test('Purview DLP blocks API key in Teams', async ({ page }) => {
  await page.goto('https://teams.microsoft.com');
  
  // Login...
  
  // Try to send Azure OpenAI key in chat
  const fakeApiKey = 'sk-proj-test1234567890abcdef';
  await page.fill('#message-input', `Here's the API key: ${fakeApiKey}`);
  await page.click('#send-button');
  
  // Should see DLP block message
  await expect(page.locator('text=blocked by policy')).toBeVisible({ timeout: 5000 });
  
  // Message should not be sent
  const messages = await page.locator('.message-content').allTextContents();
  expect(messages).not.toContain(fakeApiKey);
});
```

---

## Integration with CI/CD

```yaml
# Azure DevOps pipeline
- task: PowerShell@2
  displayName: 'Run Playwright Security Tests'
  inputs:
    targetType: 'inline'
    script: |
      npm install
      npx playwright install
      npx playwright test --grep @security
      
- task: PublishTestResults@2
  condition: always()
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: '**/test-results.xml'
    failTaskOnFailedTests: true
```

---

## Resources

- **Website**: [https://playwright.dev](https://playwright.dev)
- **Documentation**: [https://playwright.dev/docs/intro](https://playwright.dev/docs/intro)
- **GitHub**: [https://github.com/microsoft/playwright](https://github.com/microsoft/playwright)

---

**Last Updated**: October 10, 2025

