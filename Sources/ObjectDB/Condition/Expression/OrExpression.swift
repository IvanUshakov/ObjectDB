//
//  OrExpression.swift
//  
//
//  Created by Ivan Ushakov on 14.01.2023.
//

import Foundation

struct OrExpression<Element>: Expression {
    let lhs: any Expression<Element>
    let rhs: any Expression<Element>

    var debugDescription: String {
        "\(lhs) || \(rhs)"
    }

    func validate(element: Element) -> Bool {
        lhs.validate(element: element) || rhs.validate(element: element)
    }

    func indexRanges<Value>(for keyPath: KeyPath<Element, Value>) -> [IndexRange<Value>]? where Value : Comparable & Hashable {
        guard let lhsRange = lhs.indexRanges(for: keyPath) else {
            return nil
        }

        guard let rhsRange = rhs.indexRanges(for: keyPath) else {
            return nil
        }

        return IndexRange<Value>.union(lhs: lhsRange, rhs: rhsRange)
    }
}


func || <Element>(lhs: some Expression<Element>, rhs: some Expression<Element>) -> OrExpression<Element> {
    OrExpression(lhs: lhs, rhs: rhs)
}
