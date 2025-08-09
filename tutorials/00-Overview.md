# MIDI2 Reader — Codex-Driven Tutorial Series (Novice → Pro)

You’ll build a **macOS MIDI 2.0 Spec Reader** that produces both:
- a **facsimile** (page renders + span overlays; the source of truth), and
- a **readable** view (anchors, ToC, tables, search) with deep-links back to the facsimile.

We’ll use:
- **GitHub** for repo + PRs (via `gh` CLI)
- **Codex (local)** to *write code, run builds, read errors, iterate, and open PRs*
- **SwiftPM + PDFKit** (macOS-only)

Each lesson includes:
- **Intent** — what you’ll tell Codex (copy/paste)
- **Expected results** — what you should see at the end
- **Verify** — quick checks
- **Gotchas** — common pitfalls

> You can literally copy/paste the “What to say to Codex” blocks. You don’t need to memorize commands.
