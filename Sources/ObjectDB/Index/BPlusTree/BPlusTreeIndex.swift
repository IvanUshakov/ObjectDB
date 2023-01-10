//
//  BPlusTreeIndex.swift
//  
//
//  Created by Ivan Ushakov on 05.01.2023.
//

import Foundation

class BPlusTreeIndex<Key, Element>: Index where Key: Comparable & Hashable {
    let order: UInt

    var keyPath: KeyPath<Element, Key>
    lazy var root: BPlusTreeNode<Key, Element> = BPlusTreeNode<Key, Element>(index: self)

    init(keyPath: KeyPath<Element, Key>, order: UInt = 5) {
        self.keyPath = keyPath
        self.order = order
    }

    func insert(_ box: RefBox<Element>) {
        let key = box.value[keyPath: keyPath]
        findLeaf(node: root, key: key)
            .add(key: key, value: box)
    }

    func enumerate(range: IndexRange<Key>) -> (any IndexCursor<Element>)? {
        guard let leaf = findLeaf(range: range) else {
            return nil
        }

        return BPlusTreeCursor(range: range, leaf: leaf, index: 0)
    }

    func printTree() {
        root.printTree()
    }

}

// MARK: - Find nodes
private extension BPlusTreeIndex {

    // TODO: support left and right bound of range for ordering
    func findLeaf(range: IndexRange<Key>) -> BPlusTreeNode<Key, Element>? {
        if let lowerBound = range.lowerBound {
            return findLeaf(node: root, key: lowerBound.value) // TODO: handle include in bound
        } else {
            return findMostLeftLeaf()
        }
    }

    func findMostLeftLeaf() -> BPlusTreeNode<Key, Element>? {
        var node: BPlusTreeNode<Key, Element>? = root
        while node?.isLeaf == false {
            node = node?.children.first
        }

        return node
    }

    func findLeaf(node: BPlusTreeNode<Key, Element>, key: Key) -> BPlusTreeNode<Key, Element> {
        var node = node
        while !node.isLeaf {
            node = findChild(node: node, key: key)
        }

        return node
    }

    func findChild(node: BPlusTreeNode<Key, Element>, key: Key) -> BPlusTreeNode<Key, Element> {
        for i in node.keys.indices {
            if node.keys[i] > key {
                return node.children[i]
            }
        }

        return node.children[node.children.endIndex - 1]
    }

}
