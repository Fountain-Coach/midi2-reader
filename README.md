# MIDI2 Reader — macOS SwiftUI App (PDFKit) + Codex Tutorial Pack

This repository is a **single, consolidated workspace** that contains:

- A macOS **SwiftUI app** (SwiftPM) to read MIDI 2.0 specs with:
  - **Facsimile** track (page renders + overlays; source of truth)
  - **Readable** track (anchors, ToC, tables) with deep-links to facsimile
- A full **tutorial series** (novice → pro) tailored to **Codex** usage
- A **kickoff prompt** you can paste into Codex to get moving

> macOS-only (uses PDFKit). No OCR. Parser-only extraction for fidelity.

## Quick Start (build + run)

```bash
swift build -c release
swift run MIDI2SpecReader
```

- **File → Open PDFs…** to load spec PDFs
- **Export → Export Site…** to write Markdown + JSON + facsimile
- See `tutorials/` for step-by-step Codex-driven development

## Pull Requests

We use the GitHub CLI:
```bash
brew install gh
gh auth login
```
Then run the PR scripts from Codex or your shell (see `scripts/`).
