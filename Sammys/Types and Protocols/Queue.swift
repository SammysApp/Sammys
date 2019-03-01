//
//  Queue.swift
//  Sammys
//
//  Created by Natanel Niazoff on 3/1/19.
//  Copyright © 2019 Natanel Niazoff. All rights reserved.
//

import Foundation

struct Queue<Element> {
    private var array = [Element]()
    
    var isEmpty: Bool { return array.isEmpty }
    
    mutating func enqueue(_ newElement: Element) {
        array.append(newElement)
    }
    
    mutating func dequeue() -> Element? {
        if isEmpty { return nil }
        else { return array.removeFirst() }
    }
}
