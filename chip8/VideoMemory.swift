//
//  VideoMemory.swift
//  chip8
//
//  Created by Leigh Hall on 28/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import Foundation

class VideoMemory {
    
    private let maskFirst64: UInt64 = 0x8000000000000000
    private let maskFirst8: Byte = 0x80
    
    private var mem: [UInt64]
    
    init() {
        mem = [UInt64].init(repeating: 0x0, count: 31)
    }
    
    func clear() {
        mem = [UInt64].init(repeating: 0x0, count: 31)
    }
    
    /// returns true if any video bits were flipped
    func writePixels(fromByte byte: Byte, atX x: Int, y: Int) -> Bool {
        var flip = false

        for bitIndex in (0...7) {
            let bitWasOn = ((mem[y] << x) & maskFirst64) == maskFirst64
            let bitIsOn = ((byte << bitIndex) & maskFirst8) == maskFirst8
            flip = flip || (bitWasOn != bitIsOn)
            let newBitMask = maskFirst64 >> (x + bitIndex)
            if bitIsOn {
                mem[y] |= newBitMask
            } else {
                mem[y] &= ~newBitMask
            }
        }
        
        return flip
    }
}