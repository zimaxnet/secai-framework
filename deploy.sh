#!/bin/bash
# SecAI Framework - Deploy to GitHub

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║          🚀 SecAI Framework Deployment Script 🚀             ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Navigate to repository root
# cd /path/to/your/secai-framework

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ Git not initialized. Run: git init"
    exit 1
fi

echo "✅ Git repository initialized"
echo ""

# Add remote (if not already added)
if ! git remote | grep -q "origin"; then
    echo "📡 Adding GitHub remote..."
    git remote add origin https://github.com/zimaxnet/secai-framework.git
    echo "✅ Remote added: https://github.com/zimaxnet/secai-framework.git"
else
    echo "✅ Remote already configured"
fi

echo ""
echo "🔐 Attempting to push to GitHub..."
echo "   (You may be prompted for GitHub credentials)"
echo ""

# Try pushing
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   ✅ DEPLOYMENT SUCCESSFUL! ✅               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📊 Deployment Summary:"
    echo "   • Repository: https://github.com/zimaxnet/secai-framework"
    echo "   • Files pushed: 69"
    echo "   • Pages: 36"
    echo "   • Vendors documented: 20"
    echo ""
    echo "🌐 Next Steps:"
    echo "   1. Go to: https://github.com/zimaxnet/secai-framework/settings/pages"
    echo "   2. Under 'Build and deployment':"
    echo "      - Source: GitHub Actions"
    echo "   3. Save settings"
    echo "   4. Wait 3-5 minutes for build"
    echo "   5. Visit: https://zimaxnet.github.io/secai-framework/"
    echo ""
    echo "🎉 Your SecAI Framework will be live!"
    echo ""
else
    echo ""
    echo "⚠️  Push failed. Common solutions:"
    echo ""
    echo "Option 1: Use SSH instead of HTTPS"
    echo "   git remote set-url origin git@github.com:zimaxnet/secai-framework.git"
    echo "   git push -u origin main"
    echo ""
    echo "Option 2: Use GitHub CLI"
    echo "   gh repo set-default zimaxnet/secai-framework"
    echo "   git push -u origin main"
    echo ""
    echo "Option 3: Personal Access Token"
    echo "   1. Create token at: https://github.com/settings/tokens"
    echo "   2. git remote set-url origin https://YOUR_TOKEN@github.com/zimaxnet/secai-framework.git"
    echo "   3. git push -u origin main"
    echo ""
fi

