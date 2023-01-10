import XCTest
@testable import ObjectDB

final class IndexRangeTests: XCTestCase {

    func testLowerOpenIndexRange() throws {
        let firstRange = IndexRange(nil, .excluded(10))
        XCTAssertEqual(firstRange.contains(0), true)
        XCTAssertEqual(firstRange.contains(10), false)
        XCTAssertEqual(firstRange.contains(11), false)
    }

    func testUpperOpenIndexRange() throws {
        let firstRange = IndexRange(.excluded(10), nil)
        XCTAssertEqual(firstRange.contains(0), false)
        XCTAssertEqual(firstRange.contains(10), false)
        XCTAssertEqual(firstRange.contains(11), true)
    }

    func testExcludedIndexRange() throws {
        let firstRange = IndexRange(.excluded(0), .excluded(10))
        XCTAssertEqual(firstRange.contains(0), false)
        XCTAssertEqual(firstRange.contains(1), true)
        XCTAssertEqual(firstRange.contains(10), false)
        XCTAssertEqual(firstRange.contains(11), false)
    }

    func testIncludedIndexRange() throws {
        let firstRange = IndexRange(.included(1), .included(10))
        XCTAssertEqual(firstRange.contains(0), false)
        XCTAssertEqual(firstRange.contains(1), true)
        XCTAssertEqual(firstRange.contains(5), true)
        XCTAssertEqual(firstRange.contains(10), true)
        XCTAssertEqual(firstRange.contains(11), false)
    }

    func testOverlapsIndexRange() throws {
        let fullOpenRange = IndexRange<Int>(nil, nil)
        // Two full open
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange<Int>(nil, nil)), true)

        // Full open and half open
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange(nil, .excluded(2))), true)
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange(nil, .included(2))), true)
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange(.excluded(2), nil)), true)
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange(.included(2), nil)), true)

        // Full open and closed
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange(.excluded(2), .excluded(10))), true)
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange(.excluded(2), .included(10))), true)
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange(.included(2), .excluded(10))), true)
        XCTAssertEqual(fullOpenRange.overlaps(IndexRange(.included(2), .included(10))), true)

        let lowerOpenUpperExcludedRange = IndexRange(nil, .excluded(10))
        // Two half open
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(nil, .excluded(2))), true)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(nil, .excluded(10))), true)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(nil, .excluded(11))), true)

        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.excluded(2), nil)), true)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.excluded(10), nil)), false)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.included(10), nil)), true)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.included(11), nil)), false)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.excluded(11), nil)), false)

        // Half open and closed
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.excluded(0), .excluded(2))), true)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.excluded(0), .excluded(10))), true)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.excluded(0), .excluded(11))), true)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.included(10), .excluded(11))), true)
        XCTAssertEqual(lowerOpenUpperExcludedRange.overlaps(IndexRange(.excluded(10), .excluded(12))), false)

        // Two closed
    }

    func testUnion() throws {
        let lowerOpenUpperExcludedRange = IndexRange(nil, .excluded(10))

        XCTAssertEqual(lowerOpenUpperExcludedRange.union(IndexRange(nil, .excluded(11))), IndexRange(nil, .excluded(11)))
        XCTAssertEqual(lowerOpenUpperExcludedRange.union(IndexRange(nil, .excluded(9))), IndexRange(nil, .excluded(10)))
        XCTAssertEqual(lowerOpenUpperExcludedRange.union(IndexRange(nil, .included(10))), IndexRange(nil, .included(10)))
        XCTAssertEqual(lowerOpenUpperExcludedRange.union(IndexRange(nil, nil)), IndexRange(nil, nil))

        let lowerExcludedUpperOpenRange = IndexRange(.excluded(10), nil)

        XCTAssertEqual(lowerExcludedUpperOpenRange.union(IndexRange(.excluded(11), nil)), IndexRange(.excluded(10), nil))
        XCTAssertEqual(lowerExcludedUpperOpenRange.union(IndexRange(.excluded(9), nil)), IndexRange(.excluded(9), nil))
        XCTAssertEqual(lowerExcludedUpperOpenRange.union(IndexRange(.included(10), nil)), IndexRange(.included(10), nil))
        XCTAssertEqual(lowerExcludedUpperOpenRange.union(IndexRange(nil, nil)), IndexRange(nil, nil))

        XCTAssertEqual(IndexRange(.excluded(0), .included(12)).union(IndexRange(.included(0), .excluded(12))), IndexRange(.included(0), .included(12)))
    }

    func testIntersect() throws {
        // TODO: write tests
    }

}
