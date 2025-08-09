import XCTest
@testable import Midi2Core

final class HeadingDetectorTests: XCTestCase {
    func testDetectNumericHeadings() {
        if let h = detectHeading("1 Introduction") {
            XCTAssertEqual(h.level, 1)
            XCTAssertEqual(h.number, "1")
            XCTAssertEqual(h.title, "Introduction")
        } else {
            XCTFail("Should detect H1")
        }

        if let h = detectHeading("  1.2.3   Foo Bar  ") {
            XCTAssertEqual(h.level, 3)
            XCTAssertEqual(h.number, "1.2.3")
            XCTAssertEqual(h.title, "Foo Bar")
        } else {
            XCTFail("Should detect H3")
        }
    }

    func testNonHeading() {
        XCTAssertNil(detectHeading("Not a heading"))
        XCTAssertNil(detectHeading("1."))
        XCTAssertNil(detectHeading(""))
    }
}

