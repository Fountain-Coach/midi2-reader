import XCTest
@testable import Midi2Core

final class ExporterTests: XCTestCase {
    func testFacsimileExportProducesHTMLAndPNG() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let fixtures = testFile
            .deletingLastPathComponent() // ExporterTests
            .deletingLastPathComponent() // Tests
            .appendingPathComponent("Fixtures")
        let pdfURL = fixtures.appendingPathComponent("sample.pdf")
        let expectedHTMLURL = fixtures.appendingPathComponent("expected-facsimile.html")
        let pdf = try PopplerPDFDocument(path: pdfURL.path)
        let tempRoot = fixtures.appendingPathComponent("out")
        try? FileManager.default.removeItem(at: tempRoot)
        let out = try FacsimileExporter.export(pdf: pdf, docId: "sample", to: tempRoot, dpi: 72)
        let htmlURL = out.appendingPathComponent("facsimile/facsimile.html")
        let pngURL = out.appendingPathComponent("facsimile/p001.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: pngURL.path))
        let html = try String(contentsOf: htmlURL, encoding: .utf8)
        let expected = try String(contentsOf: expectedHTMLURL, encoding: .utf8)
        XCTAssertEqual(html, expected)
        try? FileManager.default.removeItem(at: tempRoot)
    }
}
