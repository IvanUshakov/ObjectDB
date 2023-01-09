//
//  Condition.swift
//  
//
//  Created by Ivan Ushakov on 06.01.2023.
//

import Foundation

enum Condition<Value>: CustomDebugStringConvertible where Value: Comparable & Hashable {
    case less(_ conditionValue: Value)
    case lessOrEqual(_ conditionValue: Value)

    case greater(_ conditionValue: Value)
    case greaterOrEqual(_ conditionValue: Value)

    case between(_ bounds: Bounds<Value>)

    case equal(_ conditionValue: Value)
    case notEqual(_ conditionValue: Value)

    case `in`(_ conditionValues: Set<Value>)
    case notIn(_ conditionValues: Set<Value>)

    // TODO: write why we need this
    static func between(_ range: some RangeExpression<Value>) -> Self {
        if let range = range as? Range<Value> {
            return .between(Bounds(.included(range.lowerBound), .excluded(range.upperBound)))
        }

        if let range = range as? ClosedRange<Value> {
            return .between(Bounds(.included(range.lowerBound), .included(range.upperBound)))
        }

        if let range = range as? PartialRangeUpTo<Value> {
            return .between(Bounds(nil, .excluded(range.upperBound)))
        }

        if let range = range as? PartialRangeThrough<Value> {
            return .between(Bounds(nil, .included(range.upperBound)))
        }

        if let range = range as? PartialRangeFrom<Value> {
            return .between(Bounds(.included(range.lowerBound), nil))
        }

        // TODO: We should't crash app if Apple adds a new type that conforms to the RangeExpression protocol
        fatalError("Unknown range type")
    }

    var debugDescription: String {
        switch self {
            case let .less(conditionValue):
                return "< \(conditionValue)"
            case let .lessOrEqual(conditionValue):
                return "<= \(conditionValue)"
            case let .greater(conditionValue):
                return "> \(conditionValue)"
            case let .greaterOrEqual(conditionValue):
                return ">= \(conditionValue)"
            case let .between(bounds):
                return "in (\(bounds))"
            case let .equal(conditionValue):
                return "== \(conditionValue)"
            case let .notEqual(conditionValue):
                return "!= \(conditionValue)"
            case let .in(conditionValues):
                return "in [\(conditionValues.sorted())]"
            case let .notIn(conditionValues):
                return "not in [\(conditionValues.sorted())]"
        }
    }

    // TODO: rename to valueRange
    var bounds: [Bounds<Value>] {
        switch self {
            case let .less(conditionValue):
                return [Bounds(nil, .excluded(conditionValue))]
            case let .lessOrEqual(conditionValue):
                return [Bounds(nil, .included(conditionValue))]
            case let .greater(conditionValue):
                return [Bounds(.excluded(conditionValue), nil)]
            case let .greaterOrEqual(conditionValue):
                return [Bounds(.included(conditionValue), nil)]
            case let .between(bounds):
                return [bounds]
            case let .equal(conditionValue):
                return [Bounds(.included(conditionValue), .included(conditionValue))]
            case let .notEqual(conditionValue):
                return [Bounds(nil, .excluded(conditionValue)), Bounds(.excluded(conditionValue), nil)]
            case let .in(conditionValues):
                return conditionValues.map { Bounds(.included($0), .included($0)) }
            case let .notIn(conditionValues):
                var (bounds, prevBounds) = conditionValues.reduce(into: (bounds: [Bounds<Value>](), prevBounds: nil as Bounds<Value>?)) {
                    let newBounds = Bounds($0.prevBounds?.upperBound, .excluded($1))
                    $0.bounds.append(newBounds)
                    $0.prevBounds = newBounds
                }

                bounds.append(Bounds(prevBounds?.upperBound, nil))

                return bounds
        }
    }

    func validate(value: Value) -> Bool {
        switch self {
            case let .less(conditionValue):
                return value < conditionValue
            case let .lessOrEqual(conditionValue):
                return value <= conditionValue

            case let .greater(conditionValue):
                return value > conditionValue
            case let .greaterOrEqual(conditionValue):
                return value >= conditionValue

            case let .between(bounds):
                return bounds.contains(value)

            case let .equal(conditionValue):
                return value == conditionValue
            case let .notEqual(conditionValue):
                return value != conditionValue

            case let .in(conditionValues):
                return conditionValues.contains(value)
            case let .notIn(conditionValues):
                return !conditionValues.contains(value)
        }
    }

}
