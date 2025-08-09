import XCTest
@testable import Midi2Core

final class Midi2CoreTests: XCTestCase {
    func testPlaceholder() throws {
        XCTAssertNoThrow(_ = try PopplerPDFDocument(path: "/tmp/none"))
    }
}
