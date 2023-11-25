//
//  File.swift
//  
//
//  Created by Ivan Ushakov on 19.11.2023.
//

import Foundation

final class SkipList<Key, Value> where Key: Comparable {
    var head: Node?

    let maxLevel: Int
    let probability: UInt32

    init(maxLevel: Int = 32, probability: UInt32 = 4) {
        self.maxLevel = maxLevel
        self.probability = probability

        self.head = .init()

        var prevNode = self.head
        for _ in 1..<maxLevel {
            prevNode?.down = Node()
            prevNode = prevNode?.down
        }
    }

    func insert(key: Key, value: Value) {
        let context = FindContext()
        guard let node = find(key: key, context: context) else {
            return // TODO: throw Can't find node for insert
        }

        // update value of already exists node
        guard node.key != key else {
            node.value = value
            return
        }

        // insert node on level 0
        let newNode = Node(key: key, value: value, next: node.next)
        node.next = newNode

        // insert nodes on other levels
        var level = randomLavels()
        var currentNode: Node? = newNode
        while level != 0, !context.prev.isEmpty {
            let last = context.prev.popLast()

            let newNode: Node = .init(key: key, next: last?.next, down: currentNode)
            last?.next = newNode

            currentNode = newNode
            level -= 1
        }
    }

    func randomLavels() -> Int {
        for i in 1..<maxLevel {
            if arc4random_uniform(probability) != 1 {
                return i
            }
        }

        return maxLevel - 1
    }

    func value(for key: Key) -> Value? {
        let context = FindContext()
        guard let node = find(key: key, context: context), node.key == key else {
            return nil
        }

        return node.value
    }

    func delete(for key: Key) {
        let context = FindContext()
        guard let node = find(key: key, context: context), node.key == key else {
            return
        }

    }

    // TODO: save context
    func find(key: Key, context: FindContext) -> Node? {
        var currentNode: Node? = head
        for _ in stride(from: maxLevel - 1, to: 0, by: -1) {
            while currentNode?.next != nil, let nextKey = currentNode?.next?.key, nextKey <= key {
                currentNode = currentNode?.next
            }

            if let currentNode {
                context.prev.append(currentNode)
            }

            currentNode = currentNode?.down
        }

        while currentNode?.next != nil, let nextKey = currentNode?.next?.key, nextKey <= key {
            currentNode = currentNode?.next
        }

        return currentNode
    }

    func printAll() -> String {
        var currentNode: Node? = head
        while currentNode?.down != nil {
            currentNode = currentNode?.down
        }

        var allValues: [String] = []
        while currentNode?.next != nil {
            currentNode = currentNode?.next
            allValues.append("\(currentNode!.key!) = \(currentNode!.value!)")
        }

        return allValues.joined(separator: ", ")
    }

    func printFullList() {
        var perLevel: [Node] = []

        // Create array of all nodes per lavel
        var currentNode: Node? = head
        while currentNode?.down != nil {
            if let currentNode {
                perLevel.append(currentNode)
            }
            currentNode = currentNode?.down
        }
        if let currentNode {
            perLevel.append(currentNode)
        }

        while perLevel.last?.next != nil {
            var string = "|"
            let key = perLevel.last?.key
            for level in 0..<perLevel.count {
                if perLevel[level].key == key {
                    if let key {
                        string.append("\(key)")
                    } else {
                        string.append("    ")
                    }
                    if let next = perLevel[level].next {
                        perLevel[level] = next
                    }
                } else {
                    string.append("    ")
                }

                string.append("|\t\t|")
            }

            print(string)
        }

        var string = "|"
        let key = perLevel.last?.key
        for level in 0..<perLevel.count {
            if perLevel[level].key == key {
                if let key {
                    string.append("\(key)")
                } else {
                    string.append("    ")
                }
                if let next = perLevel[level].next {
                    perLevel[level] = next
                }
            } else {
                string.append("    ")
            }

            string.append("|\t\t|")
        }

        print(string)
    }
}

extension SkipList {
    final class Node {
        var key: Key?
        var value: Value?
        var next: Node?
        var down: Node?

        init(key: Key? = nil, value: Value? = nil, next: Node? = nil, down: Node? = nil) {
            self.key = key
            self.value = value
            self.next = next
            self.down = down
        }
    }
}

extension SkipList {
    final class FindContext {
        var prev: [Node] = []
    }
}
