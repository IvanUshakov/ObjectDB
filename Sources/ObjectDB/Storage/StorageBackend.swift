//
//  StorageBackend.swift
//  
//
//  Created by Ivan Ushakov on 03.01.2023.
//

import Foundation

class StorageBackend<Element> {
    var primaryIndex: any Index<Element>
    var indexes: [any Index<Element>] = []

    init(primaryIndex: any Index<Element>, indexes: [any Index<Element>] = []) {
        self.primaryIndex = primaryIndex
        self.indexes = indexes
    }

    // TODO: refactor to cursor
    func insert(_ element: Element) {
        let box = RefBox(value: element)
        primaryIndex.insert(box)
        for index in indexes {
            index.insert(box)
        }
    }

    func execute(request: SelectRequest<Element>) -> [Element] {
        var cursor = executeRequest(request: request)
        var values: [Element] = []

        while let currentCursor = cursor {
            values.append(currentCursor.getValue())
            cursor = cursor?.next()
        }

        return values
    }

    func execute(request: CountRequest<Element>) -> UInt {
        var cursor = executeRequest(request: request)
        var count: UInt = 0

        while cursor != nil {
            count += 1
            cursor = cursor?.next()
        }

        return count
    }

    // TODO: update index keys if need
    func execute(request: UpdateRequest<Element>) -> UInt {
        var cursor = executeRequest(request: request)
        var count: UInt = 0

        while let currentCursor = cursor {
            currentCursor.update(updates: request.keyPathUpdates)
            count += 1
            cursor = cursor?.next()
        }

        return count
    }

    // TODO: support for multi index
    // TODO: delete element from all indexes
    func execute(request: DeleteRequest<Element>) -> UInt {
        var cursor = executeRequest(request: request)
        var count: UInt = 0

        while let currentCursor = cursor {
            currentCursor.delete()
            count += 1
            cursor = cursor?.next()
        }

        return count
    }

}

private extension StorageBackend {

    func executeRequest(request: some Request<Element>) -> (any IndexCursor<Element>)? {
        let index = selectIndex(request: request)
        return execute(index: index, request: request)
    }

    // TODO: implement
    func selectIndex(request: some Request<Element>) -> any Index<Element> {
        return primaryIndex
    }

    func execute(index: some Index<Element>, request: some Request<Element>) -> (any IndexCursor<Element>)? {
        return MultiRangeCursor(index: index, request: request)
    }

}
