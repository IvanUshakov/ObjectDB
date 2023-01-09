//
//  BPlusTreeNode.swift
//
//
//  Created by Ivan Ushakov on 29.12.2022.
//

import Foundation

// TODO: add capacity and count fileds ?
final class BPlusTreeNode<Key, Value> where Key: Comparable {
    var parent: BPlusTreeNode<Key, Value>?
    var prev: BPlusTreeNode<Key, Value>?
    var next: BPlusTreeNode<Key, Value>?

    var keys: [Key] = []
    var children: [BPlusTreeNode] = []
    var values: [Value] = []

    var isLeaf: Bool {
        children.isEmpty
    }

    init() {}

    init(key: Key, value: Value) {
        keys.append(key)
        values.append(value)
    }

    func findIndex(key: Key) -> Int {
        if let first = keys.first, key < first {
            return keys.startIndex
        }

        if let last = keys.last, key > last {
            return keys.endIndex
        }

        return keys.firstIndex { $0 <= key } ?? keys.endIndex
    }

    func add(key: Key, value: Value) {
        let index = findIndex(key: key)
        keys.insert(key, at: index)
        values.insert(value, at: index)
    }

    func split() {
        let left = BPlusTreeNode<Key, Value>()
        let right = BPlusTreeNode<Key, Value>()

        let mid = (keys.endIndex - keys.startIndex) / 2
        left.keys = Array(keys[keys.startIndex..<mid])
        if isLeaf {
            left.values = Array(values[values.startIndex..<mid])
        } else {
            left.children = Array(children[children.startIndex..<mid])
        }
        left.parent = self
        left.prev = prev
        left.next = right
        left.prev?.next = left

        for child in left.children {
            child.parent = left
        }

        right.keys = Array(keys[mid..<keys.endIndex])
        if isLeaf {
            right.values = Array(values[mid..<values.endIndex])
        } else {
            right.children = Array(children[mid..<children.endIndex])
        }
        right.parent = self
        right.prev = left
        right.next = next
        right.next?.prev = right

        for child in right.children {
            child.parent = right
        }

        self.children = [left, right]
        self.values = []
        self.keys = [self.keys[mid]]
    }

}
