//
//  Index.swift
//  
//
//  Created by Ivan Ushakov on 30.12.2022.
//

import Foundation

protocol Index<Element> {
    associatedtype Element
    associatedtype Key: Comparable & Hashable

    var keyPath: KeyPath<Element, Key> { get set }

    func insert(_ box: RefBox<Element>) // TODO: use cursor
    func enumerate(bounds: Bounds<Key>) -> (any IndexCursor<Element>)?
}
