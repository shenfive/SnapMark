//
//  SnapEditView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/15.
//

import Cocoa
class SnapEditView: NSView {
    
    var theImageView:NSImageView!
    
    var startPoint: NSPoint = .zero
    var endPoint: NSPoint = .zero
    var onSelectionComplete: ((CGRect) -> Void)?
    var newView:NSBox!
    var arrowView:ArrowView!

    var endAction:(()->())? = nil
    
    override func mouseDown(with event: NSEvent) {

        startPoint = convert(event.locationInWindow, from: nil)
        print("startPoint:\(startPoint)")
        newView = NSBox(frame: NSRect(origin: startPoint, size: NSSize(width: 1, height: 1)))
        arrowView = ArrowView()
        arrowView.frame = newView.bounds
        newView.addSubview(arrowView)
        newView.boxType = .custom
        newView.fillColor = NSColor.clear
        newView.borderColor = NSColor.white
        
        addSubview(newView, positioned: .above, relativeTo: nil)
        
    }

    override func mouseDragged(with event: NSEvent) {
        endPoint = convert(event.locationInWindow, from: nil)
        
        // 計算左下角座標與大小
        let width = abs(startPoint.x - endPoint.x)
        let height = abs(startPoint.y - endPoint.y)
        
        let originX = min(startPoint.x, endPoint.x)
        let originY = min(startPoint.y, endPoint.y)
        
        arrowView.startPoint = startPoint
        arrowView.endPoint = endPoint
        
        newView.frame = NSRect(x: originX, y: originY, width: width, height: height)
        arrowView.frame = newView.contentView!.bounds
    }

    override func mouseUp(with event: NSEvent) {
        endPoint = convert(event.locationInWindow, from: nil)
        endAction?()
        newView.borderColor = NSColor.clear
    }


    override func draw(_ dirtyRect: NSRect) {
        print("Draw")
    }
}
