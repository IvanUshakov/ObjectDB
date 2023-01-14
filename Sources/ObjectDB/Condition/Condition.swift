//
//  Condition.swift
//  
//
//  Created by Ivan Ushakov on 06.01.2023.
//

import Foundation

// TODO: add alias for Comparable & Hashable
// TODO: did we realy need constraint Value to Comparable & Hashable in whole lib?

enum Condition<Value>: CustomDebugStringConvertible where Value: Comparable & Hashable {
    case less(_ conditionValue: Value)
    case lessOrEqual(_ conditionValue: Value)

    case greater(_ conditionValue: Value)
    case greaterOrEqual(_ conditionValue: Value)

    case between(_ range: IndexRange<Value>)

    case equal(_ conditionValue: Value)
    case notEqual(_ conditionValue: Value)

    case `in`(_ conditionValues: Set<Value>)
    case notIn(_ conditionValues: Set<Value>)

    // TODO: write why we need this
    static func between(_ range: some RangeExpression<Value>) -> Self {
        if let range = range as? Range<Value> {
            return .between(IndexRange(.included(range.lowerBound), .excluded(range.upperBound)))
        }

        if let range = range as? ClosedRange<Value> {
            return .between(IndexRange(.included(range.lowerBound), .included(range.upperBound)))
        }

        if let range = range as? PartialRangeUpTo<Value> {
            return .between(IndexRange(nil, .excluded(range.upperBound)))
        }

        if let range = range as? PartialRangeThrough<Value> {
            return .between(IndexRange(nil, .included(range.upperBound)))
        }

        if let range = range as? PartialRangeFrom<Value> {
            return .between(IndexRange(.included(range.lowerBound), nil))
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
            case let .between(range):
                return "in (\(range))"
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

    var indexRanges: [IndexRange<Value>] {
        switch self {
            case let .less(conditionValue):
                return [IndexRange(nil, .excluded(conditionValue))]
            case let .lessOrEqual(conditionValue):
                return [IndexRange(nil, .included(conditionValue))]
            case let .greater(conditionValue):
                return [IndexRange(.excluded(conditionValue), nil)]
            case let .greaterOrEqual(conditionValue):
                return [IndexRange(.included(conditionValue), nil)]
            case let .between(range):
                return [range]
            case let .equal(conditionValue):
                return [IndexRange(.included(conditionValue), .included(conditionValue))]
            case let .notEqual(conditionValue):
                return [IndexRange(nil, .excluded(conditionValue)), IndexRange(.excluded(conditionValue), nil)]
            case let .in(conditionValues):
                return conditionValues.map { IndexRange(.included($0), .included($0)) }
            case let .notIn(conditionValues):
                var (ranges, prevRange) = conditionValues.reduce(into: (ranges: [IndexRange<Value>](), prevRange: nil as IndexRange<Value>?)) {
                    let newRange = IndexRange($0.prevRange?.upperBound, .excluded($1))
                    $0.ranges.append(newRange)
                    $0.prevRange = newRange
                }

                ranges.append(IndexRange(prevRange?.upperBound, nil))

                return ranges
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

            case let .between(range):
                return range.contains(value)

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
