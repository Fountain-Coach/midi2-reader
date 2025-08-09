import Foundation
#if canImport(PDFKit)
import PDFKit
import CryptoKit
#endif

public struct ReadableExporter {
#if canImport(PDFKit)
    public static func export(docURL: URL, to docFolder: URL) throws {
        guard let pdf = PDFDocument(url: docURL) else { throw ExportError.loadFailed }
        let title = docURL.deletingPathExtension().lastPathComponent

        var lines: [(pageIndex: Int, text: String)] = []
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i), let s = page.string {
                let parts = s.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
                for part in parts where !part.isEmpty {
                    lines.append((i, part))
                }
            }
        }

        // Build markdown
        var md: [String] = []
        md.append("# \(title)")
        // Collect headings for ToC
        struct Item { let level:Int; let number:String; let title:String; let anchor:String }
        var items: [Item] = []
        var nodes: [Node] = []
        var nodePageIndex: [Int] = []

        for (pi, line) in lines {
            if let h = detectHeading(line) {
                let anchor = anchorForHeading(number: h.number, title: h.title)
                items.append(Item(level: h.level, number: h.number, title: h.title, anchor: anchor))
                // node with heading type
                let bbox = findBBox(for: line, in: pdf, pageIndex: pi)
                let span = Span(text: line, bbox: bbox, sha256: sha256Hex(line))
                let node = Node(id: anchor, type: .heading(level: h.level), title: h.title, text: line, spans: [span])
                nodes.append(node)
                nodePageIndex.append(pi)
            } else {
                let anchor = "para-\(nodes.count+1)"
                let bbox = findBBox(for: line, in: pdf, pageIndex: pi)
                let span = Span(text: line, bbox: bbox, sha256: sha256Hex(line))
                let node = Node(id: anchor, type: .paragraph, title: nil, text: line, spans: [span])
                nodes.append(node)
                nodePageIndex.append(pi)
            }
        }

        // ToC (H1..H3) collapsible
        md.append("\n<details><summary><strong>Table of Contents</strong></summary>")
        for it in items where it.level <= 3 {
            let indent = String(repeating: "  ", count: max(0, it.level-1))
            md.append("\(indent)- [\(it.number) \(it.title)](#\(it.anchor))")
        }
        md.append("</details>\n")

        // Emit content
        for node in nodes {
            switch node.type {
            case .heading(let level):
                let hashes = String(repeating: "#", count: min(6, max(1, level)))
                let titleText = node.title ?? node.text
                md.append("<a id=\"\(node.id)\"></a>")
                md.append("\(hashes) \(titleText)")
            case .paragraph:
                md.append(node.text)
            case .table:
                md.append(node.text)
            }
            if let bbox = node.spans.first?.bbox, let idx = nodePageIndex[safe: nodes.firstIndex(where: { $0.id == node.id }) ?? -1], let loc = deepLink(for: bbox, pageIndex: idx) {
                md.append("[📎 source](./facsimile/facsimile.html#\(loc))")
            }
            md.append("")
        }

        // Tables per page → Markdown blocks and nodes
        var tableCount = 0
        for pi in 0..<pdf.pageCount {
            guard let page = pdf.page(at: pi) else { continue }
            let tables = TableExtractor.extract(from: page, pageIndex: pi)
            for t in tables {
                tableCount += 1
                let mdTable = tableToMarkdown(t)
                md.append("\n<a id=\"table-\(tableCount)\"></a>")
                md.append(mdTable)
                if let firstCell = t.cells.first?.first {
                    if let loc = deepLink(for: firstCell.rect, pageIndex: pi) {
                        md.append("[📎 table source](./facsimile/facsimile.html#\(loc))")
                    }
                    let span = Span(text: mdTable, bbox: firstCell.rect, sha256: sha256Hex(mdTable))
                    let node = Node(id: "table-\(tableCount)", type: .table, title: nil, text: mdTable, spans: [span])
                    nodes.append(node)
                    nodePageIndex.append(pi)
                }
                md.append("")
            }
        }

        let out = md.joined(separator: "\n")
        try FileManager.default.createDirectory(at: docFolder, withIntermediateDirectories: true)
        try out.data(using: .utf8)!.write(to: docFolder.appendingPathComponent("index.md"), options: .atomic)

        // specdoc.json
        let pageSizes = (0..<pdf.pageCount).compactMap { pdf.page(at: $0)?.bounds(for: .mediaBox).size }
        let spec = SpecDoc(title: title, pageSizes: pageSizes, nodes: nodes)
        let specURL = docFolder.appendingPathComponent("specdoc.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(spec).write(to: specURL, options: .atomic)

        // provenance.json
        let prov = Provenance(
            documentSHA256: sha256Hex(pdf.string ?? ""),
            pageCount: pdf.pageCount,
            nodeCount: nodes.count,
            headingCount: nodes.filter { if case .heading = $0.type { return true } else { return false } }.count,
            paragraphCount: nodes.filter { if case .paragraph = $0.type { return true } else { return false } }.count
        )
        let provURL = docFolder.appendingPathComponent("provenance.json")
        try encoder.encode(prov).write(to: provURL, options: .atomic)

        // QA.md
        var qa: [String] = []
        qa.append("# QA")
        qa.append("- Title: \(title)")
        qa.append("- Pages: \(pdf.pageCount)")
        qa.append("- Nodes: \(nodes.count) (headings: \(prov.headingCount), paragraphs: \(prov.paragraphCount))")
        qa.append("")
        try qa.joined(separator: "\n").data(using: .utf8)!.write(to: docFolder.appendingPathComponent("QA.md"), options: .atomic)
    }

    public enum ExportError: Error { case loadFailed }

    // Helpers
    private static func sha256Hex(_ text: String) -> String {
        let data = Data(text.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    private static func findBBox(for text: String, in pdf: PDFDocument, pageIndex: Int) -> CGRect? {
        // Try to find selection for the given text on a page; may be approximate
        guard let page = pdf.page(at: pageIndex) else { return nil }
        let selections = pdf.findString(text, withOptions: [.caseInsensitive])
        // choose first selection on same page, otherwise nil
        for sel in selections {
            if let selPage = sel.pages.first, selPage == page {
                let rect = sel.bounds(for: page)
                if rect.width > 1 && rect.height > 1 { return rect }
            }
        }
        return nil
    }

    private static func deepLink(for bbox: CGRect, pageIndex: Int) -> String? {
        // round to integers
        let x = Int(bbox.origin.x.rounded())
        let y = Int(bbox.origin.y.rounded())
        let w = Int(bbox.size.width.rounded())
        let h = Int(bbox.size.height.rounded())
        return String(format: "p%03d-x%d-y%d-w%d-h%d", pageIndex + 1, x, y, w, h)
    }

#else
    public static func export(docURL: URL, to docFolder: URL) throws {
        throw ExportError.unavailable
    }
    public enum ExportError: Error { case unavailable }
#endif
}
