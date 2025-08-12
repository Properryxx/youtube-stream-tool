#!/bin/bash

echo "🚀 GitHub Push Helper Script"
echo "=============================="

# Check if we're logged in to GitHub CLI
if ! gh auth status &>/dev/null; then
    echo "❌ Not logged in to GitHub CLI"
    echo ""
    echo "Please run the following commands manually:"
    echo "1. gh auth login"
    echo "2. Select 'GitHub.com'"
    echo "3. Select 'HTTPS'"
    echo "4. Select 'Login with a web browser'"
    echo "5. Follow the browser authentication"
    echo ""
    echo "After authentication, run this script again."
    exit 1
fi

echo "✅ GitHub CLI authenticated"

# Set up git credentials
echo "🔧 Setting up git credentials..."
gh auth setup-git

# Check repository status
echo "📊 Repository status:"
git remote -v
echo ""

# Try to push
echo "📤 Pushing to GitHub..."
if git push -u origin main; then
    echo ""
    echo "🎉 SUCCESS! Your YouTube Stream Tool is now published on GitHub!"
    echo "🌐 Repository URL: https://github.com/Properryxx/youtube-stream-tool"
    echo ""
    echo "Next steps:"
    echo "- Visit your repository to see the modern UI"
    echo "- Check that all badges and links work correctly"
    echo "- Share your project with the community!"
else
    echo ""
    echo "❌ Push failed. Trying alternative methods..."
    
    # Try using token directly
    echo "🔄 Trying with token authentication..."
    git remote set-url origin "https://Properryxx:$(gh auth token)@github.com/Properryxx/youtube-stream-tool.git"
    
    if git push -u origin main; then
        echo "🎉 SUCCESS with token authentication!"
    else
        echo "❌ Still failed. Manual steps required:"
        echo ""
        echo "1. Go to GitHub.com and create a Personal Access Token:"
        echo "   https://github.com/settings/tokens"
        echo "   - Select 'repo' scope"
        echo "   - Copy the token"
        echo ""
        echo "2. Run: git remote set-url origin https://Properryxx:[TOKEN]@github.com/Properryxx/youtube-stream-tool.git"
        echo "   (Replace [TOKEN] with your actual token)"
        echo ""
        echo "3. Run: git push -u origin main"
    fi
fi
