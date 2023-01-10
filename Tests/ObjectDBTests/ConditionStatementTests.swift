import XCTest
@testable import ObjectDB

final class ConditionStatementTests: XCTestCase {

    func testConditionStatementIndexRangeUnion() throws {
        let conditionA: some ConditionStatement<TestStruct> = \TestStruct.id < 2 || \TestStruct.id > 10
        XCTAssertEqual(conditionA.indexRanges(for: \.id), [IndexRange(nil, .excluded(2)), IndexRange(.excluded(10), nil)])

        let conditionB: some ConditionStatement<TestStruct> = \TestStruct.id <= 2 || \TestStruct.id >= 2
        XCTAssertEqual(conditionB.indexRanges(for: \.id), [IndexRange(nil, nil)])

        let conditionC: some ConditionStatement<TestStruct> = \TestStruct.id < 2 || \TestStruct.id > 2 || \TestStruct.id == 2
        XCTAssertEqual(conditionC.indexRanges(for: \.id), [IndexRange(nil, nil)])

        let conditionD: some ConditionStatement<TestStruct> = \TestStruct.id <= 2 || \TestStruct.id >= 5 || \TestStruct.id == 3
        XCTAssertEqual(conditionD.indexRanges(for: \.id), [IndexRange(nil, .included(2)), IndexRange(.included(3), .included(3)), IndexRange(.included(5), nil)])
    }

    func testConditionStatementIndexRangeIntersect() throws {
        let conditionA: some ConditionStatement<TestStruct> = \TestStruct.id < 2 && \TestStruct.id > 10
        XCTAssertEqual(conditionA.indexRanges(for: \.id), [])

        let conditionB: some ConditionStatement<TestStruct> = \TestStruct.id <= 2 && \TestStruct.id >= 2
        XCTAssertEqual(conditionB.indexRanges(for: \.id), [IndexRange(.included(2), .included(2))])

        let conditionC: some ConditionStatement<TestStruct> = \TestStruct.id < 5 && \TestStruct.id > 2
        XCTAssertEqual(conditionC.indexRanges(for: \.id), [IndexRange(.excluded(2), .excluded(5))])

        let conditionD: some ConditionStatement<TestStruct> = \TestStruct.id >= 2 && \TestStruct.id <= 5 && \TestStruct.id == 3
        XCTAssertEqual(conditionD.indexRanges(for: \.id), [IndexRange(.included(3), .included(3))])
    }

    func testConditionStatementIndexRangeUnionAndIntersect() throws {
        let conditionA: some ConditionStatement<TestStruct> = (\TestStruct.id < 2 || \TestStruct.id > 10) && (\TestStruct.id == 5 || \TestStruct.id < 1)
        XCTAssertEqual(conditionA.indexRanges(for: \.id), [IndexRange(nil, .excluded(1))])
    }

    func testConditionStatementIndexRangeInvers() throws {
        let conditionA: some ConditionStatement<TestStruct> = !(\TestStruct.id < 2 || \TestStruct.id > 10)
        XCTAssertEqual(conditionA.indexRanges(for: \.id), [IndexRange(.included(2), .included(10))])

        let conditionB: some ConditionStatement<TestStruct> = !(!(\TestStruct.id < 2 || \TestStruct.id > 10))
        XCTAssertEqual(conditionB.indexRanges(for: \.id), [IndexRange(nil, .excluded(2)), IndexRange(.excluded(10), nil)])
    }

    func testConditionStatementIndexRangeWithMultiKeyPath() throws {
        let conditionA: some ConditionStatement<TestStruct> = !(\TestStruct.id < 2 || \TestStruct.value == "A")
        XCTAssertEqual(conditionA.indexRanges(for: \.id), nil)

        let conditionB: some ConditionStatement<TestStruct> = \TestStruct.id < 2 || \TestStruct.value == "A"
        XCTAssertEqual(conditionB.indexRanges(for: \.id), nil)

        let conditionC: some ConditionStatement<TestStruct> = (\TestStruct.id < 2 || \TestStruct.value == "A") && \TestStruct.id > 2
        XCTAssertEqual(conditionC.indexRanges(for: \.id), [IndexRange(.excluded(2), nil)])
    }

}
