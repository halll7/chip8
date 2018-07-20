//
//  CPU.swift
//  chip8
//
//  Created by Leigh Hall on 17/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import Foundation

class CPU {
    
    private var registers = [Byte].init(repeating: 0, count: 16)
    private var addressI: Word = 0
    private var pc: Int = 0
    private var stack = Stack<Int>()
    private let mem: Memory
    private var skipNextInstruction = false
    
    init(withMemory mem: Memory) {
        self.mem = mem
    }
    
    func reset() {
        addressI = 0
        pc = Memory.ROM_OFFSET
        registers = [Byte].init(repeating: 0, count: 16)
    }
    
    func startFetchDecodeLoop() {
        while true {
            let opcode = mem.opCode(at: pc)
            pc += 2
            
            if skipNextInstruction {
                skipNextInstruction = false
                continue
            }
            
            let firstDigit = opcode & 0xF000
            switch firstDigit {
                case 0x0000: decodeZeroOpcode(opcode)
                case 0x1000: opJump(opcode)
                case 0x2000: opCallSubroutine(opcode)
                case 0x3000: opSkipIfRegXEqNN(opcode)
                case 0x4000: opSkipIfRegXNotEqNN(opcode)
                case 0x5000: opSkipIfRegXEqRegY(opcode)
                case 0x8000: decodeEightOpcode(opcode)
                default: print("BAD OPCODE \(opcode)")
            }
        }
    }
    
    private func decodeZeroOpcode(_ opcode: Word) {
        
    }
    
    private func decodeEightOpcode(_ opcode: Word) {
        
    }
    
    private func opSkipIfRegXEqRegY(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        skipNextInstruction = (registers[x] == registers[y])
    }
    
    private func opSkipIfRegXEqNN(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let nn = opcode & 0x00FF
        skipNextInstruction = (registers[x] == nn)
    }
    
    private func opSkipIfRegXNotEqNN(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let nn = opcode & 0x00FF
        skipNextInstruction = (registers[x] != nn)
    }
    
    private func opJump(_ opcode: Word) {
        pc = Int(opcode & 0x0FFF)
    }
    
    private func opCallSubroutine(_ opcode: Word) {
        stack.push(pc)
        pc = Int(opcode & 0x0FFF)
    }
}
