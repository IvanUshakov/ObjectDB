//
//  File.swift
//  
//
//  Created by Ivan Ushakov on 08.01.2023.
//

import Foundation

struct BPlusTreeCursor<Key, Element>: IndexCursor where Key: Comparable & Hashable {
    var range: IndexRange<Key>

    var leaf: BPlusTreeNode<Key, Element>
    var index: Int

    mutating func next() -> (any IndexCursor<Element>)? {
        index += 1

        if index == leaf.keys.endIndex {
            guard let nextLeaf = leaf.next else {
                return nil
            }

            leaf = nextLeaf
            index = 0
        }

        // TODO: fix !greater
        // TODO: handle keys.count == 0
        if let upperBound = range.upperBound, !upperBound.greater(key) {
            return nil
        }

        return self
    }

    func getValue() -> Element {
        return refBox.value
    }

    // TODO: what we need to do with cursor after deleting element
    func delete() {
        leaf.delete(index: index)
    }

    func update(updates: [any KeyPathUpdateType<Element>]) {
        for update in updates {
            update.apply(to: &refBox.value)
        }
    }

}

private extension BPlusTreeCursor {

    var key: Key {
        leaf.keys[index]
    }

    var refBox: RefBox<Element> {
        leaf.values[index]
    }

}
