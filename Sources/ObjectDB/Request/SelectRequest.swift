//
//  SelectRequest.swift
//  
//
//  Created by Ivan Ushakov on 01.01.2023.
//

import Foundation

class SelectRequest<Element> {
    var count: SearchCount // TODO: move to where statment?
    var whereStatement: WhereStatement<Element>

    init(count: SearchCount, whereStatement: WhereStatement<Element>) {
        self.count = count
        self.whereStatement = whereStatement
    }
}
