//
//  UpdateStatement.swift
//  
//
//  Created by Ivan Ushakov on 04.01.2023.
//

import Foundation

class UpdateStatement<Element> {
    var updates = [any UpdateElementType<Element>]()

    func set<Value>(_ keyPath: WritableKeyPath<Element, Value>, value: Value) {
        updates.append(UpdateElement(keyPath: keyPath, value: value))
    }
}
