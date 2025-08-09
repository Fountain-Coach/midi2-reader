import XCTest
@testable import Midi2Core

final class Midi2CoreTests: XCTestCase {
    func testTextExtraction() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent() // Midi2CoreTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // workspace-linux
            .deletingLastPathComponent() // repo root
        let pdfURL = repoRoot.appendingPathComponent("workspace/Inputs/M2-100-U_v1-1_MIDI_2-0_Specification_Overview.pdf")
        let doc = try PopplerPDFDocument(path: pdfURL.path)
        guard let page = doc.page(at: 0) as? PopplerPDFPage else {
            XCTFail("Failed to load page")
            return
        }
        let lines = TextExtractor.extract(page: page, pageIndex: 0, dpi: 72)
        XCTAssertFalse(lines.isEmpty)
        XCTAssert(lines.allSatisfy { !$0.text.isEmpty })
        XCTAssert(lines.allSatisfy { $0.bbox.width > 0 && $0.bbox.height > 0 })
    }
}
