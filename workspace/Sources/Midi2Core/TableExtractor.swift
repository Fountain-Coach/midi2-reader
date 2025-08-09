import Foundation
import CoreGraphics

public struct TableExtractor {
    public struct TableCell { public var rect: CGRect; public var text: String }
    public struct Table { public var pageIndex: Int; public var cells: [[TableCell]] }

    public static func extract(document pdf: PDFDocument, tolerance: CGFloat = 2.0) -> [Table] {
        var tables: [Table] = []
        for pi in 0..<pdf.pageCount {
            guard let page = pdf.page(at: pi) else { continue }
            tables.append(contentsOf: extract(page: page, pageIndex: pi, tolerance: tolerance))
        }
        return tables
    }

    private static func extract(page: PDFPage, pageIndex: Int, tolerance: CGFloat) -> [Table] {
        guard let cgPage = page.pageRef else { return [] }
        let content = CGPDFContentStreamCreateWithPage(cgPage)
        let optable = CGPDFOperatorTableCreate()!
        let ctx = TableScanContext()

        CGPDFOperatorTableSetCallback(optable, "m") { scanner, info in
            guard let info = info else { return }
            let ctx = Unmanaged<TableScanContext>.fromOpaque(info).takeUnretainedValue()
            if let y = popNumber(scanner), let x = popNumber(scanner) { ctx.current = CGPoint(x: x, y: y) }
        }
        CGPDFOperatorTableSetCallback(optable, "l") { scanner, info in
            guard let info = info else { return }
            let ctx = Unmanaged<TableScanContext>.fromOpaque(info).takeUnretainedValue()
            if let y = popNumber(scanner), let x = popNumber(scanner), let p0 = ctx.current {
                let p1 = CGPoint(x: x, y: y)
                ctx.lines.append((p0, p1))
                ctx.current = p1
            }
        }
        CGPDFOperatorTableSetCallback(optable, "re") { scanner, info in
            guard let info = info else { return }
            let ctx = Unmanaged<TableScanContext>.fromOpaque(info).takeUnretainedValue()
            if let h = popNumber(scanner), let w = popNumber(scanner), let y = popNumber(scanner), let x = popNumber(scanner) {
                let r = CGRect(x: x, y: y, width: w, height: h)
                // decompose rectangle into 4 lines
                let p1 = CGPoint(x: r.minX, y: r.minY)
                let p2 = CGPoint(x: r.maxX, y: r.minY)
                let p3 = CGPoint(x: r.maxX, y: r.maxY)
                let p4 = CGPoint(x: r.minX, y: r.maxY)
                ctx.lines.append((p1, p2))
                ctx.lines.append((p2, p3))
                ctx.lines.append((p3, p4))
                ctx.lines.append((p4, p1))
            }
        }

        let ctxPtr = Unmanaged.passUnretained(ctx).toOpaque()
        let scanner = CGPDFScannerCreate(content, optable, ctxPtr)
        CGPDFScannerScan(scanner)

        // Separate long H/V lines
        var hs: [CGFloat] = []
        var vs: [CGFloat] = []
        for (p0, p1) in ctx.lines {
            let dx = abs(p0.x - p1.x), dy = abs(p0.y - p1.y)
            if dy < 0.5, dx > 20 { hs.append((p0.y + p1.y)/2) }
            if dx < 0.5, dy > 20 { vs.append((p0.x + p1.x)/2) }
        }
        let rows = cluster(uniqueValues: hs, tol: tolerance).sorted()
        let cols = cluster(uniqueValues: vs, tol: tolerance).sorted()
        guard rows.count >= 2, cols.count >= 2 else { return [] }

        // Build grid and collect cell text
        var cellRows: [[TableCell]] = []
        for r in 0..<(rows.count - 1) {
            var row: [TableCell] = []
            for c in 0..<(cols.count - 1) {
                let rect = CGRect(x: cols[c], y: rows[r], width: cols[c+1]-cols[c], height: rows[r+1]-rows[r])
                let text = page.text(in: rect).trimmingCharacters(in: .whitespacesAndNewlines)
                row.append(TableCell(rect: rect, text: text))
            }
            cellRows.append(row)
        }
        return [Table(pageIndex: pageIndex, cells: cellRows)]
    }
}

// MARK: - Scanner internals
final class TableScanContext {
    var current: CGPoint? = nil
    var lines: [(CGPoint, CGPoint)] = []
}

private func popNumber(_ scanner: CGPDFScannerRef) -> CGFloat? {
    var obj: CGPDFObjectRef? = nil
    if !CGPDFScannerPopObject(scanner, &obj) { return nil }
    guard let o = obj, CGPDFObjectGetType(o) == .real || CGPDFObjectGetType(o) == .integer else { return nil }
    var f: CGPDFReal = 0
    if CGPDFObjectGetValue(o, .real, &f) { return CGFloat(f) }
    var i: CGPDFInteger = 0
    if CGPDFObjectGetValue(o, .integer, &i) { return CGFloat(i) }
    return nil
}

private func cluster(uniqueValues: [CGFloat], tol: CGFloat) -> [CGFloat] {
    guard !uniqueValues.isEmpty else { return [] }
    let sorted = uniqueValues.sorted()
    var out: [CGFloat] = []
    var group: [CGFloat] = [sorted[0]]
    for v in sorted.dropFirst() {
        if abs(v - group.last!) <= tol { group.append(v) }
        else { out.append(group.reduce(0, +) / CGFloat(group.count)); group = [v] }
    }
    out.append(group.reduce(0, +) / CGFloat(group.count))
    return out
}

// MARK: - Markdown emission
public func tableToMarkdown(_ table: TableExtractor.Table) -> String {
    let rows = table.cells
    guard let first = rows.first else { return "" }
    var lines: [String] = []
    // Header: use first row
    let headers = first.map { sanitize($0.text.isEmpty ? " " : $0.text) }
    lines.append("| " + headers.joined(separator: " | ") + " |")
    lines.append("|" + Array(repeating: " --- ", count: headers.count).joined(separator: "|") + "|")
    for r in rows.dropFirst() {
        let vals = r.map { sanitize($0.text) }
        lines.append("| " + vals.joined(separator: " | ") + " |")
    }
    return lines.joined(separator: "\n")
}

private func sanitize(_ s: String) -> String {
    s.replacingOccurrences(of: "|", with: "\\|")
}
