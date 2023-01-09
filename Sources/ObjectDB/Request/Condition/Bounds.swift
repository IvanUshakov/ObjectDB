//
//  Bounds.swift
//  
//
//  Created by Ivan Ushakov on 06.01.2023.
//

import Foundation

// We can't use std RangeExpression because we need more flexable behavior
struct Bounds<Value>: Equatable where Value: Comparable & Hashable {
    struct Bound: Equatable {
        let value: Value
        let included: Bool

        static func included(_ value: Value) -> Self {
            .init(value: value, included: true)
        }

        static func excluded(_ value: Value) -> Self {
            .init(value: value, included: false)
        }

        static func min(_ first: Bound, _ second: Bound) -> Bound {
            return (first.value < second.value) || (first.value == second.value && first.included) ? first : second
        }

        static func max(_ first: Bound, _ second: Bound) -> Bound {
            return (first.value > second.value) || (first.value == second.value && first.included) ? first : second
        }

        func lower(_ otherValue: Value) -> Bool {
            return value < otherValue || (value == otherValue && included)
        }

        func greater(_ otherValue: Value) -> Bool {
            return value > otherValue || (value == otherValue && included)
        }
    }

    let lowerBound: Bound?
    let upperBound: Bound?

    init(_ lowerBound: Bound?, _ upperBound: Bound?) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    // TODO: refactor
    static func union(lhs: [Bounds<Value>], rhs: [Bounds<Value>]) -> [Bounds<Value>] {
        let summedBounds = lhs + rhs

        guard lhs.count + rhs.count > 1 else {
            return summedBounds
        }

        let sortedBounds = sort(summedBounds)

        var prevBounds = sortedBounds[0]
        var newBounds = [Bounds<Value>]()
        for index in 1..<sortedBounds.endIndex {
            let currentBounds = sortedBounds[index]

            if prevBounds.overlaps(currentBounds) {
                prevBounds = prevBounds.union(currentBounds)
            } else {
                newBounds.append(prevBounds)
                prevBounds = currentBounds
            }
        }

        newBounds.append(prevBounds)

        return newBounds
    }

    static func intersect(lhs: [Bounds<Value>], rhs: [Bounds<Value>]) -> [Bounds<Value>] {
        guard lhs.count + rhs.count > 1 else {
            return lhs + rhs
        }

        let sortedLhs = sort(lhs)
        let sortedRhs = sort(rhs)

        var newBounds = [Bounds<Value>]()
        var lhsIndex = sortedLhs.startIndex
        var rhsIndex = sortedLhs.startIndex

        while lhsIndex < sortedLhs.endIndex && rhsIndex < sortedRhs.endIndex {
            let lhsBounds = sortedLhs[lhsIndex]
            let rhsBounds = sortedRhs[rhsIndex]

            if lhsBounds.overlaps(rhsBounds) {
                newBounds.append(lhsBounds.intersect(rhsBounds))
            }

            if isLessBound(lhsBounds.upperBound, rhsBounds.upperBound, nillLower: false) {
                lhsIndex += 1
            } else {
                rhsIndex += 1
            }
        }

        return newBounds
    }

    static func inverse(bounds: [Bounds<Value>]) -> [Bounds<Value>] {
        func reverseIncluded(_ bound: Bound?) -> Bound? {
            guard let bound else { return nil }
            return Bound(value: bound.value, included: !bound.included)
        }

        let sortedBounds = sort(bounds)

        var inversedBounds = [Bounds<Value>]()
        var prevUpperBound: Bound?

        for bounds in sortedBounds {
            if bounds.lowerBound != nil {
                inversedBounds.append(Bounds(reverseIncluded(prevUpperBound), reverseIncluded(bounds.lowerBound)))
            }

            prevUpperBound = bounds.upperBound
        }

        if prevUpperBound != nil {
            inversedBounds.append(Bounds(reverseIncluded(prevUpperBound), nil))
        }

        return inversedBounds
    }

    func contains(_ value: Value) -> Bool {
        guard let lowerBound else {
            guard let upperBound else {
                return true
            }

            return upperBound.greater(value)
        }

        guard let upperBound else {
            return lowerBound.lower(value)
        }

        return lowerBound.lower(value) && upperBound.greater(value)
    }

    func overlaps(_ other: Bounds<Value>) -> Bool {
        return lowerBound == nil && other.lowerBound == nil ||
        upperBound == nil && other.upperBound == nil ||
        contains(other.lowerBound) ||
        contains(other.upperBound) ||
        other.contains(lowerBound) ||
        other.contains(upperBound)
    }

    func union(_ other: Bounds<Value>) -> Bounds<Value> {
        return Bounds(Self.min(lowerBound, other.lowerBound, nillLower: true), Self.max(upperBound, other.upperBound, nillGreater: true))
    }

    func intersect(_ other: Bounds<Value>) -> Bounds<Value> {
        return Bounds(Self.max(lowerBound, other.lowerBound, nillGreater: false), Self.min(upperBound, other.upperBound, nillLower: false))
    }

}

// TODO: move static func away
private extension Bounds {

    static func sort(_ bounds: [Bounds<Value>]) -> [Bounds<Value>] {
        bounds.sorted { lhs, rhs in
            return isLessBound(lhs.lowerBound, rhs.lowerBound, nillLower: true)
        }
    }

    // TODO: fix
    static func isLessBound(_ lhs: Bound?, _ rhs: Bound?, nillLower: Bool) -> Bool {
        guard let lhs = lhs else {
            return nillLower
        }

        guard let rhs = rhs else {
            return !nillLower
        }

        if lhs.value == rhs.value {
            return lhs.included
        }

        return lhs.value < rhs.value
    }

    static func min(_ first: Bound?, _ second: Bound?, nillLower: Bool) -> Bound? {
        guard let first else {
            return nillLower ? nil : second
        }

        guard let second else {
            return nillLower ? nil : first
        }

        return Bound.min(first, second)
    }

    static func max(_ first: Bound?, _ second: Bound?, nillGreater: Bool) -> Bound? {
        guard let first else {
            return nillGreater ? nil : second
        }

        guard let second else {
            return nillGreater ? nil : first
        }

        return Bound.max(first, second)
    }

    func contains(_ bound: Bound?) -> Bool {
        guard let bound else {
            return false
        }

        return contains(bound.value)
    }

}
