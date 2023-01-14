//
//  WhereStatement.swift
//  
//
//  Created by Ivan Ushakov on 01.01.2023.
//

import Foundation

// TODO: rename
enum SearchCount {
    case first(_ count: UInt) // TODO: implement in Storage
    case all
}

// TODO: add order by, skip and take count (only for ordered request)
// TODO: rename to Query?
final class WhereStatement<Element> {
    let storageBackend: StorageBackend<Element>
    let expression: (any Expression<Element>)?

    init(storageBackend: StorageBackend<Element>, expression: (any Expression<Element>)?) {
        self.storageBackend = storageBackend
        self.expression = expression
    }

    init(storageBackend: StorageBackend<Element>) {
        self.storageBackend = storageBackend
        self.expression = nil
    }

    // TODO: implement
    func skip(_ count: UInt) -> Self {
        return self
    }

    func first(_ count: UInt) -> [Element] {
        let request = SelectRequest(count: .first(count), whereStatement: self)
        return storageBackend.execute(request: request)
    }

    func first() -> Element? {
        return first(1).first
    }

    func all() -> [Element] {
        let request = SelectRequest(count: .all, whereStatement: self)
        return storageBackend.execute(request: request)
    }

    func count() -> UInt {
        let request = CountRequest(whereStatement: self)
        return storageBackend.execute(request: request)
    }

    @discardableResult
    func update<Value>(_ keyPath: WritableKeyPath<Element, Value>, value: Value) -> UInt {
        let request = UpdateRequest(whereStatement: self, updates: [UpdateElement(keyPath: keyPath, value: value)])
        return storageBackend.execute(request: request)
    }

    @discardableResult
    func update(_ updates: (UpdateStatement<Element>) -> Void) -> UInt {
        let updateStatement = UpdateStatement<Element>()
        updates(updateStatement)

        let request = UpdateRequest(whereStatement: self, updates: updateStatement.updates)
        return storageBackend.execute(request: request)
    }

    @discardableResult
    func delete() -> UInt {
        let request = DeleteRequest(whereStatement: self)
        return storageBackend.execute(request: request)
    }

}
