import XCTest
@testable import ObjectDB

final class ObjectDBTests: XCTestCase {

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

    func dtestDelete() throws {
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

}

struct TestStruct: Equatable, Identifiable {
    let id: Int
    var value: String
    var secondValue: Int?
}
