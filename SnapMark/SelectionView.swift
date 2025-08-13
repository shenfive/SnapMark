//
//  SelectionView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/13.
//
import Cocoa

class SelectionView: NSView {
    var startPoint: NSPoint = .zero
    var endPoint: NSPoint = .zero
    var onSelectionComplete: ((CGRect) -> Void)?

    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        print("startPoint:\(startPoint)")
    }

    override func mouseDragged(with event: NSEvent) {
        endPoint = event.locationInWindow
        needsDisplay = true
        print("endPoint:\(endPoint)")
    }

    override func mouseUp(with event: NSEvent) {
        endPoint = event.locationInWindow
        let selectedRect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(startPoint.x - endPoint.x),
            height: abs(startPoint.y - endPoint.y)
        )
        onSelectionComplete?(selectedRect)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.red.setStroke()
        NSColor(calibratedWhite: 0, alpha: 0.3).setFill()

        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(startPoint.x - endPoint.x),
            height: abs(startPoint.y - endPoint.y)
        )

        let path = NSBezierPath(rect: rect)
        path.fill()
        path.lineWidth = 2
        path.stroke()
    }
}
