//
//  UpdateRequest.swift
//  
//
//  Created by Ivan Ushakov on 01.01.2023.
//

import Foundation

class UpdateRequest<Element> {

    var whereStatement: WhereStatement<Element>
    var updates: [AnyKeyPath: any UpdateElementType<Element>]

    init(whereStatement: WhereStatement<Element>, updates: [any UpdateElementType<Element>]) {
        self.whereStatement = whereStatement
        self.updates = updates.reduce(into: [:]) {
            $0[$1.anyKeyPath] = $1
        }
    }

}

protocol UpdateElementType<Element> {
    associatedtype Element
    associatedtype Value

    var keyPath: WritableKeyPath<Element, Value> { get }
    var value: Value { get }
}

extension UpdateElementType {

    var anyKeyPath: AnyKeyPath {
        return keyPath
    }

}

// TODO: rename
class UpdateElement<Element, Value>: UpdateElementType {
    let keyPath: WritableKeyPath<Element, Value>
    let value: Value

    init(keyPath: WritableKeyPath<Element, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }
}
