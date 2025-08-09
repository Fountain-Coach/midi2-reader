# 01 — Create the GitHub Repo

## Option A: GitHub website (easiest)
1) On github.com, click **New** → Repository name: `midi2-reader` → Private or Public → Create.
2) Copy the repo URL (e.g., `git@github.com:<you>/midi2-reader.git`).

## Option B: GitHub CLI (terminal)
```bash
brew install gh
gh auth login        # pick GitHub.com, HTTPS, open browser
mkdir -p ~/dev/midi2-reader && cd ~/dev/midi2-reader
git init -b main
gh repo create --source=. --public --push --remote=origin  # or --private
```

### Expected results
- A fresh repo called **midi2-reader** with an empty `main` branch.

### Verify
```bash
git remote -v
# should show origin pointing to github.com/<you>/midi2-reader.git
```
