import Foundation
import CoreGraphics

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

#if canImport(PDFKit)
import PDFKit

public struct PDFKitDocument: PDFDocument {
    private let doc: PDFKit.PDFDocument
    public var pageCount: Int { doc.pageCount }

    public init(path: String) throws {
        guard let d = PDFKit.PDFDocument(url: URL(fileURLWithPath: path)) else {
            throw NSError(domain: "PDFKit", code: 0, userInfo: nil)
        }
        self.doc = d
    }

    public func page(at index: Int) -> PDFPage? {
        guard let p = doc.page(at: index) else { return nil }
        return PDFKitPage(page: p)
    }
}

public struct PDFKitPage: PDFPage {
    private let page: PDFKit.PDFPage
    init(page: PDFKit.PDFPage) { self.page = page }

    public var string: String? { page.string }
    public var pageRef: CGPDFPage? { page.pageRef }
    public func bounds(for box: CGPDFBox) -> CGRect { page.bounds(for: box) }
    public func draw(with box: CGPDFBox, to context: CGContext) { page.draw(with: box, to: context) }
    public func rect(for range: NSRange) -> CGRect? { page.selection(for: range)?.bounds(for: page) }
    public func text(in rect: CGRect) -> String { page.selection(for: rect)?.string ?? "" }
}
#endif
