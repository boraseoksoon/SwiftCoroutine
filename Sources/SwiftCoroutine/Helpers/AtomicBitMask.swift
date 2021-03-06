//
//  AtomicBitMask.swift
//  SwiftCoroutine
//
//  Created by Alex Belozierov on 06.04.2020.
//  Copyright © 2020 Alex Belozierov. All rights reserved.
//

private let deBruijn = [00, 01, 48, 02, 57, 49, 28, 03,
                        61, 58, 50, 42, 38, 29, 17, 04,
                        62, 55, 59, 36, 53, 51, 43, 22,
                        45, 39, 33, 30, 24, 18, 12, 05,
                        63, 47, 56, 27, 60, 41, 37, 16,
                        54, 35, 52, 21, 44, 32, 23, 11,
                        46, 26, 40, 15, 34, 20, 31, 10,
                        25, 14, 19, 09, 13, 08, 07, 06]

struct AtomicBitMask {
    
    private var atomic = AtomicInt(value: 0)
    var rawValue: Int { atomic.value }
    var isEmpty: Bool { atomic.value == 0 }
    
    mutating func insert(_ index: Int) {
        atomic.update { $0 | (1 << index) }
    }
    
    mutating func remove(_ index: Int) -> Bool {
        if isEmpty { return false }
        let (new, old) = atomic.update { $0 & ~(1 << index) }
        return new != old
    }
    
    mutating func pop() -> Int? {
        var index: Int!
        atomic.update {
            if $0 == 0 { index = nil; return $0 }
            let uint = UInt(bitPattern: $0)
            let value = uint & (0 &- uint)
            index = deBruijn[Int((value &* 285870213051386505) >> 58)]
            return $0 & ~(1 << index)
        }
        return index
    }
    
    mutating func pop(offset: Int) -> Int? {
        var index: Int!
        atomic.update {
            if $0 == 0 { index = nil; return $0 }
            let uint = UInt(bitPattern: ($0 << offset) + ($0 >> (64 - offset)))
            let value = uint & (0 &- uint)
            index = deBruijn[Int((value &* 285870213051386505) >> 58)] - offset
            if index < 0 { index += 64 }
            return $0 & ~(1 << index)
        }
        return index
    }
    
}
