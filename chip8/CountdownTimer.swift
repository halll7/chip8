//
//  CountdownTimer.swift
//  chip8
//
//  Created by Leigh Hall on 31/07/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import Foundation

/// Contains a byte whose value is counted down to zero at a specified
/// interval
class CountdownTimer {
    
    var value: Byte {
        didSet {
            if value > 0 {
                reset()
            }
        }
    }
    
    private let interval: TimeInterval
    private var timer: Timer?
    
    init(withInterval interval: TimeInterval) {
        self.value = 0
        self.interval = interval
    }
    
    private func reset() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {_ in
            self.decrement()
        }
    }
    
    private func decrement() {
        if value > 0 {
            value -= 1
        }
        
        if value == 0 {
            timer?.invalidate()
        }
    }
}
