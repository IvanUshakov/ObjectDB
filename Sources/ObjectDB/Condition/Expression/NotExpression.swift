//
//  NotExpression.swift
//  
//
//  Created by Ivan Ushakov on 14.01.2023.
//

import Foundation

struct NotExpression<Element>: Expression {
    let expression: any Expression<Element>

    var debugDescription: String {
        "!(\(expression))"
    }

    func validate(element: Element) -> Bool {
        return !expression.validate(element: element)
    }

    func indexRanges<Value>(for keyPath: KeyPath<Element, Value>) -> [IndexRange<Value>]? where Value : Comparable & Hashable {
        guard let ranges = expression.indexRanges(for: keyPath) else {
            return nil
        }

        return IndexRange<Value>.inverse(ranges: ranges)
    }
}

prefix func ! <Element>(expression: some Expression<Element>) -> NotExpression<Element> {
    return NotExpression(expression: expression)
}
