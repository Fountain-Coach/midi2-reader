import Foundation
import PDFKit
import CryptoKit

public enum PDFParser {
    public static func parseDocument(url: URL) -> SpecDoc? {
        guard let doc = PDFDocument(url: url) else { return nil }
        let docID = url.deletingPathExtension().lastPathComponent
        let data = (try? Data(contentsOf: url)) ?? Data()
        let sha = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()

        var pages: [PageInfo] = []
        let count = doc.pageCount
        for i in 0..<count {
            guard let p = doc.page(at: i) else { continue }
            let r = p.bounds(for: .mediaBox)
            pages.append(PageInfo(pageIndex: i, width: Double(r.width), height: Double(r.height)))
        }

        var nodes: [Node] = []
        var nid = 0
        for i in 0..<count {
            guard let page = doc.page(at: i) else { continue }
            let text = page.string ?? ""
            let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty { continue }
                nid += 1
                var kind = "Paragraph"
                var attrs: [String:String] = [:]
                if let h = detectHeading(trimmed) {
                    kind = "Heading"
                    attrs["num"] = h.num
                    attrs["title"] = h.title
                    attrs["anchor"] = slugify("\(h.num) \(h.title)")
                }
                // TODO: compute real bbox via PDFSelection; placeholder zeros for now
                let span = Span(page: i, bbox: [0,0,0,0], confidence: 0.9, sha256: nil)
                nodes.append(Node(id: "n\(nid)", kind: kind, text: line, attrs: attrs.isEmpty ? nil : attrs, spans: [span], children: nil))
            }

            let tableRows = extractTables(from: page)
            if tableRows.count >= 2 {
                let md = tableToMarkdown(tableRows)
                nid += 1
                let span = Span(page: i, bbox: [0,0,0,0], confidence: 0.8, sha256: nil)
                nodes.append(Node(id: "n\(nid)", kind: "Table", text: md, attrs: nil, spans: [span], children: nil))
            }
        }

        return SpecDoc(docID: docID, source: url.path, sha256: sha, pages: pages, nodes: nodes)
    }
}
