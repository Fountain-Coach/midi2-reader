# 00 — Overview (Staged Workflow)

You’ll build a **macOS MIDI 2.0 Spec Reader** with two synchronized tracks:
- **Facsimile** — page renders + overlays; the immutable source of truth.
- **Readable** — navigable Markdown (anchors, ToC, tables, search) that deep-links back to the facsimile.

**You work only in `workspace/`.**  
`reference/` is read-only: `starter/` (reset point) and `final/` (working example).  
Use `scripts/use-lesson.sh final` to copy the final snapshot into `workspace/` when you want to jump ahead, and `scripts/reset-workspace.sh` to return to the starter.

Every lesson below assumes your shell is at:
```bash
cd workspace
```
