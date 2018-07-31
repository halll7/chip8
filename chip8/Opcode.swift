//
//  Opcode.swift
//  chip8
//
//  Created by Leigh Hall on 31/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import Foundation

struct Opcode {
    
    private let code: Word
    
    init(withWord word: Word) {
        code = word
    }
    
    func digit1() -> Byte {
        return Byte((code & 0xF000) >> 12)
    }
    
    func digit2() -> Byte {
        return Byte((code & 0x0F00) >> 8)
    }
    
    func digit3() -> Byte {
        return Byte((code & 0x00F0) >> 4)
    }
    
    func digit4() -> Byte {
        return Byte(code & 0x000F)
    }
    
    func lastThreeDigits() -> Word {
        return code & 0x0FFF
    }
    
    func lastTwoDigits() -> Byte {
        return Byte(code & 0x00FF)
    }
    
}
