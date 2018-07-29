//
//  KeyPad.swift
//  chip8
//
//  Created by Leigh Hall on 29/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import AppKit

///
/// Chip8 keypad look like this:
///     ╔═══╦═══╦═══╦═══╗
///     ║ 1 ║ 2 ║ 3 ║ C ║
///     ╠═══╬═══╬═══╬═══╣
///     ║ 4 ║ 5 ║ 6 ║ D ║
///     ╠═══╬═══╬═══╬═══╣
///     ║ 7 ║ 8 ║ 9 ║ E ║
///     ╠═══╬═══╬═══╬═══╣
///     ║ A ║ 0 ║ B ║ F ║
///     ╚═══╩═══╩═══╩═══╝
///
/// We map it to these mac keys:
///     ╔═══╦═══╦═══╦═══╗
///     ║ 1 ║ 2 ║ 3 ║ 4 ║
///     ╠═══╬═══╬═══╬═══╣
///     ║ Q ║ W ║ E ║ R ║
///     ╠═══╬═══╬═══╬═══╣
///     ║ A ║ S ║ D ║ F ║
///     ╠═══╬═══╬═══╬═══╣
///     ║ Z ║ X ║ C ║ V ║
///     ╚═══╩═══╩═══╩═══╝
///
class KeyPad {
    
    // 16 keys, 0-F, in that order. True if the corresponding key is down,
    // false otherwise.
    private var keys: [Bool]
    
    init() {
        keys = [Bool].init(repeating: false, count: 16)
    }
   
    func keyDown(with event: NSEvent) {
        if let keyIndex = index(forKeyEvent: event) {
            keys[keyIndex] = true
        }
    }
    
    func keyUp(with event: NSEvent) {
        if let keyIndex = index(forKeyEvent: event) {
            keys[keyIndex] = false
        }
    }
    
    /// returns the 'keys' array index corresponding to the key pressed
    // in the specified event. Returns nil if it's not a keypad key.
    private func index(forKeyEvent ev: NSEvent) -> Int? {
        guard let keyString = ev.charactersIgnoringModifiers?.uppercased() else {
            return nil
        }
        
        var keyIndex: Int?
        switch keyString {
            case "1": keyIndex = 0x1
            case "2": keyIndex = 0x2
            case "3": keyIndex = 0x3
            case "4": keyIndex = 0xC
            
            case "Q": keyIndex = 0x4
            case "W": keyIndex = 0x5
            case "E": keyIndex = 0x6
            case "R": keyIndex = 0xD
            
            case "A": keyIndex = 0x7
            case "S": keyIndex = 0x8
            case "D": keyIndex = 0x9
            case "F": keyIndex = 0xE
            
            case "Z": keyIndex = 0xA
            case "X": keyIndex = 0x0
            case "C": keyIndex = 0xB
            case "V": keyIndex = 0xF
            
            default: return nil
        }

        return keyIndex
    }
    
}
