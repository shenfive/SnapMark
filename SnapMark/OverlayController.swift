//
//  OverlayController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/10/2.
//

import Cocoa

class OverlayController {
    let screen: NSScreen
    let window: NSWindow
    let fullButton: NSButton
    let partialButton: NSButton

    var onFullCapture: ((NSScreen) -> Void)?
    var onPartialCapture: ((NSScreen) -> Void)?

    init(screen: NSScreen) {
        self.screen = screen
        let frame = screen.frame

        window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = NSColor.black.withAlphaComponent(0.4)
        window.level = .screenSaver
        window.ignoresMouseEvents = false

        let container = NSView(frame: frame)

        fullButton = OverlayController.makeButton(title: "Full Screen", action: #selector(fullCapture))
        partialButton = OverlayController.makeButton(title: "Partial Screen", action: #selector(partialCapture))

        fullButton.target = self
        partialButton.target = self
        
        fullButton.image = NSImage(systemSymbolName: "display.and.arrow.down", accessibilityDescription: nil)
        fullButton.imagePosition = .imageLeading // 圖在左、字在右
        fullButton.alignment = .center
        partialButton.image = NSImage(systemSymbolName: "plus.viewfinder", accessibilityDescription: nil)
        partialButton.imagePosition = .imageLeading // 圖在左、字在右
        partialButton.alignment = .center

        container.addSubview(fullButton)
        container.addSubview(partialButton)

        // 置中排列
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        fullButton.frame.origin = CGPoint(x: center.x - 130, y: center.y)
        partialButton.frame.origin = CGPoint(x: center.x - 130, y: center.y - 80)

        window.contentView = container
    }

    func show() {
        window.makeKeyAndOrderFront(nil)
    }

    func hide() {
        window.orderOut(nil)
    }

    @objc private func fullCapture() {
        onFullCapture?(screen)
    }

    @objc private func partialCapture() {
        onPartialCapture?(screen)
    }

    private static func makeButton(title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: nil, action: action)
        button.bezelStyle = .regularSquare
        button.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.8).cgColor
        button.layer?.cornerRadius = 8
        button.setButtonType(.momentaryPushIn)
        button.sizeToFit()
        button.frame.size = CGSize(width: 260, height: 60)
        return button
    }
}
