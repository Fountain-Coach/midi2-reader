import XCTest
@testable import midi2_export

final class CLITests: XCTestCase {
    func testParsePageSpec() {
        XCTAssertEqual(parsePageSpec("1,3-5,7"), [1,3,4,5,7])
        XCTAssertEqual(parsePageSpec("2-2,4"), [2,4])
    }

    func testParseArgs() {
        let testFile = URL(fileURLWithPath: #filePath)
        let fixtures = testFile
            .deletingLastPathComponent() // CLITests
            .deletingLastPathComponent() // Tests
            .appendingPathComponent("Fixtures")
        let pdfPath = fixtures.appendingPathComponent("sample.pdf").path
        let outDir = fixtures.appendingPathComponent("cli-out").path
        let args = parseArgs(["midi2-export", "--out", outDir, "--dpi", "144", "--pages", "1,2-3", "--facsimile", pdfPath])
        XCTAssertEqual(args.out.path, outDir)
        XCTAssertEqual(args.dpi, 144)
        XCTAssertEqual(args.pages!, [1,2,3])
        XCTAssertTrue(args.exportFacsimile)
        XCTAssertFalse(args.exportReadable)
        XCTAssertEqual(args.docs.map { $0.path }, [pdfPath])
    }
}
