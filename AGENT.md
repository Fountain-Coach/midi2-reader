# AGENT.md — macOS PDFKit MIDI 2 Reader (Two-Track)

You are a local coding agent operating in this repository.

## Goal
Build a macOS SwiftUI app and core library that produce a **two-track** representation of MIDI 2.0 specs:
1) **FACSIMILE** (source of truth): page PNG renders and optional span overlays + anchorable `facsimile.html`
2) **READABLE**: navigable Markdown with explicit anchors, collapsible ToC, and ruled-table → Markdown conversion. Every block has a 📎 link to its facsimile region.

## Constraints
- macOS only, **PDFKit**. No OCR.
- Preserve normative wording verbatim.
- Stable numeric anchors (e.g., `2.3.1 → 2-3-1-title`).
- App should open PDFs, show headings, and export a site.

## Implementation Plan
1) **Core (Midi2Core)**: models (`Span`, `Node`, `SpecDoc`), `slugify`, `detectHeading`.
2) **Parser**: PDFKit-based extraction (page.string → lines → Heading/Paragraph). Compute bounding boxes via `PDFSelection` for spans.
3) **Tables**: ruled-grid detection using CGPDFScanner → cell rects → `selection(for:)` → Markdown tables.
4) **Renderer**: `index.md` with collapsible ToC (H1..H3), explicit `<a id>` anchors, 📎 links to facsimile.
5) **Facsimile**: render pages to PNG; `facsimile.html` accepts fragment ids like `#pN-xX-yY-wW-hH` to scroll to a region.
6) **App (SwiftUI)**: sidebar of headings; PDF view; menu actions (Open, Export Site).
7) **Provenance & QA**: write `provenance.json`, `QA.md` with coverage/link checks.
8) **PR flow**: use `scripts/commit_pr.sh` or `scripts/smart_pr.sh` to open contextual PRs.

## Default Pipeline
- `swift build -c release`
- Run app and **Export Site** (or add headless export later).
- Update QA and provenance, open a PR.

## Guardrails
- Work only inside this repo. Ask before running commands.
- Do not install software or fetch networks beyond git/gh.
