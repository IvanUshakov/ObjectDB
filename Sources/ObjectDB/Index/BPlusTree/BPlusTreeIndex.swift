//
//  BPlusTreeIndex.swift
//  
//
//  Created by Ivan Ushakov on 05.01.2023.
//

import Foundation

class BPlusTreeIndex<Key, Element>: Index where Key: Comparable & Hashable {
    let order: UInt // TODO: rename?

    var keyPath: KeyPath<Element, Key>
    var root: BPlusTreeNode<Key, RefBox<Element>> = BPlusTreeNode()

    init(keyPath: KeyPath<Element, Key>, order: UInt = 3) {
        self.keyPath = keyPath
        self.order = order
    }

    func insert(_ box: RefBox<Element>) {
        let key = box.value[keyPath: keyPath]

        var node = findLeaf(node: root, key: key)
        node.add(key: key, value: box)

        while node.keys.count >= order {
            node.split()

            guard let parent = node.parent else {
                break
            }

            node = parent
        }
    }

    func enumerate(bounds: Bounds<Key>) -> (any IndexCursor<Element>)? {
        guard let leaf = findLeafForBounds(bounds: bounds) else {
            return nil
        }

        return BPlusTreeCursor(bounds: bounds, leaf: leaf, index: 0)
    }

}

// MARK: - Find nodes
private extension BPlusTreeIndex {

    func findMostLeftLeaf(node: BPlusTreeNode<Key, RefBox<Element>>) -> BPlusTreeNode<Key, RefBox<Element>>? {
        var node: BPlusTreeNode<Key, RefBox<Element>>? = node
        while node?.isLeaf == false {
            node = node?.children.first
        }

        return node
    }

    func findLeaf(node: BPlusTreeNode<Key, RefBox<Element>>, key: Key) -> BPlusTreeNode<Key, RefBox<Element>> {
        var node = node
        while !node.isLeaf {
            node = findChild(node: node, key: key)
        }

        return node
    }

    func findChild(node: BPlusTreeNode<Key, RefBox<Element>>, key: Key) -> BPlusTreeNode<Key, RefBox<Element>> {
        for i in node.keys.indices {
            if node.keys[i] > key {
                return node.children[i]
            }
        }

        return node.children[node.keys.endIndex]
    }

    // TODO: support left and right bounds for ordering
    func findLeafForBounds(bounds: Bounds<Key>) -> BPlusTreeNode<Key, RefBox<Element>>? {
        if let lowerBound = bounds.lowerBound {
            return findLeaf(node: root, key: lowerBound.value) // TODO: handle include in bound
        } else {
            return findMostLeftLeaf(node: root)
        }
    }

}
