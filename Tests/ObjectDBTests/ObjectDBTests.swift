import XCTest
@testable import ObjectDB

final class microDBTests: XCTestCase {

    func testSelectWhere() throws {
        let storage = Storage<TestStruct>(primaryIndex: BPlusTreeIndex(keyPath: \TestStruct.id))
        try storage.insert(TestStruct(id: 1, value: "A"))
        try storage.insert(TestStruct(id: 2, value: "B"))
        try storage.insert(TestStruct(id: 3, value: "C"))
        try storage.insert(TestStruct(id: 4, value: "D"))
        try storage.insert(TestStruct(id: 5, value: "D"))

        XCTAssertEqual(storage.where(\.id, .equal(2)).first(), TestStruct(id: 2, value: "B"))
        XCTAssertEqual(storage.where(\.id, .equal(2)).all().count, 1)
        XCTAssertEqual(storage.where(\.id, .less(2)).all(), [TestStruct(id: 1, value: "A")])
        XCTAssertEqual(storage.where(\.value.count, .equal(1)).all().count, 5)
        XCTAssertEqual(storage.where(\.id, .less(3)).all().count, 2)
        XCTAssertEqual(storage.all().count, 5)

        XCTAssertEqual(storage.where(\.id == 2).first(), TestStruct(id: 2, value: "B"))
        XCTAssertEqual(storage.where(\.id == 4 && \.value == "D").all().count, 1)
        XCTAssertEqual(storage.where(\.id == 4 || \.value == "D").all().count, 2)
        XCTAssertEqual(storage.where((\.id == 4 && \.value == "D") || (\.id == 1)).all().count, 2)
        XCTAssertEqual(storage.where(!(\.id == 4)).all().count, 4)

        XCTAssertEqual(storage.where(\.id == 2).first(), TestStruct(id: 2, value: "B"))
        XCTAssertEqual(storage.where(\.id > 2 && \.id < 5).all().count, 2)
        XCTAssertEqual(storage.where(\.id >= 1 && \.id <= 5).all().count, 5)
        XCTAssertEqual(storage.where(\.id >= 1 && \.id <= 2 || \.id >= 3 && \.id <= 10).all().count, 5)


    }

    func testUpdate() throws {
        let storage = Storage<TestStruct>(primaryIndex: BPlusTreeIndex(keyPath: \TestStruct.id))
        try storage.insert(TestStruct(id: 1, value: "A"))
        try storage.insert(TestStruct(id: 2, value: "B"))
        try storage.insert(TestStruct(id: 3, value: "C"))
        try storage.insert(TestStruct(id: 4, value: "D"))

        XCTAssertEqual(storage.where(\.id, .equal(1)).update(\.value, value: "H"), 1)
        XCTAssertEqual(storage.where(\.id, .equal(1)).first(), TestStruct(id: 1, value: "H"))

        storage.where(\.id, .in([1, 3])).update {
            $0.set(\.value, value: "T")
            $0.set(\.secondValue, value: 3)
        }

        XCTAssertEqual(storage.where(\.id, .equal(1)).first(), TestStruct(id: 1, value: "T", secondValue: 3))
        XCTAssertEqual(storage.where(\.id, .equal(3)).first(), TestStruct(id: 3, value: "T", secondValue: 3))

        // TODO: test with changing index key
    }

    func testDelete() throws {
        let storage = Storage<TestStruct>(primaryIndex: BPlusTreeIndex(keyPath: \TestStruct.id))
        try storage.insert(TestStruct(id: 1, value: "A"))
        try storage.insert(TestStruct(id: 2, value: "B"))
        try storage.insert(TestStruct(id: 3, value: "C"))
        try storage.insert(TestStruct(id: 4, value: "D"))

        XCTAssertEqual(storage.where(\.id, .equal(2)).delete(), 1)
        XCTAssertNil(storage.where(\.id, .equal(2)).first())
        XCTAssertEqual(storage.where(\.id, .greater(2)).delete(), 2)
        XCTAssertNil(storage.where(\.id, .equal(3)).first())
        XCTAssertNil(storage.where(\.id, .equal(4)).first())
        XCTAssertEqual(storage.all().count, 1)
    }

    func sample() throws {
        let storage = Storage<TestStruct>(primaryIndex: BPlusTreeIndex(keyPath: \TestStruct.id))
        try storage.insert(TestStruct(id: 1, value: "A"))
        try storage.insert(TestStruct(id: 2, value: "B"))
        try storage.insert(TestStruct(id: 3, value: "C"))
        try storage.insert(TestStruct(id: 4, value: "D"))

        let _ = storage
            .where(
                (\.id == 4 && \.value == "D") || (\.id == 1)
            )
            .all()

        storage.where(\.id, .equal(1)).update(\.value, value: "G")
    }

    func testLowerOpenBounds() throws {
        let firstBounds = Bounds(nil, .excluded(10))
        XCTAssertEqual(firstBounds.contains(0), true)
        XCTAssertEqual(firstBounds.contains(10), false)
        XCTAssertEqual(firstBounds.contains(11), false)
    }

    func testUpperOpenBounds() throws {
        let firstBounds = Bounds(.excluded(10), nil)
        XCTAssertEqual(firstBounds.contains(0), false)
        XCTAssertEqual(firstBounds.contains(10), false)
        XCTAssertEqual(firstBounds.contains(11), true)
    }

    func testExcludedBounds() throws {
        let firstBounds = Bounds(.excluded(0), .excluded(10))
        XCTAssertEqual(firstBounds.contains(0), false)
        XCTAssertEqual(firstBounds.contains(1), true)
        XCTAssertEqual(firstBounds.contains(10), false)
        XCTAssertEqual(firstBounds.contains(11), false)
    }

    func testIncludedBounds() throws {
        let firstBounds = Bounds(.included(1), .included(10))
        XCTAssertEqual(firstBounds.contains(0), false)
        XCTAssertEqual(firstBounds.contains(1), true)
        XCTAssertEqual(firstBounds.contains(5), true)
        XCTAssertEqual(firstBounds.contains(10), true)
        XCTAssertEqual(firstBounds.contains(11), false)
    }

    func testOverlapsBounds() throws {
        let fullOpenBounds = Bounds<Int>(nil, nil)
        // Two full open
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds<Int>(nil, nil)), true)

        // Full open and half open
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds(nil, .excluded(2))), true)
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds(nil, .included(2))), true)
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds(.excluded(2), nil)), true)
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds(.included(2), nil)), true)

        // Full open and closed
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds(.excluded(2), .excluded(10))), true)
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds(.excluded(2), .included(10))), true)
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds(.included(2), .excluded(10))), true)
        XCTAssertEqual(fullOpenBounds.overlaps(Bounds(.included(2), .included(10))), true)

        let lowerOpenUpperExcludedBounds = Bounds(nil, .excluded(10))
        // Two half open
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(nil, .excluded(2))), true)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(nil, .excluded(10))), true)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(nil, .excluded(11))), true)

        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.excluded(2), nil)), true)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.excluded(10), nil)), false)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.included(10), nil)), true)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.included(11), nil)), false)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.excluded(11), nil)), false)

        // Half open and closed
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.excluded(0), .excluded(2))), true)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.excluded(0), .excluded(10))), true)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.excluded(0), .excluded(11))), true)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.included(10), .excluded(11))), true)
        XCTAssertEqual(lowerOpenUpperExcludedBounds.overlaps(Bounds(.excluded(10), .excluded(12))), false)

        // Two closed
    }

    func testUnion() throws {
        let lowerOpenUpperExcludedBounds = Bounds(nil, .excluded(10))

        XCTAssertEqual(lowerOpenUpperExcludedBounds.union(Bounds(nil, .excluded(11))), Bounds(nil, .excluded(11)))
        XCTAssertEqual(lowerOpenUpperExcludedBounds.union(Bounds(nil, .excluded(9))), Bounds(nil, .excluded(10)))
        XCTAssertEqual(lowerOpenUpperExcludedBounds.union(Bounds(nil, .included(10))), Bounds(nil, .included(10)))
        XCTAssertEqual(lowerOpenUpperExcludedBounds.union(Bounds(nil, nil)), Bounds(nil, nil))

        let lowerExcludedUpperOpenBounds = Bounds(.excluded(10), nil)

        XCTAssertEqual(lowerExcludedUpperOpenBounds.union(Bounds(.excluded(11), nil)), Bounds(.excluded(10), nil))
        XCTAssertEqual(lowerExcludedUpperOpenBounds.union(Bounds(.excluded(9), nil)), Bounds(.excluded(9), nil))
        XCTAssertEqual(lowerExcludedUpperOpenBounds.union(Bounds(.included(10), nil)), Bounds(.included(10), nil))
        XCTAssertEqual(lowerExcludedUpperOpenBounds.union(Bounds(nil, nil)), Bounds(nil, nil))

        XCTAssertEqual(Bounds(.excluded(0), .included(12)).union(Bounds(.included(0), .excluded(12))), Bounds(.included(0), .included(12)))
    }

    func testIntersect() throws {
        // TODO: write tests
    }

    func testConditionStatementBoundsUnion() throws {
        let conditionA: some ConditionStatement<TestStruct> = \TestStruct.id < 2 || \TestStruct.id > 10
        XCTAssertEqual(conditionA.bounds(for: \.id), [Bounds(nil, .excluded(2)), Bounds(.excluded(10), nil)])

        let conditionB: some ConditionStatement<TestStruct> = \TestStruct.id <= 2 || \TestStruct.id >= 2
        XCTAssertEqual(conditionB.bounds(for: \.id), [Bounds(nil, nil)])

        let conditionC: some ConditionStatement<TestStruct> = \TestStruct.id < 2 || \TestStruct.id > 2 || \TestStruct.id == 2
        XCTAssertEqual(conditionC.bounds(for: \.id), [Bounds(nil, nil)])

        let conditionD: some ConditionStatement<TestStruct> = \TestStruct.id <= 2 || \TestStruct.id >= 5 || \TestStruct.id == 3
        XCTAssertEqual(conditionD.bounds(for: \.id), [Bounds(nil, .included(2)), Bounds(.included(3), .included(3)), Bounds(.included(5), nil)])
    }

    func testConditionStatementBoundsIntersect() throws {
        let conditionA: some ConditionStatement<TestStruct> = \TestStruct.id < 2 && \TestStruct.id > 10
        XCTAssertEqual(conditionA.bounds(for: \.id), [])

        let conditionB: some ConditionStatement<TestStruct> = \TestStruct.id <= 2 && \TestStruct.id >= 2
        XCTAssertEqual(conditionB.bounds(for: \.id), [Bounds(.included(2), .included(2))])

        let conditionC: some ConditionStatement<TestStruct> = \TestStruct.id < 5 && \TestStruct.id > 2
        XCTAssertEqual(conditionC.bounds(for: \.id), [Bounds(.excluded(2), .excluded(5))])

        let conditionD: some ConditionStatement<TestStruct> = \TestStruct.id >= 2 && \TestStruct.id <= 5 && \TestStruct.id == 3
        XCTAssertEqual(conditionD.bounds(for: \.id), [Bounds(.included(3), .included(3))])
    }

    func testConditionStatementBoundsUnionAndIntersect() throws {
        let conditionA: some ConditionStatement<TestStruct> = (\TestStruct.id < 2 || \TestStruct.id > 10) && (\TestStruct.id == 5 || \TestStruct.id < 1)
        XCTAssertEqual(conditionA.bounds(for: \.id), [Bounds(nil, .excluded(1))])
    }

    func testConditionStatementBoundsInvers() throws {
        let conditionA: some ConditionStatement<TestStruct> = !(\TestStruct.id < 2 || \TestStruct.id > 10)
        XCTAssertEqual(conditionA.bounds(for: \.id), [Bounds(.included(2), .included(10))])

        let conditionB: some ConditionStatement<TestStruct> = !(!(\TestStruct.id < 2 || \TestStruct.id > 10))
        XCTAssertEqual(conditionB.bounds(for: \.id), [Bounds(nil, .excluded(2)), Bounds(.excluded(10), nil)])
    }

    func testConditionStatementBoundsWithMultiKeyPath() throws {
        let conditionA: some ConditionStatement<TestStruct> = !(\TestStruct.id < 2 || \TestStruct.value == "A")
        XCTAssertEqual(conditionA.bounds(for: \.id), nil)

        let conditionB: some ConditionStatement<TestStruct> = \TestStruct.id < 2 || \TestStruct.value == "A"
        XCTAssertEqual(conditionB.bounds(for: \.id), nil)

        let conditionC: some ConditionStatement<TestStruct> = (\TestStruct.id < 2 || \TestStruct.value == "A") && \TestStruct.id > 2
        XCTAssertEqual(conditionC.bounds(for: \.id), [Bounds(.excluded(2), nil)])
    }

}

struct TestStruct: Equatable, Identifiable {
    let id: Int
    var value: String
    var secondValue: Int?
}
