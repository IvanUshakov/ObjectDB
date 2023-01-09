//
//  File.swift
//  
//
//  Created by Ivan Ushakov on 02.01.2023.
//

import Foundation

class DeleteRequest<Element> {
    var whereStatement: WhereStatement<Element>

    init(whereStatement: WhereStatement<Element>) {
        self.whereStatement = whereStatement
    }
}
