//
//  Request.swift
//  
//
//  Created by Ivan Ushakov on 14.01.2023.
//

import Foundation

// TODO: add order by
protocol Request<Element> {
    associatedtype Element
    var expression: (any Expression<Element>)? { get }
    var limit: UInt? { get }
    var offset: UInt? { get }
}
