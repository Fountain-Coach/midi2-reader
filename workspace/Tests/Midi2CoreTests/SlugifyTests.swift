import XCTest
@testable import Midi2Core

final class SlugifyTests: XCTestCase {
    func testSimpleSlug() {
        XCTAssertEqual(slugify("Hello World"), "hello-world")
        XCTAssertEqual(slugify("  Multiple   Spaces  "), "multiple-spaces")
        XCTAssertEqual(slugify("Symbols & Stuff!"), "symbols-stuff")
    }

    func testAnchorForHeading() {
        XCTAssertEqual(anchorForHeading(number: "1", title: "Introduction"), "1-introduction")
        XCTAssertEqual(anchorForHeading(number: "1.2.3", title: "Foo Bar"), "1-2-3-foo-bar")
        XCTAssertEqual(anchorForHeading(number: "2", title: ""), "2")
    }
}

