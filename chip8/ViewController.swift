//
//  ViewController.swift
//  chip8
//
//  Created by Leigh Hall on 17/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    private var emu: Emulator?
    @IBOutlet var graphicsView: GraphicsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) {event in
            self.keyUp(with: event)
            return nil
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {event in
            self.keyDown(with: event)
            return nil
        }
        
        emu = Emulator(withGraphicsView: graphicsView)
        emu!.start()
    }

    override func keyDown(with event: NSEvent) {
        emu?.keyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        emu?.keyUp(with: event)
    }
    
}

