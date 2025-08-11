# 🤝 Contributing to YouTube Stream Tool

Thank you for your interest in contributing to YouTube Stream Tool! This document provides guidelines and instructions for contributing to this project.

## 📋 Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:
- Be respectful and inclusive
- Use welcoming and professional language
- Focus on what's best for the community
- Show empathy towards other community members

## 🐛 Reporting Issues

### Before Submitting an Issue

1. **Check existing issues** - Search through existing issues to avoid duplicates
2. **Update dependencies** - Ensure you're using the latest versions of yt-dlp, mpv, and fzf
3. **Test with different videos** - Try multiple YouTube URLs to isolate the problem

### How to Submit an Issue

Include the following information:

```markdown
**Environment:**
- OS: [Ubuntu 22.04, Fedora 38, etc.]
- Shell: [bash, zsh, etc.]
- yt-dlp version: [output of `yt-dlp --version`]
- mpv version: [output of `mpv --version`]
- fzf version: [output of `fzf --version`]

**Steps to Reproduce:**
1. Run `./youtube-stream.sh "URL"`
2. Select quality X
3. Error occurs

**Expected Behavior:**
[What should have happened]

**Actual Behavior:**
[What actually happened]

**Error Output:**
```
[Paste any error messages here]
```

**Additional Context:**
[Any other relevant information]
```

## 💻 Development Setup

### Prerequisites

```bash
# Install development tools
sudo apt install git shellcheck -y

# Install runtime dependencies
sudo apt install mpv ffmpeg fzf python3-pip -y
pip3 install yt-dlp
```

### Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/yourusername/youtube-stream-tool.git
cd youtube-stream-tool

# Add upstream remote
git remote add upstream https://github.com/originaluser/youtube-stream-tool.git
```

## 🔧 Making Changes

### Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow existing code style and patterns
   - Add comments for complex logic
   - Test your changes thoroughly

3. **Test your changes**
   ```bash
   # Test with various YouTube URLs
   ./youtube-stream.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
   
   # Test edge cases
   ./youtube-stream.sh "https://www.youtube.com/watch?v=invalid"
   ```

4. **Check code quality**
   ```bash
   # Run shellcheck for bash best practices
   shellcheck youtube-stream.sh
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

### Commit Message Guidelines

Use conventional commit format:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code formatting
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

Examples:
- `feat: add support for playlist streaming`
- `fix: resolve audio sync issues with video-only formats`
- `docs: update installation instructions`

## 📝 Pull Request Process

### Before Submitting

1. **Update from upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Ensure tests pass**
   - Test with multiple YouTube URLs
   - Verify all quality options work
   - Check error handling

3. **Update documentation**
   - Update README.md if needed
   - Add comments to new code
   - Update help text if applicable

### Pull Request Template

When submitting a PR, include:

```markdown
## 📋 Description
Brief description of changes made.

## 🔧 Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## ✅ Testing
- [ ] Tested with multiple YouTube URLs
- [ ] Verified quality selection works
- [ ] Checked error handling
- [ ] Ran shellcheck

## 📸 Screenshots (if applicable)
[Add screenshots of new features or UI changes]

## 📝 Additional Notes
[Any additional information for reviewers]
```

## 🎯 Feature Requests

### Proposing New Features

1. **Check existing issues** - Look for similar feature requests
2. **Describe the use case** - Explain why this feature would be valuable
3. **Provide implementation ideas** - Suggest how it could work
4. **Consider alternatives** - Discuss other approaches

### Feature Request Template

```markdown
**Feature Description**
A clear description of the feature you'd like to see.

**Use Case**
Describe the problem this feature would solve or the workflow it would improve.

**Proposed Implementation**
How do you think this feature should work?

**Alternatives Considered**
What other approaches have you considered?

**Additional Context**
Any other relevant information, mockups, or examples.
```

## 🔍 Code Style Guidelines

### Bash Scripting Best Practices

- Use `#!/bin/bash` shebang
- Quote variables: `"$variable"`
- Use `[[ ]]` for conditions instead of `[ ]`
- Prefer `$()` over backticks for command substitution
- Use meaningful variable names
- Add error checking for critical operations

### Formatting

- Indent with 4 spaces
- Maximum line length of 100 characters
- Use consistent spacing around operators
- Group related functions together

### Comments

- Add comments for complex logic
- Explain the "why" not just the "what"
- Use `#` for single-line comments
- Use clear section headers:

```bash
#==============================================================================
# VIDEO QUALITY SELECTION
#==============================================================================
```

## 🧪 Testing

### Manual Testing Checklist

- [ ] Script runs without syntax errors
- [ ] Quality selection interface appears correctly
- [ ] Video playback works with different qualities
- [ ] Error messages are helpful and clear
- [ ] Fallback mechanisms work as expected
- [ ] Script handles invalid URLs gracefully

### Test Cases

1. **Valid YouTube URL** - Should show quality options and play video
2. **Invalid URL** - Should show appropriate error message
3. **Restricted video** - Should handle gracefully with fallbacks
4. **Network issues** - Should timeout appropriately
5. **Missing dependencies** - Should show helpful error messages

## 🌟 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Project documentation

## 📞 Getting Help

- **GitHub Discussions** - For general questions and ideas
- **Issues** - For bugs and specific problems
- **Pull Requests** - For code review and collaboration

---

Thank you for contributing to YouTube Stream Tool! 🎉
