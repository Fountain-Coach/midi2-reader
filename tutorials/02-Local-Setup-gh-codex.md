# 02 — Local Setup: gh + Codex + Swift

```bash
# macOS command line tools
xcode-select --install

# GitHub CLI (for PRs)
brew install gh
gh auth login

# Node.js + Codex CLI (local coding agent)
brew install node
npm install -g @openai/codex
codex --version

# SwiftPM is included with Xcode CLTs; verify:
swift --version
```
**Tip:** Keep a dedicated terminal window/tab for Codex sessions.
