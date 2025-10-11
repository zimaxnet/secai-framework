---
layout: default
title: Playwright Testing
parent: Security Tools & Vendors
nav_order: 14
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

**Playwright** is a modern, open-source testing framework from Microsoft that enables reliable end-to-end testing for web applications. It supports multiple browsers and provides powerful automation capabilities essential for validating security controls in Cursor deployments.

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

**Test Azure Firewall Blocking**:
```typescript
test('Azure Firewall blocks unauthorized domains', async ({ page }) => {
  // Configure Playwright to use enterprise proxy
  const browser = await chromium.launch({
    proxy: {
      server: 'http://azure-firewall.company.com:8080'
    }
  });
  
  const context = await browser.newContext();
  const page = await context.newPage();
  
  // Attempt to access blocked domain
  try {
    await page.goto('https://unauthorized-llm-provider.com', { 
      timeout: 5000 
    });
    
    // Should not reach here
    throw new Error('Expected navigation to be blocked');
  } catch (error) {
    // Verify it's a firewall block, not network error
    const content = await page.content();
    expect(content).toContain('Azure Firewall');
    expect(content).toContain('blocked by security policy');
  }
  
  await browser.close();
});
```

**Test RBAC Permissions**:
```typescript
test('Developer role cannot access production secrets', async ({ page }) => {
  // Login as developer
  await loginAsUser(page, 'developer@company.com');
  
  // Navigate to Key Vault
  await page.goto('https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.KeyVault%2Fvaults');
  
  // Try to access production Key Vault
  await page.click('text=keyvault-prod-001');
  
  // Try to view secrets
  await page.click('text=Secrets');
  
  // Should see access denied
  await expect(page.locator('text=Access denied')).toBeVisible();
  await expect(page.locator('text=You do not have permission')).toBeVisible();
});

test('Security admin can access production secrets', async ({ page }) => {
  // Login as security admin
  await loginAsUser(page, 'secadmin@company.com');
  
  // Navigate to Key Vault
  await page.goto('https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.KeyVault%2Fvaults');
  
  // Access production Key Vault
  await page.click('text=keyvault-prod-001');
  
  // View secrets
  await page.click('text=Secrets');
  
  // Should see secret list
  await expect(page.locator('.secret-list')).toBeVisible();
  
  // Audit: Record access
  const secretNames = await page.locator('.secret-name').allTextContents();
  console.log(`Security admin accessed ${secretNames.length} secrets`);
});
```

---

## Integration with CI/CD

### Azure DevOps Pipeline

```yaml
# azure-pipelines.yml
trigger:
  - main
  - develop

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: SecurityTests
  displayName: 'Security Test Automation'
  jobs:
  - job: PlaywrightTests
    displayName: 'Run Playwright Security Tests'
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '18.x'
      displayName: 'Install Node.js'
    
    - script: |
        npm ci
        npx playwright install --with-deps
      displayName: 'Install dependencies'
    
    - script: |
        npx playwright test --grep @security
      displayName: 'Run security tests'
      env:
        TEST_USER: $(TEST_USER)
        TEST_PASSWORD: $(TEST_PASSWORD)
        AZURE_TENANT_ID: $(AZURE_TENANT_ID)
    
    - task: PublishTestResults@2
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/test-results.xml'
        failTaskOnFailedTests: true
      displayName: 'Publish test results'
    
    - task: PublishPipelineArtifact@1
      condition: always()
      inputs:
        targetPath: 'playwright-report'
        artifact: 'playwright-report'
        publishLocation: 'pipeline'
      displayName: 'Publish test report'
```

### GitHub Actions

```yaml
name: Security Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'

jobs:
  security-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - uses: actions/setup-node@v3
      with:
        node-version: 18
    
    - name: Install dependencies
      run: |
        npm ci
        npx playwright install --with-deps
    
    - name: Run security tests
      run: npx playwright test --grep @security
      env:
        TEST_USER: ${{ secrets.TEST_USER }}
        TEST_PASSWORD: ${{ secrets.TEST_PASSWORD }}
        AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    
    - uses: actions/upload-artifact@v3
      if: always()
      with:
        name: playwright-report
        path: playwright-report/
        retention-days: 30
```

---

## Test Organization

### Directory Structure

```
tests/
├── security/
│   ├── authentication/
│   │   ├── okta-sso.spec.ts
│   │   ├── mfa-enforcement.spec.ts
│   │   └── session-management.spec.ts
│   ├── authorization/
│   │   ├── rbac-permissions.spec.ts
│   │   ├── api-authorization.spec.ts
│   │   └── data-access.spec.ts
│   ├── dlp/
│   │   ├── teams-dlp.spec.ts
│   │   ├── email-dlp.spec.ts
│   │   └── api-key-detection.spec.ts
│   ├── network/
│   │   ├── firewall-rules.spec.ts
│   │   ├── allowed-domains.spec.ts
│   │   └── blocked-domains.spec.ts
│   └── monitoring/
│       ├── audit-logging.spec.ts
│       ├── alert-generation.spec.ts
│       └── incident-response.spec.ts
└── playwright.config.ts
```

### Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['junit', { outputFile: 'test-results.xml' }],
    ['list']
  ],
  use: {
    baseURL: process.env.BASE_URL || 'https://cursor.company.com',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  // Security tests
  grep: /@security/,
});
```

---

## Best Practices for Security Testing

### 1. Use Test Accounts

**Never use production credentials**:
```typescript
// ❌ BAD: Using real credentials
const user = 'admin@company.com';
const password = 'RealPassword123!';

// ✅ GOOD: Using dedicated test accounts
const user = process.env.TEST_USER; // testadmin@company.com
const password = process.env.TEST_PASSWORD; // Test environment only
```

### 2. Test Isolation

**Clean state between tests**:
```typescript
test.beforeEach(async ({ page }) => {
  // Clear cookies and storage
  await page.context().clearCookies();
  await page.context().clearPermissions();
  
  // Start fresh
  await page.goto('about:blank');
});

test.afterEach(async ({ page }) => {
  // Logout
  await page.goto('https://cursor.company.com/logout');
});
```

### 3. Security-First Assertions

**Test security controls explicitly**:
```typescript
test('API requires authentication', async ({ request }) => {
  // Attempt to call API without token
  const response = await request.get('/api/v1/models', {
    headers: {
      // No Authorization header
    }
  });
  
  // Should reject
  expect(response.status()).toBe(401);
  
  const body = await response.json();
  expect(body.error).toContain('authentication required');
});
```

### 4. Continuous Monitoring

**Run security tests regularly**:
- After every deployment
- Daily scheduled runs
- Before production releases
- When security policies change

---

## Comparison: Playwright vs Selenium

| Feature | Playwright | Selenium |
|---------|-----------|----------|
| **Auto-wait** | ✅ Built-in | ❌ Manual |
| **Speed** | ⚡ Fast | 🐢 Slower |
| **Browser Support** | Chromium, Firefox, WebKit | All major browsers |
| **Mobile Emulation** | ✅ Built-in | ❌ Requires Appium |
| **Network Interception** | ✅ Native | ❌ Limited |
| **Best For** | Modern apps, new tests | Legacy apps, existing tests |
| **Maturity** | 4 years | 20 years |
| **Learning Curve** | Easy | Moderate |

**When to Use Playwright**:
- New test development
- Modern web applications
- Need network interception
- Fast execution required
- API testing alongside UI tests

**When to Use Selenium**:
- Existing test suites (migration cost high)
- Legacy applications
- Team expertise in Selenium
- Need Java/Ruby support
- Selenium Grid infrastructure already exists

---

## Advanced Security Testing Patterns

### API Request Interception

```typescript
test('Intercept and validate API calls', async ({ page }) => {
  // Listen for Azure OpenAI API calls
  await page.route('https://**.openai.azure.com/**', async route => {
    const request = route.request();
    
    // Verify API key is present
    const apiKey = request.headers()['api-key'];
    expect(apiKey).toBeTruthy();
    expect(apiKey).toMatch(/^[a-f0-9]{32}$/);
    
    // Verify request is logged
    console.log(`API call to: ${request.url()}`);
    console.log(`Headers: ${JSON.stringify(request.headers())}`);
    
    // Allow request to proceed
    await route.continue();
  });
  
  // Perform action that triggers API call
  await page.goto('https://cursor.company.com');
  await page.fill('#prompt', 'Explain this code');
  await page.click('#submit');
  
  // Wait for response
  await page.waitForSelector('.response');
});
```

### Network Condition Testing

```typescript
test('Graceful degradation under network issues', async ({ page, context }) => {
  // Simulate slow network
  await context.route('**/*', route => {
    setTimeout(() => route.continue(), 2000); // 2s delay
  });
  
  await page.goto('https://cursor.company.com');
  
  // Should show loading state
  await expect(page.locator('.loading-spinner')).toBeVisible();
  
  // Should eventually load
  await expect(page.locator('.dashboard')).toBeVisible({ timeout: 10000 });
});

test('Offline mode security', async ({ page, context }) => {
  await page.goto('https://cursor.company.com');
  
  // Go offline
  await context.setOffline(true);
  
  // Attempt to access sensitive data
  await page.click('text=View API Keys');
  
  // Should show offline message, not cached sensitive data
  await expect(page.locator('text=No internet connection')).toBeVisible();
  await expect(page.locator('.api-key')).not.toBeVisible();
});
```

---

## Monitoring and Reporting

### Custom Reporter

```typescript
// custom-reporter.ts
import { Reporter, TestCase, TestResult } from '@playwright/test/reporter';

class SecurityReporter implements Reporter {
  onTestEnd(test: TestCase, result: TestResult) {
    if (test.tags.includes('@security')) {
      console.log(`Security Test: ${test.title}`);
      console.log(`Status: ${result.status}`);
      console.log(`Duration: ${result.duration}ms`);
      
      if (result.status === 'failed') {
        // Alert security team
        this.alertSecurityTeam(test, result);
      }
    }
  }
  
  private alertSecurityTeam(test: TestCase, result: TestResult) {
    // Send to Teams webhook
    fetch(process.env.TEAMS_WEBHOOK_URL!, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        title: '🚨 Security Test Failed',
        text: `${test.title} failed in ${result.duration}ms`,
        sections: [{
          activityTitle: 'Test Details',
          facts: [
            { name: 'Test', value: test.title },
            { name: 'Status', value: result.status },
            { name: 'Error', value: result.error?.message || 'Unknown' }
          ]
        }]
      })
    });
  }
}

export default SecurityReporter;
```

---

## Integration with Security Tools

### CrowdStrike Endpoint Detection

```typescript
test('CrowdStrike detects malicious activity', async ({ page }) => {
  // Perform action that should trigger CrowdStrike
  await page.goto('https://cursor.company.com');
  
  // Attempt to download suspicious file
  const [download] = await Promise.all([
    page.waitForEvent('download'),
    page.click('a[href="/download/suspicious.exe"]')
  ]);
  
  // CrowdStrike should block download
  // Verify in CrowdStrike API
  const csResponse = await fetch('https://api.crowdstrike.com/detects/queries/detects/v1', {
    headers: {
      'Authorization': `Bearer ${process.env.CROWDSTRIKE_API_KEY}`
    }
  });
  
  const detections = await csResponse.json();
  expect(detections.resources.length).toBeGreaterThan(0);
});
```

### Wiz Cloud Security

```typescript
test('Wiz detects misconfigured resources', async () => {
  // Deploy test resource with intentional misconfiguration
  // (in test environment only)
  
  // Wait for Wiz to scan
  await new Promise(resolve => setTimeout(resolve, 60000)); // 1 minute
  
  // Check Wiz API for findings
  const wizResponse = await fetch('https://api.wiz.io/findings', {
    headers: {
      'Authorization': `Bearer ${process.env.WIZ_API_KEY}`
    }
  });
  
  const findings = await wizResponse.json();
  const testFinding = findings.find(f => f.resource.id === 'test-resource-id');
  
  expect(testFinding).toBeTruthy();
  expect(testFinding.severity).toBe('high');
});
```

---

## Resources

### Official Documentation
- **Website**: [https://playwright.dev](https://playwright.dev)
- **Documentation**: [https://playwright.dev/docs/intro](https://playwright.dev/docs/intro)
- **GitHub**: [https://github.com/microsoft/playwright](https://github.com/microsoft/playwright)
- **Discord**: [https://aka.ms/playwright/discord](https://aka.ms/playwright/discord)

### Security Testing Guides
- **OWASP Testing Guide**: [https://owasp.org/www-project-web-security-testing-guide/](https://owasp.org/www-project-web-security-testing-guide/)
- **Microsoft Security Testing**: [https://docs.microsoft.com/security/test](https://docs.microsoft.com/security/test)

### Related Tools
- **[Selenium](selenium.md)** - Industry standard browser automation
- **[Okta](okta.md)** - SSO platform to test against
- **[Veracode](veracode.md)** - Application security scanning

---

**Last Updated**: October 11, 2025  
**Status**: <span class="badge badge-production">Production Validated</span>

