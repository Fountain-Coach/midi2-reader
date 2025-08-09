import Foundation
import CoreGraphics
public struct TextLine: Codable, Sendable, Equatable {
    public let pageIndex: Int
    public let range: NSRange
    public let text: String
    public let bbox: CGRect?
}

public enum TextExtractor {
    public static func extract(document pdf: PDFDocument) -> [TextLine] {
        // Prefer CGPDFScanner-based extraction for deterministic order; fall back to PDFKit newlines.
        var lines: [TextLine] = []
        var usedCG = false
        for pi in 0..<pdf.pageCount {
            guard let page = pdf.page(at: pi) else { continue }
            if let cgLines = extractPageWithCG(page: page, pageIndex: pi) {
                lines.append(contentsOf: mapToRanges(cgLines, on: page, pageIndex: pi))
                usedCG = true
            } else {
                lines.append(contentsOf: extractPageWithPDFKit(page: page, pageIndex: pi))
            }
        }
        if !usedCG {
            // All fell back to PDFKit; lines already include ranges
            return lines
        }
        return lines
    }

    // MARK: - CGPDFScanner-based page extraction (text only; positions approximated via mapping to ranges)
    private static func extractPageWithCG(page: PDFPage, pageIndex: Int) -> [String]? {
        guard let cgPage = page.pageRef else { return nil }
        let cs = CGPDFContentStreamCreateWithPage(cgPage)
        let table = CGPDFOperatorTableCreate()!
        // Install operator callbacks (C function pointers) using a collector context
        CGPDFOperatorTableSetCallback(table, "Tj", op_Tj)
        CGPDFOperatorTableSetCallback(table, "TJ", op_TJ)
        CGPDFOperatorTableSetCallback(table, "'", op_quote)
        CGPDFOperatorTableSetCallback(table, "\"", op_doublequote)
        CGPDFOperatorTableSetCallback(table, "T*", op_Tstar)
        CGPDFOperatorTableSetCallback(table, "ET", op_ET)

        let collector = CGTextCollector()
        let info = UnsafeMutableRawPointer(Unmanaged.passRetained(collector).toOpaque())
        defer { Unmanaged<CGTextCollector>.fromOpaque(info).release() }
        let scanner = CGPDFScannerCreate(cs, table, info)
        CGPDFScannerScan(scanner)
        collector.flush()
        return collector.lines
    }

    private static func mapToRanges(_ strings: [String], on page: PDFPage, pageIndex: Int) -> [TextLine] {
        guard let full = page.string else { return [] }
        var out: [TextLine] = []
        let nsFull = full as NSString
        var searchLoc = 0
        for s in strings {
            guard !s.isEmpty else { continue }
            let range = nsFull.range(of: s, options: [], range: NSRange(location: searchLoc, length: nsFull.length - searchLoc))
            if range.location != NSNotFound {
                let box = page.rect(for: range)
                out.append(TextLine(pageIndex: pageIndex, range: range, text: s, bbox: box))
                searchLoc = range.location + range.length
            }
        }
        return out
    }

    // Fallback: split page.string by newlines
    private static func extractPageWithPDFKit(page: PDFPage, pageIndex: Int) -> [TextLine] {
        var out: [TextLine] = []
        guard let full = page.string, !full.isEmpty else { return out }
        let scalars = Array(full)
        var idx = 0
        var start = 0
        while idx <= scalars.count {
            if idx == scalars.count || scalars[idx] == "\n" || scalars[idx] == "\r" {
                let length = idx - start
                if length > 0 {
                    let nsr = NSRange(location: start, length: length)
                    let s = (full as NSString).substring(with: nsr)
                    let box = page.rect(for: nsr)
                    out.append(TextLine(pageIndex: pageIndex, range: nsr, text: s, bbox: box))
                }
                start = idx + 1
            }
            idx += 1
        }
        return out
    }
}

// MARK: - CGPDF helpers
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

private func popPDFString(_ scanner: CGPDFScannerRef) -> String? {
    var strRef: CGPDFStringRef? = nil
    if CGPDFScannerPopString(scanner, &strRef), let s = strRef, let cf = CGPDFStringCopyTextString(s) {
        return cf as String
    }
    return nil
}

// MARK: - CGPDF text collector and callbacks
final class CGTextCollector {
    var current: String = ""
    var lines: [String] = []
    func append(_ s: String) { current += s }
    func flush() { if !current.isEmpty { lines.append(current); current.removeAll(keepingCapacity: true) } }
}

private func op_Tj(_ scanner: CGPDFScannerRef, _ info: UnsafeMutableRawPointer?) {
    guard let info, let s = popPDFString(scanner) else { return }
    let ctx = Unmanaged<CGTextCollector>.fromOpaque(info).takeUnretainedValue()
    ctx.append(s)
}

private func op_TJ(_ scanner: CGPDFScannerRef, _ info: UnsafeMutableRawPointer?) {
    guard let info else { return }
    var array: CGPDFArrayRef? = nil
    guard CGPDFScannerPopArray(scanner, &array), let array else { return }
    let ctx = Unmanaged<CGTextCollector>.fromOpaque(info).takeUnretainedValue()
    let count = CGPDFArrayGetCount(array)
    for i in 0..<count {
        var obj: CGPDFObjectRef? = nil
        if CGPDFArrayGetObject(array, i, &obj), let o = obj, CGPDFObjectGetType(o) == .string {
            var strRef: CGPDFStringRef? = nil
            if CGPDFObjectGetValue(o, .string, &strRef), let str = strRef, let cf = CGPDFStringCopyTextString(str) {
                ctx.append(cf as String)
            }
        }
    }
}

private func op_quote(_ scanner: CGPDFScannerRef, _ info: UnsafeMutableRawPointer?) {
    guard let info else { return }
    let ctx = Unmanaged<CGTextCollector>.fromOpaque(info).takeUnretainedValue()
    if let s = popPDFString(scanner) { ctx.flush(); ctx.append(s) }
}

private func op_doublequote(_ scanner: CGPDFScannerRef, _ info: UnsafeMutableRawPointer?) {
    guard let info else { return }
    let ctx = Unmanaged<CGTextCollector>.fromOpaque(info).takeUnretainedValue()
    _ = popNumber(scanner)
    _ = popNumber(scanner)
    if let s = popPDFString(scanner) { ctx.flush(); ctx.append(s) }
}

private func op_Tstar(_ scanner: CGPDFScannerRef, _ info: UnsafeMutableRawPointer?) {
    guard let info else { return }
    let ctx = Unmanaged<CGTextCollector>.fromOpaque(info).takeUnretainedValue()
    ctx.flush()
}

private func op_ET(_ scanner: CGPDFScannerRef, _ info: UnsafeMutableRawPointer?) {
    guard let info else { return }
    let ctx = Unmanaged<CGTextCollector>.fromOpaque(info).takeUnretainedValue()
    ctx.flush()
}
