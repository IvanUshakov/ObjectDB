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

    // TODO: make private
    // TODO: rename?
    func bounds<Value>(for keyPath: KeyPath<Element, Value>) -> [Bounds<Value>]?
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

    func bounds<V>(for keyPath: KeyPath<Element, V>) -> [Bounds<V>]? {
        guard let condition = condition as? Condition<V>, keyPath == self.keyPath else {
            return nil
        }

        return condition.bounds
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

    func bounds<Value>(for keyPath: KeyPath<Element, Value>) -> [Bounds<Value>]? where Value : Comparable & Hashable {
        guard let lhsBounds = lhs.bounds(for: keyPath) else {
            return nil
        }

        guard let rhsBounds = rhs.bounds(for: keyPath) else {
            return nil
        }

        return Bounds<Value>.union(lhs: lhsBounds, rhs: rhsBounds)
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

    func bounds<Value>(for keyPath: KeyPath<Element, Value>) -> [Bounds<Value>]? where Value: Comparable & Hashable {
        guard let lhsBounds = lhs.bounds(for: keyPath) else {
            return rhs.bounds(for: keyPath)
        }

        guard let rhsBounds = rhs.bounds(for: keyPath) else {
            return lhsBounds
        }

        return Bounds<Value>.intersect(lhs: lhsBounds, rhs: rhsBounds)
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

    func bounds<Value>(for keyPath: KeyPath<Element, Value>) -> [Bounds<Value>]? where Value : Comparable & Hashable {
        guard let bounds = conditionStatement.bounds(for: keyPath) else {
            return nil
        }

        return Bounds<Value>.inverse(bounds: bounds)
    }
}

prefix func ! <Element>(conditionStatement: some ConditionStatement<Element>) -> NotConditionStatement<Element> {
    return NotConditionStatement(conditionStatement: conditionStatement)
}
