//
//  GraphicsView.swift
//  chip8
//
//  Created by Leigh Hall on 06/08/2018.
//  Copyright © 2018 Leigh Hall. All rights reserved.
//

import AppKit

protocol GraphicsViewDataSource: class {
    /// return an array of 32 UInt64s. Each element represents a row, from
    /// to to bottom.
    func graphicsData() -> [UInt64]
}

class GraphicsView: NSView {

    weak var dataSource: GraphicsViewDataSource?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let data = dataSource?.graphicsData() else {
            return
        }
        
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        let pixelWidth: CGFloat = self.bounds.size.width / 64
        let pixelHeight: CGFloat = self.bounds.size.height / 32
        
        context.saveGState()
        for rowIndex in (0..<data.count) {
            let rowData = data[rowIndex]
            for col in (0..<64) {
                let color: CGColor = bitIsOnAtIndex(col, in: rowData) ? .white : .black
                context.setFillColor(color)
                let pixelX = pixelWidth * CGFloat(col)
                let pixelY = self.bounds.size.height - (CGFloat(rowIndex + 1) * pixelHeight)
                let pixelRect = CGRect(x: pixelX, y: pixelY, width: pixelWidth, height: pixelHeight)
                context.fill(pixelRect)
            }
        }
        context.restoreGState()
    }
    
    private func bitIsOnAtIndex(_ index: Int, in int: UInt64) -> Bool {
        guard index < 64 else {
            return false
        }
        
        return ((int << index) & 0x8000000000000000) == 0x8000000000000000
    }
    
}
