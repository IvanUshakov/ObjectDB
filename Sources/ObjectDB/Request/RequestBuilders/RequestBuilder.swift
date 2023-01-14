//
//  RequestBuilder.swift
//  
//
//  Created by Ivan Ushakov on 01.01.2023.
//

import Foundation

// TODO: add order by, skip and take count (only for ordered request)
final class RequestBuilder<Element> {
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
        // TODO: use offset
        let request = SelectRequest(expression: expression, limit: count, offset: nil)
        return storageBackend.execute(request: request)
    }

    func first() -> Element? {
        return first(1).first
    }

    func all() -> [Element] {
        // TODO: use offset
        let request = SelectRequest(expression: expression, limit: nil, offset: nil)
        return storageBackend.execute(request: request)
    }

    func count() -> UInt {
        // TODO: use limit offset
        let request = CountRequest(expression: expression, limit: nil, offset: nil)
        return storageBackend.execute(request: request)
    }

    @discardableResult
    func update<Value>(_ keyPath: WritableKeyPath<Element, Value>, value: Value) -> UInt {
        // TODO: use limit offset
        let request = UpdateRequest(expression: expression, keyPathUpdates: [KeyPathUpdate(keyPath: keyPath, value: value)], limit: nil, offset: nil)
        return storageBackend.execute(request: request)
    }

    @discardableResult
    func update(_ updates: (inout UpdateRequestBuilder<Element>) -> Void) -> UInt {
        // TODO: use limit offset
        var updateRequestBuilder = UpdateRequestBuilder<Element>()
        updates(&updateRequestBuilder)

        let request = UpdateRequest(expression: expression, keyPathUpdates: updateRequestBuilder.keyPathUpdates, limit: nil, offset: nil)
        return storageBackend.execute(request: request)
    }

    @discardableResult
    func delete() -> UInt {
        // TODO: use limit offset
        let request = DeleteRequest(expression: expression, limit: nil, offset: nil)
        return storageBackend.execute(request: request)
    }

}
