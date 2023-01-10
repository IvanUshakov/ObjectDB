//
//  BPlusTreeNode.swift
//
//
//  Created by Ivan Ushakov on 29.12.2022.
//

import Foundation

// TODO: add capacity and count fileds ?
final class BPlusTreeNode<Key, Element> where Key: Comparable & Hashable {
    weak var index: BPlusTreeIndex<Key, Element>?

    var parent: BPlusTreeNode<Key, Element>?
    var prev: BPlusTreeNode<Key, Element>?
    var next: BPlusTreeNode<Key, Element>?

    var keys: [Key] = []
    var children: [BPlusTreeNode] = []
    var values: [RefBox<Element>] = []

    var isLeaf: Bool {
        children.isEmpty
    }

    init(index: BPlusTreeIndex<Key, Element>?) {
        self.index = index
    }

    func add(key: Key, value: RefBox<Element>) {
        let index = findIndex(key: key)
        keys.insert(key, at: index)
        values.insert(value, at: index)

        if keys.count >= 3 { // TODO: use order from index
            split()
        }
    }

    func delete(index: Int) {
        keys.remove(at: index)
        values.remove(at: index)

        // TODO: get order from index
        // TODO: add to index order to split and order to merge
        let order = 3 / 2

        if keys.count < order - 1 {
            if let prev, prev.keys.count > order - 1 {
                
                // move max item from prev node
                // fix parent keys
            } else if let next, next.keys.count > order - 1 {
                // move min item from next node
                // fix parent keys
            } else {
                if let prev {
                    // merge with prev node
                } else if let next {
                    // merge with next node
                }
            }
        }
    }

    func printTree() {
        print(treeLines().joined(separator:"\n"))
    }

}

private extension BPlusTreeNode {

    func findIndex(key: Key) -> Int {
        if let first = keys.first, key < first {
            return keys.startIndex
        }

        if let last = keys.last, key > last {
            return keys.endIndex
        }

        return keys.firstIndex { $0 <= key } ?? keys.endIndex
    }

    func split() {
        let newNode = BPlusTreeNode<Key, Element>(index: index)

        // Insert new node after current
        newNode.next = next
        newNode.next?.prev = newNode
        newNode.prev = self
        next = newNode

        // Copy second half of keys, children and values to new node
        let mid = (keys.endIndex - keys.startIndex) / 2
        let midKey = keys[mid]
        move(to: newNode, startFrom: mid)

        if let parent {
            // Add new node to parent node of current node
            newNode.parent = parent
            let index = parent.findIndex(key: midKey)
            parent.keys.insert(midKey, at: index)
            parent.children.insert(newNode, at: index + 1)

            // TODO: get order from index
            // TODO: add to index order to split and order to merge
            // Split parent if need
            let order = 3
            if parent.keys.count >= order {
                parent.split()
            }
        } else {
            // Create new root
            let newRoot = BPlusTreeNode(index: index)
            parent = newRoot
            newNode.parent = newRoot

            newRoot.keys = [midKey]
            newRoot.children = [self, newNode]

            index?.root = newRoot
        }
    }

    func move(to newNode: BPlusTreeNode<Key, Element>, startFrom mid: Int) {
        if isLeaf {
            // For leaf copy all keys and value
            newNode.keys = Array(keys[mid..<keys.endIndex])
            keys.removeLast(keys.endIndex - mid)
            newNode.values = Array(values[mid..<values.endIndex])
            values.removeLast(values.endIndex - mid)
        } else {
            // Don't copy mid key for internal node
            newNode.keys = Array(keys[(mid + 1)..<keys.endIndex])
            keys.removeLast(keys.endIndex - mid)
            newNode.children = Array(children[(mid + 1)..<children.endIndex])
            children.removeLast(children.endIndex - mid - 1)
        }

        for child in newNode.children {
            child.parent = newNode
        }
    }

    func treeLines(_ nodeIndent:String="", _ childIndent:String="") -> [String] {
        func label() -> String {
            return (isLeaf ? "leaf: " : "") + keys.map { "\($0)" }.joined(separator: ", ")
        }

        var lines = [nodeIndent + label()]
        for (index, child) in children.enumerated() {
            if index < children.count - 1 {
                lines.append(contentsOf: child.treeLines("┣╸", "┃ ").map { childIndent + $0 } )
            } else {
                lines.append(contentsOf: child.treeLines("┗╸", "  ").map { childIndent + $0 } )
            }
        }

        return lines
    }

}
