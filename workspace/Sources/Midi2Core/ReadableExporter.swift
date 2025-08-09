import Foundation
#if canImport(PDFKit)
import PDFKit
#endif

public struct ReadableExporter {
#if canImport(PDFKit)
    public static func export(docURL: URL, to docFolder: URL) throws {
        guard let pdf = PDFDocument(url: docURL) else { throw ExportError.loadFailed }
        let title = docURL.deletingPathExtension().lastPathComponent

        var lines: [String] = []
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i), let s = page.string {
                // Split by newlines; keep order
                let parts = s.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
                lines.append(contentsOf: parts.filter { !$0.isEmpty })
            }
        }

        // Build markdown
        var md: [String] = []
        md.append("# \(title)")
        // Collect headings for ToC
        struct Item { let level:Int; let number:String; let title:String; let anchor:String }
        var items: [Item] = []

        for line in lines {
            if let h = detectHeading(line) {
                let anchor = anchorForHeading(number: h.number, title: h.title)
                items.append(Item(level: h.level, number: h.number, title: h.title, anchor: anchor))
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
        for line in lines {
            if let h = detectHeading(line) {
                let anchor = anchorForHeading(number: h.number, title: h.title)
                let hashes = String(repeating: "#", count: min(6, max(1, h.level)))
                md.append("<a id=\"\(anchor)\"></a>")
                md.append("\(hashes) \(h.number) \(h.title)")
            } else {
                md.append(line) // verbatim paragraph
            }
            md.append("")
        }

        let out = md.joined(separator: "\n")
        try FileManager.default.createDirectory(at: docFolder, withIntermediateDirectories: true)
        try out.data(using: .utf8)!.write(to: docFolder.appendingPathComponent("index.md"), options: .atomic)
    }

    public enum ExportError: Error { case loadFailed }
#else
    public static func export(docURL: URL, to docFolder: URL) throws {
        throw ExportError.unavailable
    }
    public enum ExportError: Error { case unavailable }
#endif
}

