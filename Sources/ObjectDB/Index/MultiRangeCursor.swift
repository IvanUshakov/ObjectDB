//
//  MultiRangeCursor.swift
//  
//
//  Created by Ivan Ushakov on 09.01.2023.
//

import Foundation

// TODO: use limit/offset from request
struct MultiRangeCursor<I>: IndexCursor where I: Index {
    let index: I
    let request: any Request<Element>

    var ranges: [IndexRange<I.Key>]
    var rangeIndex: Int
    var cursor: (any IndexCursor<Element>)

    init?(index: I, request: some Request<Element>) {
        self.index = index
        self.request = request

        self.ranges = request.expression?.indexRanges(for: index.keyPath) ?? [IndexRange(nil, nil)]
        self.rangeIndex = 0

        guard let cursor = index.enumerate(range: ranges[rangeIndex]) else {
            return nil
        }

        self.cursor = cursor

        skipWhileConditionNotSatisfied()
    }

    mutating func next() -> (any IndexCursor<I.Element>)? {
        if let newCursor = cursor.next() {
            self.cursor = newCursor
            return skipWhileConditionNotSatisfied()
        }

        rangeIndex += 1
        guard rangeIndex < ranges.endIndex else {
            return nil
        }

        if let newCursor = index.enumerate(range: ranges[rangeIndex]) {
            self.cursor = newCursor
            return skipWhileConditionNotSatisfied()
        }

        return nil
    }

    func getValue() -> I.Element {
        cursor.getValue()
    }

    func update(updates: [any KeyPathUpdateType<I.Element>]) {
        cursor.update(updates: updates)
    }

    func delete() {
        cursor.delete()
    }

    // TODO: if we skip to end of range, we need move to next range
    @discardableResult
    mutating func skipWhileConditionNotSatisfied() -> Self? {
        guard let expression = request.expression else {
            return self
        }

        while !expression.validate(element: cursor.getValue()) {
            guard next() != nil else {
                return nil
            }
        }

        return self
    }

}
