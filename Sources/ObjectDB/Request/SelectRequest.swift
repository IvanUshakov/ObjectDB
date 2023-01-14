//
//  SelectRequest.swift
//  
//
//  Created by Ivan Ushakov on 01.01.2023.
//

import Foundation

struct SelectRequest<Element>: Request {
    let expression: (any Expression<Element>)?
    let limit: UInt?
    let offset: UInt?
}
