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
    private let video: VideoMemory
    private let keypad: KeyPad
    private var skipNextInstruction = false
    private var delayTimerValue: Byte = 0
    private var delayTimer: Timer?
    
    init(withMemory mem: Memory, keyPad keypad: KeyPad) {
        self.mem = mem
        self.keypad = keypad
        self.video = VideoMemory()
    }
    
    func reset() {
        addressI = 0
        pc = Memory.ROM_OFFSET
        registers = [Byte].init(repeating: 0, count: 16)
    }
    
//MARK:- fetch-decode

    func startFetchDecodeLoop() {
        //start the delay timer, which counts down at a rate of 60Hz
        delayTimer = Timer.scheduledTimer(withTimeInterval: 0.0166, repeats: true) {_ in
            if self.delayTimerValue > 0 {
                self.delayTimerValue -= 1
            }
        }

        while true {
            let opcode = mem.opCode(at: pc)
            pc += 2
            
            if skipNextInstruction {
                skipNextInstruction = false
                continue
            }
            
            let firstDigit = opcode.digit1()
            switch firstDigit {
                case 0x0: decodeZeroOpcode(opcode)
                case 0x1: op1NNN(opcode)
                case 0x2: op2NNN(opcode)
                case 0x3: op3XNN(opcode)
                case 0x4: op4XNN(opcode)
                case 0x5: op5XY0(opcode)
                case 0x8: decodeEightOpcode(opcode)
                case 0x9: op9XY0(opcode)
                case 0xA: opANNN(opcode)
                case 0xB: opBNNN(opcode)
                case 0xC: opCXNN(opcode)
                case 0xD: opDXYN(opcode)
                case 0xE: decodeEOpcode(opcode)
                case 0xF: decodeFOpcode(opcode)
                default: print("BAD OPCODE \(opcode)")
            }
        }
    }
    
    private func decodeZeroOpcode(_ opcode: Opcode) {
        let lastThreeDigits = opcode.lastThreeDigits()
        switch lastThreeDigits {
            case 0x00E0: op00E0(opcode)
            case 0x00EE: op00EE(opcode)
            default: op0NNN(opcode)
        }
    }
    
    private func decodeEightOpcode(_ opcode: Opcode) {
        let lastDigit = opcode.digit4()
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
    
    private func decodeEOpcode(_ opcode: Opcode) {
        let lastTwoDigits = opcode.lastTwoDigits()
        switch lastTwoDigits {
            case 0x009E: opEX9E(opcode)
            case 0x00A1: opEXA1(opcode)
            default: print("BAD OPCODE \(opcode)")
        }
    }
    
    private func decodeFOpcode(_ opcode: Opcode) {
        let lastTwoDigits = opcode.lastTwoDigits()
        switch lastTwoDigits {
            case 0x0007: opFX07(opcode)
            case 0x000A: opFX0A(opcode)
            case 0x0015: opFX15(opcode)
            case 0x0018: opFX18(opcode)
            case 0x001E: opFX1E(opcode)
            case 0x0029: opFX29(opcode)
            case 0x0033: opFX33(opcode)
            case 0x0055: opFX55(opcode)
            case 0x0065: opFX65(opcode)
            default: print("BAD OPCODE \(opcode)")
        }
    }
    
//MARK:- opcode handlers
    
    /// Sets Vx to the value of the delay timer
    private func opFX07(_ opcode: Opcode) {
        let x = opcode.digit2()
        registers[x] = delayTimerValue
    }
    
    /// A key press is awaited, and then stored in Vx.
    private func opFX0A(_ opcode: Opcode) {
        //todo input
    }
    
    /// Sets the delay timer to Vx.
    private func opFX15(_ opcode: Opcode) {
        let x = opcode.digit2()
        delayTimerValue = registers[x]
    }
    
    /// Sets the sound timer to Vx.
    private func opFX18(_ opcode: Opcode) {
        //todo sound
    }
    
    /// Adds Vx to I. Vf is set to 1 when there is a range overflow (I+Vx>0xFFFF),
    /// and to 0 when there isn't (the overflow flag is an undocumented feature).
    private func opFX1E(_ opcode: Opcode) {
        let x = opcode.digit2()
        let vx = registers[x]
        let sum = UInt32(addressI) + UInt32(vx)
        registers[15] = sum > 0xFFFF ? 1 : 0
        addressI = Word(sum % 0xFFFF)
    }
    
    /// Sets I to the location of the sprite for the character in Vx. Characters
    /// 0-F (in hexadecimal) are represented by a 4x5 font.
    private func opFX29(_ opcode: Opcode) {
        let char = Byte(opcode.digit2())
        addressI = mem.spriteAddress(forChar: char)
    }
    
    /// Stores the binary-coded decimal representation of Vx, with the most significant
    /// of three digits at the address in I, the middle digit at I plus 1, and the least
    /// significant digit at I plus 2. (In other words, take the decimal representation
    /// of VX, place the hundreds digit in memory at location in I, the tens digit at
    /// location I+1, and the ones digit at location I+2.)
    private func opFX33(_ opcode: Opcode) {
        let x = opcode.digit2()
        mem.storeBCD(of: registers[x], at: addressI)
    }
    
    /// Stores V0 to Vx (including Vx) in memory starting at address I. The offset
    /// from I is increased by 1 for each value written, but I itself is left unmodified.
    private func opFX55(_ opcode: Opcode) {
        let x = opcode.digit2()
        var values = [Byte]()
        for index in (0...x) {
            values.append(registers[index])
        }
        mem.store(values: values, from: addressI)
    }
    
    /// Fills V0 to Vx (including Vx) with values from memory starting at address I.
    /// The offset from I is increased by 1 for each value written, but I itself is left
    /// unmodified.
    private func opFX65(_ opcode: Opcode) {
        let x = opcode.digit2()
        for regIndex in (0...x) {
            registers[regIndex] = mem.byte(at: (addressI + Word(regIndex)))
        }
    }
    
    /// Skips the next instruction if the key stored in Vx is pressed.
    private func opEX9E(_ opcode: Opcode) {
        //todo input
    }
    
    /// Skips the next instruction if the key stored in Vx is not pressed.
    private func opEXA1(_ opcode: Opcode) {
        //todo input
    }
    
    /// Draws a sprite at coordinate (Vx, Vy) that has a width of 8 pixels and a height of N pixels.
    /// Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t
    /// change after the execution of this instruction. As described above, Vf is set to 1 if any
    /// screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that
    /// doesn’t happen.
    private func opDXYN(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
        let n = opcode.digit4()
        
        var flipped = false
        for spriteRow in (0..<n) {
            let rowByte = mem.byte(at: addressI + Word(spriteRow))
            flipped = flipped || video.writePixels(fromByte: rowByte, atX: x, y: y + spriteRow)
        }
        
        registers[15] = flipped ? 1 : 0
    }
    
    /// Sets Vx to the result of a bitwise AND operation on a random number
    /// (0 to 255) and NN.
    private func opCXNN(_ opcode: Opcode) {
        let x = opcode.digit2()
        let nn = opcode.lastTwoDigits()
        let rand = Byte(arc4random_uniform(256))
        registers[x] = nn & rand
    }
    
    /// Jumps to the address NNN plus V0.
    private func opBNNN(_ opcode: Opcode) {
        pc = opcode.lastThreeDigits() + Word(registers[0])
    }
    
    /// Sets I to the address NNN.
    private func opANNN(_ opcode: Opcode) {
        addressI = opcode.lastThreeDigits()
    }
    
    /// Skips the next instruction if Vx doesn't equal Vy.
    private func op9XY0(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
        skipNextInstruction = registers[x] != registers[y]
    }
    
    /// set Vx = Vy
    private func op8XY0(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
        registers[x] = registers[y]
        
    }
    
    /// set Vx = Vx OR Vy
    private func op8XY1(_ opcode: Opcode) {
        applyOp(|, forOpcode: opcode)
    }
    
    /// set Vx = Vx AND Vy
    private func op8XY2(_ opcode: Opcode) {
        applyOp(&, forOpcode: opcode)
    }
    
    /// set Vx = Vx XOR Vy
    private func op8XY3(_ opcode: Opcode) {
        applyOp(^, forOpcode: opcode)
    }
    
    /// Adds Vy to Vx. VF is set to 1 when there's a carry, and to 0 when there isn't.
    private func op8XY4(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
        registers[15] = (registers[x] + registers[y] > 0xF) ? 1 : 0
        registers[x] = (registers[x] + registers[y]) % 0xF
    }
    
    /// Vy is subtracted from Vx. VF is set to 0 when there's a borrow, and 1 when there isn't.
    private func op8XY5(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
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
    private func op8XY6(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
        registers[15] = registers[y] & 0x1
        registers[x] = registers[y] >> 1
    }
    
    /// Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
    private func op8XY7(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
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
    private func op8XYE(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
        registers[15] = registers[y] & 0x8
        registers[x] = registers[y] << 1
    }
    
    /// applies the specified operation to Vx and Vy, where x and y are decoded
    /// from the specified opcode bytes. Result stored in Vx.
    private func applyOp(_ op: (Byte, Byte) -> Byte, forOpcode opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
        registers[x] = op(registers[x], registers[y])
    }
    
    /// skip instruction if Vx == Vy
    private func op5XY0(_ opcode: Opcode) {
        let x = opcode.digit2()
        let y = opcode.digit3()
        skipNextInstruction = (registers[x] == registers[y])
    }
    
    /// skip instruction if Vx == NN
    private func op3XNN(_ opcode: Opcode) {
        let x = opcode.digit2()
        let nn = opcode.lastTwoDigits()
        skipNextInstruction = (registers[x] == nn)
    }
    
    /// skip instruction if Vx != NN
    private func op4XNN(_ opcode: Opcode) {
        let x = opcode.digit2()
        let nn = opcode.lastTwoDigits()
        skipNextInstruction = (registers[x] != nn)
    }
    
    /// jump to NNN
    private func op1NNN(_ opcode: Opcode) {
        pc = opcode.lastThreeDigits()
    }
    
    /// call subroutine
    private func op2NNN(_ opcode: Opcode) {
        stack.push(pc)
        pc = opcode.lastThreeDigits()
    }

    /// return from subroutine
    private func op00EE(_ opcode: Opcode) {
        guard let retAddr = stack.pop() else {
            print("ERROR: failed to return from subroutine, address stack empty.")
            return
        }
        pc = retAddr
    }
    
    /// clear screen
    private func op00E0(_ opcode: Opcode) {
        video.clear()
    }
    
    /// call RCA1802 program at NNN
    private func op0NNN(_ opcode: Opcode) {
        print("ERROR: RCA 1802 not supported.")
    }
    
}
