//
//  ConditionStatement.swift
//  
//
//  Created by Ivan Ushakov on 04.01.2023.
//

import Foundation

// TODO: add alias for Comparable & Hashable

// MARK: -
// TODO: rename to Constraint?
protocol ConditionStatement<Element>: CustomDebugStringConvertible {
    associatedtype Element
    func validate(element: Element) -> Bool
    func indexRanges<Value>(for keyPath: KeyPath<Element, Value>) -> [IndexRange<Value>]?
}

// MAKR: - 
struct PropertyConditionStatement<Element, Value>: ConditionStatement where Value: Comparable & Hashable {
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

func == <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyConditionStatement<Element, Value> where Value: Comparable & Hashable {
    return PropertyConditionStatement(keyPath: lhs, condition: .equal(rhs))
}

func < <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyConditionStatement<Element, Value> where Value: Comparable & Hashable {
    return PropertyConditionStatement(keyPath: lhs, condition: .less(rhs))
}

func <= <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyConditionStatement<Element, Value> where Value: Comparable & Hashable {
    return PropertyConditionStatement(keyPath: lhs, condition: .lessOrEqual(rhs))
}

func > <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyConditionStatement<Element, Value> where Value: Comparable & Hashable {
    return PropertyConditionStatement(keyPath: lhs, condition: .greater(rhs))
}

func >= <Element, Value>(lhs: KeyPath<Element, Value>, rhs: Value) -> PropertyConditionStatement<Element, Value> where Value: Comparable & Hashable {
    return PropertyConditionStatement(keyPath: lhs, condition: .greaterOrEqual(rhs))
}

func ~= <Element, Value>(lhs: KeyPath<Element, Value>, rhs: some RangeExpression<Value>) -> PropertyConditionStatement<Element, Value> where Value: Comparable & Hashable {
    return PropertyConditionStatement(keyPath: lhs, condition: .between(rhs))
}

// MARK: -
struct OrConditionStatement<Element>: ConditionStatement {
    let lhs: any ConditionStatement<Element>
    let rhs: any ConditionStatement<Element>

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


func || <Element>(lhs: some ConditionStatement<Element>, rhs: some ConditionStatement<Element>) -> OrConditionStatement<Element> {
    OrConditionStatement(lhs: lhs, rhs: rhs)
}

// MARK: -
struct AndConditionStatement<Element>: ConditionStatement {
    let lhs: any ConditionStatement<Element>
    let rhs: any ConditionStatement<Element>

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

func && <Element>(lhs: some ConditionStatement<Element>, rhs: some ConditionStatement<Element>) -> AndConditionStatement<Element> {
    AndConditionStatement(lhs: lhs, rhs: rhs)
}

// MARK: -
struct NotConditionStatement<Element>: ConditionStatement {
    let conditionStatement: any ConditionStatement<Element>

    var debugDescription: String {
        "!(\(conditionStatement))"
    }

    func validate(element: Element) -> Bool {
        return !conditionStatement.validate(element: element)
    }

    func indexRanges<Value>(for keyPath: KeyPath<Element, Value>) -> [IndexRange<Value>]? where Value : Comparable & Hashable {
        guard let ranges = conditionStatement.indexRanges(for: keyPath) else {
            return nil
        }

        return IndexRange<Value>.inverse(ranges: ranges)
    }
}

prefix func ! <Element>(conditionStatement: some ConditionStatement<Element>) -> NotConditionStatement<Element> {
    return NotConditionStatement(conditionStatement: conditionStatement)
}
