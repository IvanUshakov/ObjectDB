//
//  CountRequest.swift
//  
//
//  Created by Ivan Ushakov on 10.01.2023.
//

import Foundation

struct CountRequest<Element>: Request {
    let expression: (any Expression<Element>)?
    let limit: UInt?
    let offset: UInt?
}
