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
    
    /// ROMs are loaded from 0x200
    static let ROM_OFFSET: Word = 0x200
    
    private static let FONT_OFFSET: Word = 0x0
    
    private var mem = [Byte].init(repeating: 0, count: 0xFFF)
    
    init() {
        loadFonts()
    }
    
    private func loadFonts() {
        var i = Int(Memory.FONT_OFFSET)
        
        // 0
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // 1
        mem[i] = 0b00100000; i += 1
        mem[i] = 0b01100000; i += 1
        mem[i] = 0b00100000; i += 1
        mem[i] = 0b00100000; i += 1
        mem[i] = 0b01110000; i += 1
        
        // 2
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b00010000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // 3
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b00010000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b00010000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // 4
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b00010000; i += 1
        mem[i] = 0b00010000; i += 1
        
        // 5
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b00010000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // 6
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // 7
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b00010000; i += 1
        mem[i] = 0b00100000; i += 1
        mem[i] = 0b01000000; i += 1
        mem[i] = 0b01000000; i += 1
        
        // 8
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // 9
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b00010000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // A
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b10010000; i += 1
        
        // B
        mem[i] = 0b11100000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11100000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11100000; i += 1
        
        // C
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // D
        mem[i] = 0b11100000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b10010000; i += 1
        mem[i] = 0b11100000; i += 1
        
        // E
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b11110000; i += 1
        
        // F
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b11110000; i += 1
        mem[i] = 0b10000000; i += 1
        mem[i] = 0b10000000
    }
    
    func loadRom(from romLocation: String) -> Bool {
        guard let data = NSData(contentsOfFile: romLocation) else {
            print("failed to load rom from \(romLocation)")
            return false
        }
        
        guard data.length <= (0xFFF - Memory.ROM_OFFSET) else {
            print("rom too big (\(data.length) bytes)")
            return false
        }
        
        data.getBytes(&mem[Int(Memory.ROM_OFFSET)], length: data.length)
        
        print("+++ loaded ROM: \n \(asHexString(from: 0, to: mem.count - 1))")
        
        return true
    }
    
    func spriteAddress(forChar char: Byte) -> Word {
        let index = Word(char & 0x0F)
        return Memory.FONT_OFFSET + index
    }
    
    func opCode(at: Word) -> Opcode {
        let word = (Word(mem[Int(at)]) << 8) | Word(mem[Int(at + 1)])
        return Opcode(withWord: word)
    }
    
    func byte(at: Word) -> Byte {
        return mem[Int(at)]
    }
    
    func storeBCD(of byte: Byte, at location: Word) {
        let index = Int(location)
        mem[index] = byte / 100
        mem[index + 1] = (byte / 10) % 10
        mem[index + 2] = byte % 10
    }
    
    func store(values: [Byte], from location: Word) {
        var offset = Int(location)
        values.forEach {
            mem[offset] = $0
            offset += 1
        }
    }
    
    func asHexString(from: Int, to: Int) -> String {
        guard to >= from, to < mem.count else {
            return "invalid args"
        }
        
        var i = from
        var hex = ""
        while i <= to {
            if (i % 16 == 0) {
                hex.append("\n\(String(format: "%03hhhX) ", i))")
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
