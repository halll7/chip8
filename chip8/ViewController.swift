//
//  ViewController.swift
//  chip8
//
//  Created by Leigh Hall on 17/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    private let emu = Emulator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emu.start()
    }

    override func keyDown(with event: NSEvent) {
        emu.keyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        emu.keyUp(with: event)
    }
    
}

