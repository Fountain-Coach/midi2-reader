import Foundation
import CoreGraphics
#if canImport(ImageIO)
import ImageIO
#endif
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

public struct FacsimileExporter {
#if canImport(ImageIO)
    public static func export(pdf: PDFDocument, docId: String, to targetRoot: URL, dpi: CGFloat = 220) throws -> URL {
        let docFolder = targetRoot.appendingPathComponent(safeSlug(docId), isDirectory: true)
        let facsimileFolder = docFolder.appendingPathComponent("facsimile", isDirectory: true)
        try FileManager.default.createDirectory(at: facsimileFolder, withIntermediateDirectories: true)

        let pageCount = pdf.pageCount
        var pageEntries: [String] = []
        for i in 0..<pageCount {
            guard let page = pdf.page(at: i) else { continue }
            let fileName = String(format: "p%03d.png", i + 1)
            let outURL = facsimileFolder.appendingPathComponent(fileName)
            try render(page: page, to: outURL, dpi: dpi)
            pageEntries.append(fileName)
        }

        // Minimal facsimile.html
        let html = Self.facsimileHTML(title: docId, pages: pageEntries)
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

    private static func render(page: PDFPage, to url: URL, dpi: CGFloat) throws {
        let bounds = page.bounds(for: .mediaBox)
        let scale = dpi / 72.0
        let widthPx = Int((bounds.width * scale).rounded(.toNearestOrAwayFromZero))
        let heightPx = Int((bounds.height * scale).rounded(.toNearestOrAwayFromZero))
        try fallbackRender(page: page, to: url, widthPx: widthPx, heightPx: heightPx, scale: scale)
    }

    private static func fallbackRender(page: PDFPage, to url: URL, widthPx: Int, heightPx: Int, scale: CGFloat) throws {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { throw ExportError.renderFailed }
        guard let bmp = CGContext(
            data: nil,
            width: widthPx,
            height: heightPx,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { throw ExportError.renderFailed }

        let white = CGColor(gray: 1.0, alpha: 1.0)
        bmp.setFillColor(white)
        bmp.fill(CGRect(x: 0, y: 0, width: CGFloat(widthPx), height: CGFloat(heightPx)))
        bmp.scaleBy(x: scale, y: scale)
        page.draw(with: .mediaBox, to: bmp)
        guard let cg = bmp.makeImage() else { throw ExportError.renderFailed }
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw ExportError.renderFailed
        }
        CGImageDestinationAddImage(dest, cg, nil)
        if !CGImageDestinationFinalize(dest) {
            throw ExportError.renderFailed
        }
    }

    private static func facsimileHTML(title: String, pages: [String]) -> String {
        var items = pages.enumerated().map { idx, fn in
            let pid = String(format: "p%03d", idx + 1)
            return """
            <li id="\(pid)">
              <h3>Page \(idx + 1)</h3>
              <div class="page">
                <img alt="\(pid)" src="\(fn)" loading="lazy"/>
                <div class="hi" hidden></div>
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
          const p = parts[0]; // e.g., p003
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
            const top = (img.naturalHeight - y - h) * scale; // PDF->CSS
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

    public enum ExportError: Error { case loadFailed, renderFailed }
#else
    public static func export(pdf: PDFDocument, docId: String, to targetRoot: URL, dpi: CGFloat = 220) throws -> URL {
        throw ExportError.unavailable
    }
    public enum ExportError: Error { case unavailable }
#endif
}
