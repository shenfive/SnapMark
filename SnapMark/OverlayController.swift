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
    let cancelButton: NSButton

    var onFullCapture: ((NSScreen) -> Void)?
    var onPartialCapture: ((NSScreen) -> Void)?
    var onCancel:(()->Void)?

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
        cancelButton = OverlayController.makeButton(title: "Cencel", action: #selector(cancel))

        fullButton.target = self
        partialButton.target = self
        cancelButton.target = self
        
        fullButton.image = NSImage(systemSymbolName: "display.and.arrow.down", accessibilityDescription: nil)
        fullButton.imagePosition = .imageLeading // 圖在左、字在右
        fullButton.alignment = .center
        partialButton.image = NSImage(systemSymbolName: "plus.viewfinder", accessibilityDescription: nil)
        partialButton.imagePosition = .imageLeading // 圖在左、字在右
        partialButton.alignment = .center

        container.addSubview(fullButton)
        container.addSubview(partialButton)
        container.addSubview(cancelButton)

        // 置中排列
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        fullButton.frame.origin = CGPoint(x: center.x - 130, y: center.y)
        partialButton.frame.origin = CGPoint(x: center.x - 130, y: center.y - 80)
        cancelButton.frame.origin = CGPoint(x:center.x - 130, y: center.y - 160)

        window.contentView = container
    }

    func show() {

        window.makeKeyAndOrderFront(nil)
        window.level = .screenSaver // 確保在最上層
        NSApp.activate(ignoringOtherApps: true) // 強制 App 成為焦點
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
    
    @objc private func cancel(){
        onCancel?()
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
