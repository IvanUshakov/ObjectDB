//
//  UpdateRequestBuilder.swift
//  
//
//  Created by Ivan Ushakov on 04.01.2023.
//

import Foundation

struct UpdateRequestBuilder<Element> {
    var keyPathUpdates = [any KeyPathUpdateType<Element>]()

    mutating func set<Value>(_ keyPath: WritableKeyPath<Element, Value>, value: Value) {
        keyPathUpdates.append(KeyPathUpdate(keyPath: keyPath, value: value))
    }
}
