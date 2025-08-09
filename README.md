# MIDI2 Reader — Human & Machine-Readable MIDI 2.0 Spec Viewer (macOS)

**MIDI2 Reader** is a macOS app (SwiftUI + PDFKit) that lets you browse official MIDI 2.0 specification PDFs in two synchronized ways:

* **Facsimile (source of truth)** — page-perfect PNG renders of each PDF page.
* **Readable** — navigable Markdown with stable anchors, collapsible ToC, and (when detected) Markdown tables.

Every section in the Readable view links back to the exact page region in the Facsimile view for verification. No OCR; wording is preserved verbatim.

---

## Who is this for?

* Developers implementing MIDI 2.0 or specific features.
* Readers who need exact, citable passages with fast navigation.
* Tooling authors who want machine-readable exports (Markdown + JSON).

---

## Features

* **Open multiple PDFs** (File → *Open PDFs…*).
* **Export Site**: generates per-document output under a folder you choose:

  * `facsimile/` — page PNGs + `facsimile.html` (deep-link anchors).
  * `index.md` — Markdown with **explicit anchors** (GitHub-friendly).
  * `specdoc.json` — structure and span metadata (for automation).
  * `provenance.json` + `QA.md` — integrity and coverage notes.
* **Verbatim text only** — no paraphrasing.
* **(Planned)** table extraction from ruled grids (Markdown output).
* **(Planned)** in-app search with jump-to selection.

> The app uses **PDFKit** and does not modify the original PDFs.

---

## Install / Build (macOS 13+)

```bash
# from the repo root
cd workspace
swift build -c release
swift run MIDI2SpecReader
```

### Quick use

1. **File → Open PDFs…** and choose your MIDI 2.0 spec PDFs.
2. **Export → Export Site…** to generate the site outputs.
3. Open the generated `index.md` on GitHub (or a Markdown viewer) — the ToC and anchors work, and each section has a 📎 **source** link back to the facsimile.

> If you just want to try a working snapshot immediately:
> `../scripts/use-lesson.sh final && swift build -c release && swift run MIDI2SpecReader`

---

## Outputs at a glance

```
<dest>/
  <DOCID>/
    facsimile/
      page-1.png
      page-2.png
      ...
      facsimile.html
    index.md
    specdoc.json
    provenance.json
  README.md  (index of exported docs)
```

* **Anchors** are explicit (`<a id="...">`) so they work on GitHub.
* 📎 **source** links jump to precise rectangles in `facsimile.html`.

---

## Limitations & roadmap

* Some PDFs extract headings/paragraphs more cleanly than others.
* Tables: ruled-grid detection is stubbed and may need tuning per doc family.
* Planned: search, strict mode for CI, and per-section file splitting.

---

## Contributing / Development

The repository ships with a **staged** layout so real development stays separate from reference snapshots and tutorials. See **DEVELOPING.md**.
