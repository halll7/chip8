//
//  Emulator.swift
//  chip8
//
//  Created by Leigh Hall on 17/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import AppKit

class Emulator {
    
    private let cpu = CPU()
    private let mem = Memory()
    
    func start() {
        guard let romLocation = promptForROMFile() else {
            return
        }
        
        guard mem.loadRom(from: romLocation) else {
            return
        }
    }
    
    private func promptForROMFile() -> String? {
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose a ROM file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["bin"];
        
        guard dialog.runModal() == .OK, let path = dialog.url?.path else {
            print("Failed to get rom location")
            return nil
        }

        return path
    }
    
}
