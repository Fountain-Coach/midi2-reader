import Foundation
import CPoppler
#if canImport(CoreGraphics)
import CoreGraphics
#else
public typealias CGPDFPage = OpaquePointer
public typealias CGPDFBox = Int32
public typealias CGContext = OpaquePointer
#endif

public protocol PDFDocument {
    var pageCount: Int { get }
    init(path: String) throws
    func page(at index: Int) -> PDFPage?
}

public protocol PDFPage {
    var string: String? { get }
    var pageRef: CGPDFPage? { get }
    func bounds(for box: CGPDFBox) -> CGRect
    func draw(with box: CGPDFBox, to context: CGContext)
    func rect(for range: NSRange) -> CGRect?
    func text(in rect: CGRect) -> String
}

#if os(Linux)
public struct PopplerPDFDocument: PDFDocument {
    private let doc: OpaquePointer?
    public let pageCount: Int

    public init(path: String) throws {
        var err: UnsafeMutablePointer<GError>? = nil
        let uri = "file://" + path
        let ptr = poppler_document_new_from_file(uri, nil, &err)
        if let e = err { g_error_free(e) }
        doc = ptr
        if let d = ptr {
            pageCount = Int(poppler_document_get_n_pages(d))
        } else {
            pageCount = 0
        }
    }

    public func page(at index: Int) -> PDFPage? {
        guard let d = doc, let p = poppler_document_get_page(d, Int32(index)) else { return nil }
        return PopplerPDFPage(page: p)
    }
}

public struct PopplerPDFPage: PDFPage {
    private let page: OpaquePointer
    init(page: OpaquePointer) { self.page = page }

    public var string: String? {
        guard let cstr = poppler_page_get_text(page) else { return nil }
        defer { g_free(cstr) }
        return String(cString: cstr)
    }

    public var pageRef: CGPDFPage? { nil }

    public func bounds(for box: CGPDFBox) -> CGRect {
        var w: Double = 0, h: Double = 0
        poppler_page_get_size(page, &w, &h)
        return CGRect(x: 0, y: 0, width: w, height: h)
    }

    public func draw(with box: CGPDFBox, to context: CGContext) {
        // Rendering via Poppler requires Cairo; not yet implemented.
    }

    public func rect(for range: NSRange) -> CGRect? { nil }

    public func text(in rect: CGRect) -> String {
        guard let c = poppler_page_get_text(page) else { return "" }
        defer { g_free(c) }
        return String(cString: c)
    }
}
#endif
