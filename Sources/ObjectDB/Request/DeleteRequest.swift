//
//  File.swift
//  
//
//  Created by Ivan Ushakov on 02.01.2023.
//

import Foundation

struct DeleteRequest<Element>: Request {
    let expression: (any Expression<Element>)?
    let limit: UInt?
    let offset: UInt?
}
