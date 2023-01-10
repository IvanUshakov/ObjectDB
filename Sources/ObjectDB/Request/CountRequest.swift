//
//  CountRequest.swift
//  
//
//  Created by Ivan Ushakov on 10.01.2023.
//

import Foundation

class CountRequest<Element> {
    var whereStatement: WhereStatement<Element>

    init(whereStatement: WhereStatement<Element>) {
        self.whereStatement = whereStatement
    }
}
