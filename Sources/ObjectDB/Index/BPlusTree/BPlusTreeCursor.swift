//
//  File.swift
//  
//
//  Created by Ivan Ushakov on 08.01.2023.
//

import Foundation

struct BPlusTreeCursor<Key, Element>: IndexCursor where Key: Comparable & Hashable {
    var bounds: Bounds<Key>

    var leaf: BPlusTreeNode<Key, RefBox<Element>>
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
        if let upperBound = bounds.upperBound, !upperBound.greater(key) {
            return nil
        }

        return self
    }

    func getValue() -> Element {
        return refBox.value
    }

    func delete() {
        // TODO: implement
    }

    func update(updates: [any UpdateElementType<Element>]) {
        for update in updates {
            self.update(update)
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

    func update(_ update: some UpdateElementType<Element>) {
        refBox.value[keyPath: update.keyPath] = update.value
    }

}
