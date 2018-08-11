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
    
    var firstNibble: Byte {
        return Byte((code & 0xF000) >> 12)
    }
    
    var x: Byte {
        return Byte((code & 0x0F00) >> 8)
    }
    
    var y: Byte {
        return Byte((code & 0x00F0) >> 4)
    }
    
    var n: Byte {
        return Byte(code & 0x000F)
    }
    
    var nnn: Word {
        return code & 0x0FFF
    }
    
    var nn: Byte {
        return Byte(code & 0x00FF)
    }
    
}
