import XCTest
@testable import ObjectDB

final class ExpressionTests: XCTestCase {

    func testConditionStatementIndexRangeUnion() throws {
        let expressionA: some Expression<TestStruct> = \TestStruct.id < 2 || \TestStruct.id > 10
        XCTAssertEqual(expressionA.indexRanges(for: \.id), [IndexRange(nil, .excluded(2)), IndexRange(.excluded(10), nil)])

        let expressionB: some Expression<TestStruct> = \TestStruct.id <= 2 || \TestStruct.id >= 2
        XCTAssertEqual(expressionB.indexRanges(for: \.id), [IndexRange(nil, nil)])

        let expressionC: some Expression<TestStruct> = \TestStruct.id < 2 || \TestStruct.id > 2 || \TestStruct.id == 2
        XCTAssertEqual(expressionC.indexRanges(for: \.id), [IndexRange(nil, nil)])

        let expressionD: some Expression<TestStruct> = \TestStruct.id <= 2 || \TestStruct.id >= 5 || \TestStruct.id == 3
        XCTAssertEqual(expressionD.indexRanges(for: \.id), [IndexRange(nil, .included(2)), IndexRange(.included(3), .included(3)), IndexRange(.included(5), nil)])
    }

    func testConditionStatementIndexRangeIntersect() throws {
        let expressionA: some Expression<TestStruct> = \TestStruct.id < 2 && \TestStruct.id > 10
        XCTAssertEqual(expressionA.indexRanges(for: \.id), [])

        let expressionB: some Expression<TestStruct> = \TestStruct.id <= 2 && \TestStruct.id >= 2
        XCTAssertEqual(expressionB.indexRanges(for: \.id), [IndexRange(.included(2), .included(2))])

        let expressionC: some Expression<TestStruct> = \TestStruct.id < 5 && \TestStruct.id > 2
        XCTAssertEqual(expressionC.indexRanges(for: \.id), [IndexRange(.excluded(2), .excluded(5))])

        let expressionD: some Expression<TestStruct> = \TestStruct.id >= 2 && \TestStruct.id <= 5 && \TestStruct.id == 3
        XCTAssertEqual(expressionD.indexRanges(for: \.id), [IndexRange(.included(3), .included(3))])
    }

    func testConditionStatementIndexRangeUnionAndIntersect() throws {
        let expressionA: some Expression<TestStruct> = (\TestStruct.id < 2 || \TestStruct.id > 10) && (\TestStruct.id == 5 || \TestStruct.id < 1)
        XCTAssertEqual(expressionA.indexRanges(for: \.id), [IndexRange(nil, .excluded(1))])
    }

    func testConditionStatementIndexRangeInvers() throws {
        let expressionA: some Expression<TestStruct> = !(\TestStruct.id < 2 || \TestStruct.id > 10)
        XCTAssertEqual(expressionA.indexRanges(for: \.id), [IndexRange(.included(2), .included(10))])

        let expressionB: some Expression<TestStruct> = !(!(\TestStruct.id < 2 || \TestStruct.id > 10))
        XCTAssertEqual(expressionB.indexRanges(for: \.id), [IndexRange(nil, .excluded(2)), IndexRange(.excluded(10), nil)])
    }

    func testConditionStatementIndexRangeWithMultiKeyPath() throws {
        let expressionA: some Expression<TestStruct> = !(\TestStruct.id < 2 || \TestStruct.value == "A")
        XCTAssertEqual(expressionA.indexRanges(for: \.id), nil)

        let expressionB: some Expression<TestStruct> = \TestStruct.id < 2 || \TestStruct.value == "A"
        XCTAssertEqual(expressionB.indexRanges(for: \.id), nil)

        let expressionC: some Expression<TestStruct> = (\TestStruct.id < 2 || \TestStruct.value == "A") && \TestStruct.id > 2
        XCTAssertEqual(expressionC.indexRanges(for: \.id), [IndexRange(.excluded(2), nil)])
    }

}
