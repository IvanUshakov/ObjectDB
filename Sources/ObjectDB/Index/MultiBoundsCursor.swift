//
//  MultiBoundsCursor.swift
//  
//
//  Created by Ivan Ushakov on 09.01.2023.
//

import Foundation

struct MultiBoundsCursor<I>: IndexCursor where I: Index {

    let index: I
    let whereStatement: WhereStatement<Element>

    var bounds: [Bounds<I.Key>]
    var boundsIndex: Int
    var cursor: (any IndexCursor<Element>)

    init?(index: I, whereStatement: WhereStatement<Element>) {
        self.index = index
        self.whereStatement = whereStatement

        self.bounds = whereStatement.condition?.bounds(for: index.keyPath) ?? [Bounds(nil, nil)]
        self.boundsIndex = 0

        guard let cursor = index.enumerate(bounds: bounds[boundsIndex]) else {
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

        boundsIndex += 1
        guard boundsIndex < bounds.endIndex else {
            return nil
        }

        if let newCursor = index.enumerate(bounds: bounds[boundsIndex]) {
            self.cursor = newCursor
            return skipWhileConditionNotSatisfied()
        }

        return nil
    }

    func getValue() -> I.Element {
        cursor.getValue()
    }

    func update(updates: [any UpdateElementType<I.Element>]) {
        cursor.update(updates: updates)
    }

    func delete() {
        cursor.delete()
    }

    @discardableResult
    mutating func skipWhileConditionNotSatisfied() -> Self? {
        guard let condition = whereStatement.condition else {
            return self
        }

        while !condition.validate(element: cursor.getValue()) {
            guard next() != nil else {
                return nil
            }
        }

        return self
    }

}
