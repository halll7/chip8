//
//  Memory.swift
//  chip8
//
//  Created by Leigh Hall on 17/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import AppKit

typealias Word = UInt16
typealias Byte = UInt8

class Memory {
    
    private var mem = [Byte].init(repeating: 0, count: 0xFFF)
    
    func loadRom(from romLocation: String) -> Bool {
        guard let data = NSData(contentsOfFile: romLocation) else {
            print("failed to load rom from \(romLocation)")
            return false
        }
        
        guard data.length <= 0xFFF else {
            print("rom too big (\(data.length) bytes)")
            return false
        }
        
        data.getBytes(&mem, length: data.length)
        
        print("+++ loaded ROM: \n \(asHexString(from: 0, to: data.length - 1))")
        
        return true
    }
    
    func asHexString(from: Int, to: Int) -> String {
        guard to >= from, to < mem.count else {
            return "invalid args"
        }
        
        var i = from
        var hex = ""
        while i <= to {
            if (i % 16 == 0) {
                hex.append("\n")
            } else if (i % 8 == 0) {
                hex.append("  ")
            }
            hex.append(String(format: "%02hhX ", mem[i]))
            i += 1
        }
        hex.append("\n")
        return hex
    }
}
