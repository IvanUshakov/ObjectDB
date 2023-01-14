//
//  UpdateRequest.swift
//  
//
//  Created by Ivan Ushakov on 01.01.2023.
//

import Foundation

struct UpdateRequest<Element>: Request {
    let expression: (any Expression<Element>)?
    let keyPathUpdates: [any KeyPathUpdateType<Element>]
    let limit: UInt?
    let offset: UInt?
}

protocol KeyPathUpdateType<Element> {
    associatedtype Element
    var anyKeyPath: AnyKeyPath { get }
    func apply(to element: inout Element)
}

struct KeyPathUpdate<Element, Value>: KeyPathUpdateType {
    let keyPath: WritableKeyPath<Element, Value>
    let value: Value

    var anyKeyPath: AnyKeyPath {
        return keyPath
    }

    init(keyPath: WritableKeyPath<Element, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }

    func apply(to element: inout Element) {
        element[keyPath: keyPath] = value
    }
}
