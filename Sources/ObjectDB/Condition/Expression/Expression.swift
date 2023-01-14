//
//  Expression.swift
//  
//
//  Created by Ivan Ushakov on 04.01.2023.
//

import Foundation

protocol Expression<Element>: CustomDebugStringConvertible {
    associatedtype Element
    func validate(element: Element) -> Bool
    func indexRanges<Value>(for keyPath: KeyPath<Element, Value>) -> [IndexRange<Value>]?
}
