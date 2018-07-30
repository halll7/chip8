//
//  Array+Extension.swift
//  chip8
//
//  Created by Leigh Hall on 30/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import Foundation

extension Array {
    subscript(index: Byte) -> Element {
        get {
            return self[Int(index)]
        }
        set {
            self[Int(index)] = newValue
        }
    }
}
