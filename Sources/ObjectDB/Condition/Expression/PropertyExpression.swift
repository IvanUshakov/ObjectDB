//
//  PropertyExpression.swift
//  
//
//  Created by Ivan Ushakov on 14.01.2023.
//

import Foundation

struct PropertyExpression<Element, Value>: Expression where Value: Comparable & Hashable {
    let keyPath: KeyPath<Element, Value>
    let condition: Condition<Value>

    var debugDescription: String {
        "(\(Element.Type.self)<\(Value.Type.self)> \(condition))"
    }

    func validate(element: Element) -> Bool {
        return condition.validate(value: element[keyPath: keyPath])
    }

    func indexRanges<V>(for keyPath: KeyPath<Element, V>) -> [IndexRange<V>]? {
        guard let condition = condition as? Condition<V>, keyPath == self.keyPath else {
            return nil
        }

        return condition.indexRanges
    }

}

func == <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyExpression<Element, Value> where Value: Comparable & Hashable {
    return PropertyExpression(keyPath: lhs, condition: .equal(rhs))
}

func < <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyExpression<Element, Value> where Value: Comparable & Hashable {
    return PropertyExpression(keyPath: lhs, condition: .less(rhs))
}

func <= <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyExpression<Element, Value> where Value: Comparable & Hashable {
    return PropertyExpression(keyPath: lhs, condition: .lessOrEqual(rhs))
}

func > <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyExpression<Element, Value> where Value: Comparable & Hashable {
    return PropertyExpression(keyPath: lhs, condition: .greater(rhs))
}

func >= <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyExpression<Element, Value> where Value: Comparable & Hashable {
    return PropertyExpression(keyPath: lhs, condition: .greaterOrEqual(rhs))
}

func ~= <Element, Value>(lhs: KeyPath<Element, Value>, rhs: some RangeExpression<Value>) -> PropertyExpression<Element, Value> where Value: Comparable & Hashable {
    return PropertyExpression(keyPath: lhs, condition: .between(rhs))
}
