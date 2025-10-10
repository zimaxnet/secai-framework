---
layout: default
title: Cursor IDE Setup
parent: Getting Started
nav_order: 2
---

# Cursor IDE Enterprise Setup
{: .no_toc }

Comprehensive guide for installing and configuring Cursor IDE with enterprise security controls.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Installation Overview

Cursor IDE can be deployed in several modes for enterprise use:

| Deployment Mode | Use Case | Security Level |
|----------------|----------|----------------|
| **Individual License + Privacy Mode** | Small teams, pilot projects | ⭐⭐⭐ Good |
| **Enterprise License + SSO** | Medium organizations | ⭐⭐⭐⭐ Better |
| **Enterprise + MDM Enforcement** | Large enterprises, regulated industries | ⭐⭐⭐⭐⭐ Best |

This guide covers all three modes.

---

## Download and Installation

### Supported Platforms

Cursor supports:
- **macOS**: 10.15 (Catalina) or later
- **Windows**: Windows 10/11 (64-bit)
- **Linux**: Ubuntu 18.04+, Debian 10+, RHEL/CentOS 7+

### Download Cursor

1. **Enterprise License Holders**:
   ```
   Navigate to: https://cursor.com/enterprise/download
   Login with your enterprise credentials
   Download installer for your platform
   ```

2. **Individual/Trial License**:
   ```
   Navigate to: https://cursor.com/download
   Select your platform
   Download installer
   ```

### Installation Steps

#### macOS Installation

```bash
# Download the .dmg file
# Then install via command line (for automation)
hdiutil attach Cursor-*.dmg
cp -R "/Volumes/Cursor/Cursor.app" /Applications/
hdiutil detach "/Volumes/Cursor"

# Verify installation
/Applications/Cursor.app/Contents/MacOS/Cursor --version

# Accept license and grant permissions
xattr -rd com.apple.quarantine /Applications/Cursor.app
```

#### Windows Installation

```powershell
# Download the .exe installer
# Then install silently for automation
Start-Process -FilePath "CursorSetup-x64.exe" -ArgumentList "/S" -Wait

# Verify installation
& "$env:LOCALAPPDATA\Programs\Cursor\Cursor.exe" --version

# Add to PATH for CLI access
$cursorPath = "$env:LOCALAPPDATA\Programs\Cursor"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$cursorPath", "User")
```

#### Linux Installation

```bash
# Download the .AppImage file
wget https://cursor.com/download/linux -O Cursor.AppImage
chmod +x Cursor.AppImage

# Move to /opt for system-wide access
sudo mv Cursor.AppImage /opt/cursor/
sudo ln -s /opt/cursor/Cursor.AppImage /usr/local/bin/cursor

# Verify installation
cursor --version

# Create desktop entry
cat > ~/.local/share/applications/cursor.desktop <<EOF
[Desktop Entry]
Name=Cursor
Exec=/usr/local/bin/cursor
Icon=cursor
Type=Application
Categories=Development;
EOF
```

---

## Initial Configuration

### First Launch Setup

When Cursor first launches:

1. **Account Sign-In**:
   - For Enterprise: Use SSO (Azure Entra ID)
   - For Individual: Create/sign-in to Cursor account

2. **Privacy Mode Prompt**:
   - **IMPORTANT**: Enable Privacy Mode immediately
   - This prevents code from being sent to Cursor's servers

3. **Extension Migration**:
   - Cursor will offer to import VS Code extensions
   - **Security Review Required**: Only import approved extensions

### Enterprise SSO Configuration

For Azure Entra ID integration:

1. Navigate to: **Settings → Account → Sign In**
2. Select **Sign in with SSO**
3. Enter your organization domain: `yourcompany.com`
4. Complete Entra ID authentication flow
5. Verify enterprise license is active

```json
// Expected enterprise license status in settings.json
{
  "cursor.account": {
    "type": "enterprise",
    "organization": "yourcompany.com",
    "licensedUntil": "2026-12-31"
  }
}
```

---

## Privacy Mode Configuration

{: .security }
**CRITICAL SECURITY CONTROL**: Privacy Mode must be enabled before using Cursor for any enterprise work.

### Enabling Privacy Mode

#### Via UI

1. Open Cursor Settings: `Cmd/Ctrl + ,`
2. Navigate to: **Features → Privacy Mode**
3. Toggle **Privacy Mode** to **ON**
4. Verify status: Green checkmark should appear

#### Via Configuration File

```json
// Location: ~/.cursor/settings.json (macOS/Linux)
// Location: %APPDATA%\Cursor\settings.json (Windows)

{
  "cursor.privacyMode": true,
  "cursor.telemetry.disable": true,
  "cursor.analytics.disable": true,
  "cursor.crashReporter.disable": true
}
```

#### Via Command Line (for automation)

```bash
# macOS/Linux
mkdir -p ~/.cursor
cat > ~/.cursor/settings.json <<EOF
{
  "cursor.privacyMode": true,
  "cursor.telemetry.disable": true
}
EOF

# Windows (PowerShell)
$settingsPath = "$env:APPDATA\Cursor"
New-Item -ItemType Directory -Force -Path $settingsPath
@"
{
  "cursor.privacyMode": true,
  "cursor.telemetry.disable": true
}
"@ | Out-File -FilePath "$settingsPath\settings.json" -Encoding utf8
```

### Validating Privacy Mode

Verify Privacy Mode is active:

```bash
# Check settings file
cat ~/.cursor/settings.json | grep privacyMode

# Expected output:
# "cursor.privacyMode": true

# Check network traffic (while using Cursor)
# Should see NO connections to cursor.sh domains (except for license check)
sudo tcpdump -i any -n host cursor.sh
```

{: .warning }
If you see ongoing connections to `api.cursor.sh` or `telemetry.cursor.sh` while Privacy Mode is enabled, contact Cursor support immediately.

---

## AI Model Configuration

### Default Model Settings

Configure which AI model Cursor uses:

```json
{
  "cursor.ai.model": "custom",  // Use custom endpoint (Azure)
  "cursor.ai.endpoint": "https://aoai-cursor-prod.openai.azure.com/",
  "cursor.ai.apiKey": "${AZURE_OPENAI_API_KEY}", // Reference from env var
  "cursor.ai.deploymentName": "gpt-4-turbo",
  "cursor.ai.maxTokens": 4000,
  "cursor.ai.temperature": 0.3  // Lower = more deterministic
}
```

{: .note }
We'll configure the Azure endpoint in the next section. For now, just understand the structure.

### Disabling Default Cursor Models

To prevent accidental use of Cursor's cloud models:

```json
{
  "cursor.ai.fallbackToDefault": false,  // Don't fall back to Cursor's models
  "cursor.ai.allowedModels": ["custom"], // Only allow custom Azure endpoint
  "cursor.ai.blockPublicModels": true    // Block all public AI models
}
```

---

## Extension Management

### Security Baseline for Extensions

Only install extensions from trusted sources:

```json
{
  "extensions.autoCheckUpdates": true,
  "extensions.autoUpdate": false,  // Manual review before updates
  "extensions.ignoreRecommendations": true,
  "extensions.autoApprove": false
}
```

### Recommended Extensions Allowlist

Create an approved extension list:

```json
{
  "cursor.extensions.allowed": [
    "ms-azuretools.vscode-azurefunctions",
    "ms-azuretools.vscode-bicep",
    "ms-vscode.azurecli",
    "github.copilot",  // If using dual AI tools
    "ms-python.python",
    "ms-vscode.powershell",
    "redhat.vscode-yaml",
    "esbenp.prettier-vscode"
  ]
}
```

### Blocking High-Risk Extensions

Extensions to avoid:

- Code execution without sandboxing
- Unrestricted network access
- Telemetry-heavy extensions
- Unmaintained extensions (no updates >6 months)

---

## File Exclusion Configuration

### .cursorignore File

Create a `.cursorignore` file in your workspace root:

```bash
# Secrets and credentials
**/*.env
**/*.env.*
**/secrets/**
**/.secrets/**

# Private keys and certificates
**/*.key
**/*.pem
**/*.p12
**/*.pfx
**/*.cer
**/*.crt

# Configuration with potential secrets
**/config/prod/**
**/config/production/**
**/appsettings.Production.json
**/appsettings.*.json

# Azure-specific
**/.azure/**
**/azureauth.json
**/ServicePrincipal.json

# Build artifacts (performance)
**/node_modules/**
**/bin/**
**/obj/**
**/dist/**
**/build/**
**/.next/**

# Databases and backups
**/*.sql
**/*.bak
**/*.backup
**/data/**
**/backups/**

# Large files (performance)
**/*.log
**/*.zip
**/*.tar.gz
**/*.iso
**/*.dmg

# IDE and OS files
**/.vscode/**
**/.idea/**
**/.DS_Store
**/Thumbs.db
```

### Global Exclusions (All Workspaces)

Configure global exclusions in settings:

```json
{
  "files.exclude": {
    "**/.git": true,
    "**/.svn": true,
    "**/.hg": true,
    "**/CVS": true,
    "**/.DS_Store": true,
    "**/*.env": true,
    "**/*.key": true,
    "**/*.pem": true,
    "**/node_modules": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/bin": true,
    "**/obj": true,
    "**/dist": true
  }
}
```

---

## Workspace Settings Template

### Secure Workspace Configuration

Create `.cursor/workspace.json`:

```json
{
  "name": "Secure Azure Development",
  "description": "Enterprise workspace with Azure AI Foundry",
  "settings": {
    "cursor.privacyMode": true,
    "cursor.telemetry.disable": true,
    "cursor.ai.model": "custom",
    "cursor.ai.endpoint": "${AZURE_OPENAI_ENDPOINT}",
    "cursor.ai.apiKey": "${AZURE_OPENAI_API_KEY}",
    "cursor.ai.deploymentName": "gpt-4-turbo",
    "files.exclude": {
      "**/*.env": true,
      "**/*.key": true,
      "**/.azure/**": true
    },
    "git.ignoreLimitWarning": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": true
    }
  },
  "extensions": {
    "recommendations": [
      "ms-azuretools.vscode-bicep",
      "ms-vscode.azurecli"
    ]
  }
}
```

---

## MDM Enforcement (Enterprise)

### Deploying Cursor via Intune (Windows)

For Microsoft Intune managed devices:

```powershell
# Package Cursor as Win32 app for Intune
# Create detection script: check-cursor-installed.ps1

$cursorPath = "$env:LOCALAPPDATA\Programs\Cursor\Cursor.exe"
if (Test-Path $cursorPath) {
    $version = (Get-Item $cursorPath).VersionInfo.FileVersion
    Write-Host "Installed"
    exit 0
} else {
    exit 1
}

# Create configuration script: configure-cursor-security.ps1
$settingsPath = "$env:APPDATA\Cursor\settings.json"
$settings = @{
    "cursor.privacyMode" = $true
    "cursor.telemetry.disable" = $true
    "cursor.ai.fallbackToDefault" = $false
} | ConvertTo-Json

New-Item -ItemType Directory -Force -Path (Split-Path $settingsPath)
$settings | Out-File -FilePath $settingsPath -Encoding utf8 -Force
```

### Deploying Cursor via Jamf (macOS)

For Jamf managed Macs:

```bash
#!/bin/bash
# install-cursor-enterprise.sh

# Download and install Cursor
curl -L https://cursor.com/download/mac -o /tmp/Cursor.dmg
hdiutil attach /tmp/Cursor.dmg
cp -R "/Volumes/Cursor/Cursor.app" /Applications/
hdiutil detach "/Volumes/Cursor"

# Configure security settings for all users
for user_home in /Users/*; do
    settings_dir="$user_home/.cursor"
    mkdir -p "$settings_dir"
    cat > "$settings_dir/settings.json" <<EOF
{
  "cursor.privacyMode": true,
  "cursor.telemetry.disable": true
}
EOF
    chown -R $(basename "$user_home"):staff "$settings_dir"
done

echo "Cursor enterprise installation complete"
```

---

## Validation & Testing

### Verification Checklist

- [ ] Cursor installed and launches successfully
- [ ] Privacy Mode enabled and verified in settings
- [ ] Enterprise SSO configured (if applicable)
- [ ] Telemetry disabled
- [ ] .cursorignore file created
- [ ] Extension allowlist configured
- [ ] No connections to Cursor's telemetry servers
- [ ] Settings persist after restart

### Testing Privacy Mode

```bash
# Test 1: Check settings file
cat ~/.cursor/settings.json | jq '.["cursor.privacyMode"]'
# Expected: true

# Test 2: Monitor network traffic for 5 minutes while using Cursor
sudo tcpdump -i any -n -w /tmp/cursor-traffic.pcap &
TCPDUMP_PID=$!

# Use Cursor normally for 5 minutes...

sudo kill $TCPDUMP_PID

# Analyze traffic - should NOT see connections to:
# - telemetry.cursor.sh
# - api.cursor.sh (except initial license check)
# - analytics.cursor.sh
tcpdump -r /tmp/cursor-traffic.pcap -n | grep cursor.sh
```

---

## Troubleshooting

### Issue: Privacy Mode Not Persisting

**Symptoms**: Privacy Mode resets to OFF after restart

**Solutions**:
1. Check file permissions on `settings.json`
2. Verify no MDM policy is overriding settings
3. Check for multiple Cursor installations

```bash
# Fix file permissions
chmod 644 ~/.cursor/settings.json

# Check for multiple installations
find / -name "Cursor.app" 2>/dev/null  # macOS
where cursor  # Windows
```

### Issue: Can't Enable Enterprise SSO

**Symptoms**: SSO button greyed out or failing

**Solutions**:
1. Verify enterprise license is active
2. Check organization domain is correct
3. Ensure Entra ID Conditional Access isn't blocking

```bash
# Check license status
cat ~/.cursor/license.json | jq .

# Test Entra ID connectivity
curl -I https://login.microsoftonline.com
```

### Issue: High CPU Usage

**Symptoms**: Cursor consuming excessive CPU

**Solutions**:
1. Disable unused extensions
2. Exclude build directories from indexing
3. Reduce AI model frequency

```json
{
  "cursor.ai.autoComplete": false,  // Disable automatic completions
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true
  }
}
```

---

## Next Steps

With Cursor installed and configured, proceed to:

**→ [Azure AI Foundry Integration](azure-ai-foundry-integration.md)** - Connect Cursor to your Azure OpenAI endpoint

---

**Last Updated**: October 10, 2025  
**Status**: <span class="badge badge-updated">Validated</span>

