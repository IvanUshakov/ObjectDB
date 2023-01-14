//
//  AndExpression.swift
//  
//
//  Created by Ivan Ushakov on 14.01.2023.
//

import Foundation

struct AndExpression<Element>: Expression {
    let lhs: any Expression<Element>
    let rhs: any Expression<Element>

    var debugDescription: String {
        "\(lhs) && \(rhs)"
    }

    func validate(element: Element) -> Bool {
        lhs.validate(element: element) && rhs.validate(element: element)
    }

    func indexRanges<Value>(for keyPath: KeyPath<Element, Value>) -> [IndexRange<Value>]? where Value: Comparable & Hashable {
        guard let lhsRange = lhs.indexRanges(for: keyPath) else {
            return rhs.indexRanges(for: keyPath)
        }

        guard let rhsrange = rhs.indexRanges(for: keyPath) else {
            return lhsRange
        }

        return IndexRange<Value>.intersect(lhs: lhsRange, rhs: rhsrange)
    }
}

func && <Element>(lhs: some Expression<Element>, rhs: some Expression<Element>) -> AndExpression<Element> {
    AndExpression(lhs: lhs, rhs: rhs)
}
