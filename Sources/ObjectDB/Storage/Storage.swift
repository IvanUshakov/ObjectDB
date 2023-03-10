//
//  File.swift
//  
//
//  Created by Ivan Ushakov on 09.08.2022.
//

import Foundation

class Storage<Element> {
    var storageBackend: StorageBackend<Element>

    init(primaryIndex: any Index<Element>, indexes: [any Index<Element>] = []) {
        self.storageBackend = StorageBackend(primaryIndex: primaryIndex, indexes: indexes)
    }

    // TODO: throw if element alrady exists
    func insert(_ element: Element) throws {
        storageBackend.insert(element)
    }

    // TODO: implement
    func insert(_ elements: [Element]) throws {

    }

    // TODO: implement
    // TODO: we need insert by cursor for this
    func insertOrUpdate(_ element: Element) throws {
//        storageBackend.insert(element)
    }

    // TODO: implement
    func insertOrUpdate(_ elements: [Element]) throws {

    }

    func first() -> Element? {
        return RequestBuilder(storageBackend: storageBackend).first()
    }

    func first(_ count: UInt) -> [Element] {
        return RequestBuilder(storageBackend: storageBackend).first(count)
    }

    func all() -> [Element] {
        return RequestBuilder(storageBackend: storageBackend).all()
    }

    func clear() -> UInt {
        return RequestBuilder(storageBackend: storageBackend).delete()
    }

    func `where`<Value>(_ keyPath: KeyPath<Element, Value>, _ condition: Condition<Value>) -> RequestBuilder<Element> {
        return RequestBuilder(
            storageBackend: storageBackend,
            expression: PropertyExpression(keyPath: keyPath, condition: condition)
        )
    }

    func `where`(_ expression: some Expression<Element>) -> RequestBuilder<Element> {
        return RequestBuilder(storageBackend: storageBackend, expression: expression)
    }

}
