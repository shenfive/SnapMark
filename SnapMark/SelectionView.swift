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

    override func draw(_ dirtyRect: NSRect) {
        NSColor.red.setStroke()
        NSColor(calibratedWhite: 0, alpha: 0).setFill()

        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(startPoint.x - endPoint.x),
            height: abs(startPoint.y - endPoint.y)
        )

        let path = NSBezierPath(rect: rect)
        path.fill()
        path.lineWidth = 1
        path.stroke()
    }
}
