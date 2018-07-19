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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

