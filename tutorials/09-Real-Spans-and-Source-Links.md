# 09 — Real Spans + Source Links to Facsimile

## What to say to Codex
```
Add real span bboxes and facsimile deep-links:

- For each node, compute a PDFSelection and capture its .bounds (PDF points) into Span.bbox; set sha256(text).
- After each heading/paragraph line in index.md, append a small source pin:
  [📎 source](./facsimile/facsimile.html#p<N>-x<X>-y<Y>-w<W>-h<H>)
- Update facsimile.html to accept fragment ids pN-xX-yY-wW-hH and scroll to that rect (JS).

Commit: "feat(spans): real bboxes + facsimile deep-links"
```
## Expected results
- Clicking 📎 opens the facsimile and scrolls to the text region.

## Verify
Try a few headings/paragraphs; link jumps should be accurate.
