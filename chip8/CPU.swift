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
    private var pc: Word = 0
    private var stack = Stack<Word>()
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
    
//MARK:- fetch-decode

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
                case 0x1000: op1NNN(opcode)
                case 0x2000: op2NNN(opcode)
                case 0x3000: op3XNN(opcode)
                case 0x4000: op4XNN(opcode)
                case 0x5000: op5XY0(opcode)
                case 0x8000: decodeEightOpcode(opcode)
                case 0x9000: op9XY0(opcode)
                case 0xA000: opANNN(opcode)
                case 0xB000: opBNNN(opcode)
                case 0xC000: opCXNN(opcode)
                default: print("BAD OPCODE \(opcode)")
            }
        }
    }
    
    private func decodeZeroOpcode(_ opcode: Word) {
        let lastThreeDigits = opcode & 0x0FFF
        switch lastThreeDigits {
            case 0x00E0: op00E0(opcode)
            case 0x00EE: op00EE(opcode)
            default: op0NNN(opcode)
        }
    }
    
    private func decodeEightOpcode(_ opcode: Word) {
        let lastDigit = opcode & 0x000F
        switch lastDigit {
        case 0x0: op8XY0(opcode)
        case 0x1: op8XY1(opcode)
        case 0x2: op8XY2(opcode)
        case 0x3: op8XY3(opcode)
        case 0x4: op8XY4(opcode)
        case 0x5: op8XY5(opcode)
        case 0x6: op8XY6(opcode)
        case 0x7: op8XY7(opcode)
        case 0xE: op8XYE(opcode)
        default: print("BAD OPCODE \(opcode)")
        }
    }
    
//MARK:- opcode handlers
    
    /// Sets Vx to the result of a bitwise AND operation on a random number
    /// (0 to 255) and NN.
    private func opCXNN(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let nn = Byte(opcode & 0x00FF)
        let rand = Byte(arc4random_uniform(256))
        registers[x] = nn & rand
    }
    
    /// Jumps to the address NNN plus V0.
    private func opBNNN(_ opcode: Word) {
        pc = (opcode & 0x0FFF) + Word(registers[0])
    }
    
    /// Sets I to the address NNN.
    private func opANNN(_ opcode: Word) {
        addressI = opcode & 0x0FFF
    }
    
    /// Skips the next instruction if Vx doesn't equal Vy.
    private func op9XY0(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        skipNextInstruction = registers[x] != registers[y]
    }
    
    /// set Vx = Vy
    private func op8XY0(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        registers[x] = registers[y]
        
    }
    
    /// set Vx = Vx OR Vy
    private func op8XY1(_ opcode: Word) {
        applyOp(|, forOpcode: opcode)
    }
    
    /// set Vx = Vx AND Vy
    private func op8XY2(_ opcode: Word) {
        applyOp(&, forOpcode: opcode)
    }
    
    /// set Vx = Vx XOR Vy
    private func op8XY3(_ opcode: Word) {
        applyOp(^, forOpcode: opcode)
    }
    
    /// Adds Vy to Vx. VF is set to 1 when there's a carry, and to 0 when there isn't.
    private func op8XY4(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        registers[15] = (registers[x] + registers[y] > 0xF) ? 1 : 0
        registers[x] = (registers[x] + registers[y]) % 0xF
    }
    
    /// Vy is subtracted from Vx. VF is set to 0 when there's a borrow, and 1 when there isn't.
    private func op8XY5(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        if Int(registers[x]) - Int(registers[y]) < 0 {
            registers[15] = 0
            registers[x] = 0xF - (registers[y] - registers[x])
        } else {
            registers[15] = 1
            registers[x] = registers[x] - registers[y]
        }
    }
    
    /// Shifts Vy right by one and stores the result to Vx (Vy remains unchanged).
    /// VF is set to the value of the least significant bit of Vy before the shift
    private func op8XY6(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        registers[15] = registers[y] & 0x1
        registers[x] = registers[y] >> 1
    }
    
    /// Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
    private func op8XY7(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        if Int(registers[y]) - Int(registers[x]) < 0 {
            registers[15] = 0
            registers[x] = 0xF - (registers[x] - registers[y])
        } else {
            registers[15] = 1
            registers[x] = registers[y] - registers[x]
        }
    }
    
    /// Shifts VY left by one and copies the result to VX.
    /// VF is set to the value of the most significant bit of VY before the shift.
    private func op8XYE(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        registers[15] = registers[y] & 0x8
        registers[x] = registers[y] << 1
    }
    
    /// applies the specified operation to Vx and Vy, where x and y are decoded
    /// from the specified opcode bytes. Result stored in Vx.
    private func applyOp(_ op: (Byte, Byte) -> Byte, forOpcode opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        registers[x] = op(registers[x], registers[y])
    }
    
    /// skip instruction if Vx == Vy
    private func op5XY0(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let y = Int(opcode & 0x00F0)
        skipNextInstruction = (registers[x] == registers[y])
    }
    
    /// skip instruction if Vx == NN
    private func op3XNN(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let nn = opcode & 0x00FF
        skipNextInstruction = (registers[x] == nn)
    }
    
    /// skip instruction if Vx != NN
    private func op4XNN(_ opcode: Word) {
        let x = Int(opcode & 0x0F00)
        let nn = opcode & 0x00FF
        skipNextInstruction = (registers[x] != nn)
    }
    
    /// jump to NNN
    private func op1NNN(_ opcode: Word) {
        pc = opcode & 0x0FFF
    }
    
    /// call subroutine
    private func op2NNN(_ opcode: Word) {
        stack.push(pc)
        pc = opcode & 0x0FFF
    }

    /// return from subroutine
    private func op00EE(_ opcode: Word) {
        guard let retAddr = stack.pop() else {
            print("ERROR: failed to return from subroutine, address stack empty.")
            return
        }
        pc = retAddr
    }
    
    /// clear screen
    private func op00E0(_ opcode: Word) {
        //todo
    }
    
    /// call RCA1802 program at NNN
    private func op0NNN(_ opcode: Word) {
        print("ERROR: RCA 1802 not supported.")
    }
    
}
