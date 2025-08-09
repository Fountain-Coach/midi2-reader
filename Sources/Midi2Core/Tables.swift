import Foundation
import PDFKit

public func extractTables(from page: PDFPage) -> [[String]] {
    // TODO: Implement ruled-table detection via CGPDFScanner and PDFSelection per cell.
    return []
}

public func tableToMarkdown(_ rows: [[String]]) -> String {
    guard let header = rows.first else { return "" }
    var md = "|" + header.map { $0.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: "|") + "|\n"
    md += "|" + Array(repeating: "---", count: header.count).joined(separator: "|") + "|\n"
    for r in rows.dropFirst() {
        md += "|" + r.map { $0.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: "|") + "|\n"
    }
    return md
}
