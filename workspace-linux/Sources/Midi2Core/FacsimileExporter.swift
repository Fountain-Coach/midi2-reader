import Foundation

/// Linux facsimile exporter using Poppler + Cairo.
public struct FacsimileExporter {
    /// Render each page of `pdf` to PNG files and emit a `facsimile.html` with
    /// deep‑link rectangles. Coordinates mirror the macOS exporter so anchors
    /// remain stable across platforms.
    /// - Parameters:
    ///   - pdf: Source document.
    ///   - docId: Identifier used for the output folder name.
    ///   - targetRoot: Destination root folder where the doc folder will be
    ///     created.
    ///   - dpi: Rendering resolution (sRGB) in dots-per-inch.
    ///   - pages: Optional 1-based list of pages to render; defaults to all pages.
    public static func export(pdf: PDFDocument, docId: String, to targetRoot: URL, dpi: Double = 220, pages: [Int]? = nil) throws -> URL {
        let docFolder = targetRoot.appendingPathComponent(safeSlug(docId), isDirectory: true)
        let facsimileFolder = docFolder.appendingPathComponent("facsimile", isDirectory: true)
        try FileManager.default.createDirectory(at: facsimileFolder, withIntermediateDirectories: true)

        // Determine page indices (0-based) to render.
        let pageIndices: [Int]
        if let pages = pages, !pages.isEmpty {
            pageIndices = pages
                .filter { $0 > 0 && $0 <= pdf.pageCount }
                .sorted()
                .map { $0 - 1 }
        } else {
            pageIndices = Array(0..<pdf.pageCount)
        }

        var pageEntries: [String] = []
        for i in pageIndices {
            guard let page = pdf.page(at: i) else { continue }
            let fileName = String(format: "p%03d.png", i + 1)
            let outURL = facsimileFolder.appendingPathComponent(fileName)
            try CairoRenderer.render(page: page, to: outURL, dpi: dpi)
            pageEntries.append(fileName)
        }

        // Minimal facsimile.html identical to macOS exporter.
        let html = facsimileHTML(title: docId, pages: pageEntries)
        try html.data(using: .utf8)!.write(to: facsimileFolder.appendingPathComponent("facsimile.html"), options: .atomic)

        return docFolder
    }

    private static func safeSlug(_ s: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let replaced = trimmed.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        var out = String(replaced)
        while out.contains("--") { out = out.replacingOccurrences(of: "--", with: "-") }
        return out.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private static func facsimileHTML(title: String, pages: [String]) -> String {
        var items = pages.enumerated().map { idx, fn in
            let pid = String(format: "p%03d", idx + 1)
            return """
            <li id=\"\(pid)\">
              <h3>Page \(idx + 1)</h3>
              <div class=\"page\">
                <img alt=\"\(pid)\" src=\"\(fn)\" loading=\"lazy\"/>
                <div class=\"hi\" hidden></div>
              </div>
            </li>
            """
        }.joined(separator: "\n")
        if items.isEmpty { items = "<li><em>No pages</em></li>" }
        return #"""
        <!doctype html>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>\#(title) — facsimile</title>
        <style>
        body{font:14px -apple-system,BlinkMacSystemFont,Helvetica,Arial,sans-serif;margin:20px}
        ul{list-style:none;padding:0}
        li{margin:12px 0}
        .page{position:relative;display:inline-block}
        img{max-width:100%;height:auto;box-shadow:0 0 6px rgba(0,0,0,.2)}
        .hi{position:absolute;border:2px solid #e00;background:rgba(255,0,0,.15);pointer-events:none}
        </style>
        <h1>\#(title) — Facsimile</h1>
        <ul>
        \#(items)
        </ul>
        <script>
        function applyHash() {
          const raw = decodeURIComponent(location.hash || '').replace(/^#/, '');
          if (!raw) return;
          const parts = raw.split('-');
          const p = parts[0];
          const li = document.getElementById(p);
          if (!li) return;
          li.scrollIntoView({block:'start'});
          const img = li.querySelector('img');
          const hi = li.querySelector('.hi');
          let x=0,y=0,w=0,h=0; let hasRect=false;
          for (let i=1;i<parts.length;i++) {
            const seg = parts[i];
            if (seg.startsWith('x')) { x = parseFloat(seg.slice(1)); hasRect=true; }
            else if (seg.startsWith('y')) { y = parseFloat(seg.slice(1)); hasRect=true; }
            else if (seg.startsWith('w')) { w = parseFloat(seg.slice(1)); hasRect=true; }
            else if (seg.startsWith('h')) { h = parseFloat(seg.slice(1)); hasRect=true; }
          }
          if (hasRect && img && hi) {
            const scale = img.clientWidth / img.naturalWidth;
            const left = x * scale;
            const top = (img.naturalHeight - y - h) * scale;
            hi.style.left = left + 'px';
            hi.style.top = top + 'px';
            hi.style.width = (w * scale) + 'px';
            hi.style.height = (h * scale) + 'px';
            hi.hidden = false;
          } else if (hi) {
            hi.hidden = true;
          }
        }
        window.addEventListener('hashchange', applyHash);
        window.addEventListener('load', applyHash);
        </script>
        """#
    }

    public enum ExportError: Error { case renderFailed }
}
