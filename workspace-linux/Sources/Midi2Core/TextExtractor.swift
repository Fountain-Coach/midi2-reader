#if os(Linux)
import Foundation
import CPoppler

public struct TextLine: Codable, Sendable, Equatable {
    public let pageIndex: Int
    public let range: NSRange
    public let text: String
    public let bbox: CGRect
}

public enum TextExtractor {
    public static func extract(document pdf: PDFDocument, dpi: Double) -> [TextLine] {
        var lines: [TextLine] = []
        for index in 0..<pdf.pageCount {
            guard let popplerPage = pdf.page(at: index) as? PopplerPDFPage else { continue }
            lines.append(contentsOf: extract(page: popplerPage, pageIndex: index, dpi: dpi))
        }
        return lines
    }

    public static func extract(page: PopplerPDFPage, pageIndex: Int, dpi: Double) -> [TextLine] {
        var rectsPtr: UnsafeMutablePointer<PopplerRectangle>? = nil
        var count: UInt32 = 0
        guard poppler_page_get_text_layout(page.page, &rectsPtr, &count) != 0,
              let rects = rectsPtr else { return [] }
        defer { g_free(rectsPtr) }

        let fullPtr = poppler_page_get_text(page.page)
        let fullText = fullPtr.map { String(cString: $0) } ?? ""
        if let fp = fullPtr { g_free(fp) }
        let nsFull = fullText as NSString
        var searchLoc = 0

        let pageHeight = Double(page.bounds(for: .mediaBox).height)
        var out: [TextLine] = []

        for i in 0..<Int(count) {
            var rect = rects[i]
            guard let cstr = poppler_page_get_text_for_area(page.page, &rect) else { continue }
            let original = String(cString: cstr)
            g_free(cstr)
            let normalized = normalizeWhitespace(original)
            if normalized.isEmpty { continue }
            let range = nsFull.range(of: original, options: [], range: NSRange(location: searchLoc, length: nsFull.length - searchLoc))
            if range.location != NSNotFound {
                searchLoc = range.location + range.length
            }
            let mapped = map(rect: rect, pageHeight: pageHeight, dpi: dpi)
            out.append(TextLine(pageIndex: pageIndex, range: range, text: normalized, bbox: mapped))
        }
        return out
    }

    private static func normalizeWhitespace(_ s: String) -> String {
        let collapsed = s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func map(rect: PopplerRectangle, pageHeight: Double, dpi: Double) -> CGRect {
        let scale = dpi / 72.0
        let x = rect.x1 * scale
        let y = (pageHeight - rect.y2) * scale
        let width = (rect.x2 - rect.x1) * scale
        let height = (rect.y2 - rect.y1) * scale
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
#endif
