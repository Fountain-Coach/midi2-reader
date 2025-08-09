#if canImport(PDFKit)
import XCTest
import CoreGraphics
import CoreText
@testable import Midi2Core

final class TextAndTableExtractorTests: XCTestCase {
    private func makePDF(at url: URL) throws {
        var box = CGRect(x: 0, y: 0, width: 200, height: 200)
        guard let ctx = CGContext(url as CFURL, mediaBox: &box, nil) else { throw NSError(domain: "pdf", code: 1) }
        ctx.beginPDFPage(nil)

        let font = CTFontCreateWithName("Helvetica" as CFString, 12, nil)
        func draw(_ text: String, at point: CGPoint) {
            let attrs: [NSAttributedString.Key: Any] = [kCTFontAttributeName as NSAttributedString.Key: font]
            let attr = NSAttributedString(string: text, attributes: attrs)
            let line = CTLineCreateWithAttributedString(attr)
            ctx.textPosition = point
            CTLineDraw(line, ctx)
        }

        // top text line
        draw("Hello", at: CGPoint(x: 60, y: 170))

        // table grid
        ctx.setLineWidth(1)
        ctx.addRect(CGRect(x: 50, y: 50, width: 100, height: 100))
        ctx.move(to: CGPoint(x: 50, y: 100))
        ctx.addLine(to: CGPoint(x: 150, y: 100))
        ctx.move(to: CGPoint(x: 100, y: 50))
        ctx.addLine(to: CGPoint(x: 100, y: 150))
        ctx.strokePath()

        // cell texts
        draw("A1", at: CGPoint(x: 60, y: 130))
        draw("B1", at: CGPoint(x: 110, y: 130))
        draw("A2", at: CGPoint(x: 60, y: 80))
        draw("B2", at: CGPoint(x: 110, y: 80))

        ctx.endPDFPage()
        ctx.closePDF()
    }

    func testTextExtraction() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("sample.pdf")
        try? FileManager.default.removeItem(at: url)
        try makePDF(at: url)
        let pdf = try PDFKitDocument(path: url.path)
        let lines = TextExtractor.extract(document: pdf)
        XCTAssertEqual(lines.map { $0.text }, ["Hello", "A1", "B1", "A2", "B2"])
    }

    func testTableExtraction() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("sample.pdf")
        try? FileManager.default.removeItem(at: url)
        try makePDF(at: url)
        let pdf = try PDFKitDocument(path: url.path)
        let tables = TableExtractor.extract(document: pdf, tolerance: 0.5)
        XCTAssertEqual(tables.count, 1)
        guard let table = tables.first else { return }
        XCTAssertEqual(table.pageIndex, 0)
        XCTAssertEqual(table.cells.count, 2)
        XCTAssertEqual(table.cells[0].count, 2)
        XCTAssertEqual(table.cells[0][0].text, "A1")
        XCTAssertEqual(table.cells[0][1].text, "B1")
        XCTAssertEqual(table.cells[1][0].text, "A2")
        XCTAssertEqual(table.cells[1][1].text, "B2")
    }
}
#endif
