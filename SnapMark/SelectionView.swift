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
    var lineWidth: CGFloat = 1

    private var selectionRect: CGRect {
        CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(startPoint.x - endPoint.x),
            height: abs(startPoint.y - endPoint.y)
        )
    }

    private func updateSelection(to point: NSPoint) {
        endPoint = point
        needsDisplay = true
    }

    private var infoLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.textColor = .white
        label.backgroundColor = NSColor.black.withAlphaComponent(0.6)
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.isBordered = false
        label.isEditable = false
        label.sizeToFit()
        return label
    }()

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        addSubview(infoLabel)
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        endPoint = startPoint
        updateSelection(to: startPoint)
    }

    override func mouseDragged(with event: NSEvent) {
        let currentPoint = event.locationInWindow
        updateSelection(to: currentPoint)

        let size = selectionRect.size
        infoLabel.stringValue = "\(Int(size.width)) × \(Int(size.height))"
        infoLabel.sizeToFit()
        infoLabel.frame.origin = CGPoint(x: currentPoint.x + 10, y: currentPoint.y - 20)
    }

    override func mouseUp(with event: NSEvent) {
        endPoint = event.locationInWindow

        guard let window = self.window else { return }

        let startInScreen = window.convertToScreen(NSRect(origin: startPoint, size: .zero)).origin
        let endInScreen = window.convertToScreen(NSRect(origin: endPoint, size: .zero)).origin

        let screenHeight = NSScreen.main!.frame.height

        let width = abs(startInScreen.x - endInScreen.x) - 2
        let height = abs(startInScreen.y - endInScreen.y) - 2

        let originX = min(startInScreen.x, endInScreen.x) + 1
        let originY = screenHeight - (min(startInScreen.y, endInScreen.y) + height)
        let selectedRect = CGRect(x: originX, y: originY, width: width, height: height)

        onSelectionComplete?(selectedRect)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        // 灰色遮罩
        context.setFillColor(NSColor.black.withAlphaComponent(0.4).cgColor)
        context.fill(bounds)

        // 清除選取區域
        context.setBlendMode(.clear)
        context.fill(selectionRect)

        // 邊框
        context.setBlendMode(.normal)
        context.setStrokeColor(NSColor.red.cgColor)
        context.setLineWidth(lineWidth)
        context.stroke(selectionRect)
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: NSCursor.crosshair)
    }
}
