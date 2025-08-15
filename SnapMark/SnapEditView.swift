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
    
    override func mouseDown(with event: NSEvent) {

        startPoint = convert(event.locationInWindow, from: nil)
        print("startPoint:\(startPoint)")
        newView = NSBox(frame: NSRect(origin: startPoint, size: NSSize(width: 50, height: 50)))
        newView.boxType = .custom
        newView.fillColor = NSColor.systemMint
        newView.borderColor = NSColor.clear
        addSubview(newView, positioned: .above, relativeTo: nil)
        
    }

    override func mouseDragged(with event: NSEvent) {
        endPoint = convert(event.locationInWindow, from: nil)
        print("endPoint:\(endPoint)")
        newView.frame.origin = endPoint
    }

    override func mouseUp(with event: NSEvent) {
        endPoint = convert(event.locationInWindow, from: nil)
        newView.removeFromSuperview()
    }


    override func draw(_ dirtyRect: NSRect) {
        print("Draw")
    }
}
