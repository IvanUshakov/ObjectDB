//
//  IndexCursor.swift
//  
//
//  Created by Ivan Ushakov on 09.01.2023.
//

import Foundation

protocol IndexCursor<Element> {
    associatedtype Element

    mutating func next() -> (any IndexCursor<Element>)?

    func getValue() -> Element
    func update(updates: [any KeyPathUpdateType<Element>])
    func delete()
}
