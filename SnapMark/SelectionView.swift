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
    var lineWidth:CGFloat = 1

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

        guard let window = self.window else { return }

        // 轉換為螢幕座標
        let startInScreen = window.convertToScreen(NSRect(origin: startPoint, size: .zero)).origin
        let endInScreen = window.convertToScreen(NSRect(origin: endPoint, size: .zero)).origin

        let screenHeight = NSScreen.main!.frame.height

        // 計算左下角座標與大小
        let width = abs(startInScreen.x - endInScreen.x) - 2
        let height = abs(startInScreen.y - endInScreen.y) - 2
        
        let originX = min(startInScreen.x, endInScreen.x) + 1
        let originY = screenHeight - ( min(startInScreen.y, endInScreen.y) + height )
        let selectedRect = CGRect(x: originX, y: originY, width: width, height: height)

        print("Selected rect in screen coordinates: \(selectedRect)")
        onSelectionComplete?(selectedRect)
    }

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
        path.lineWidth = lineWidth
        path.stroke()
    }
}
