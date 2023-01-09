//
//  RefBox.swift
//  
//
//  Created by Ivan Ushakov on 30.12.2022.
//

import Foundation

final class RefBox<T> {
    var value: T

    init(value: T) {
        self.value = value
    }
}
