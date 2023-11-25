//
//  File.swift
//  
//
//  Created by Ivan Ushakov on 19.11.2023.
//

import Foundation
import XCTest
@testable import ObjectDB

final class SkipListTests: XCTestCase {
    func testSkipList() throws {
        let skipList = SkipList<Int, String>(maxLevel: 8)
        let count = 100
        for _ in 0..<count {
            let key = Int.random(in: 0..<Int.max) % (count)
            let value = Int.random(in: 0..<count)
            skipList.insert(key: key, value: "\(value)")
        }

        skipList.printFullList()
        print("---")

        let context = SkipList<Int, String>.FindContext()
        let node = skipList.find(key: 15, context: context)
        print(context.prev.map { $0.key })
        print(node?.value ?? "unknown")

        //        skipList.insert(key: 1, value: "\(1)")
        //        skipList.insert(key: 5, value: "\(5)")
        //        skipList.insert(key: 3, value: "\(3)")
        //        print(skipList.printAll())
        //        print(skipList.value(for: 3))
    }
}
