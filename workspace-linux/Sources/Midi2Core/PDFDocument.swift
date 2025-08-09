public protocol PDFDocument {
    var pageCount: Int { get }
    init(path: String) throws
    func text(at page: Int) -> String
}

#if os(Linux)
/// Placeholder implementation. Integration with Poppler or PDFium will live here.
public struct PopplerPDFDocument: PDFDocument {
    public let pageCount: Int
    public init(path: String) throws {
        // TODO: load document using Poppler
        self.pageCount = 0
    }
    public func text(at page: Int) -> String {
        // TODO: extract text for page
        return ""
    }
}
#endif
