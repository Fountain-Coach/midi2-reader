import XCTest
@testable import Midi2Core

final class PDFTests: XCTestCase {
    func testSamplePDF() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let fixtures = testFile
            .deletingLastPathComponent() // PDFTests
            .deletingLastPathComponent() // Tests
            .appendingPathComponent("Fixtures")
        let pdfURL = fixtures.appendingPathComponent("sample.pdf")
        let textURL = fixtures.appendingPathComponent("sample.txt")
        let expected = try String(contentsOf: textURL).trimmingCharacters(in: .whitespacesAndNewlines)
        let pdf = try PopplerPDFDocument(path: pdfURL.path)
        XCTAssertEqual(pdf.pageCount, 1)
        guard let page = pdf.page(at: 0) else {
            return XCTFail("Missing page")
        }
        let extracted = page.string?.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(extracted, expected)
    }
}
