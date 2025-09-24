//
//  TransparentTextField.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/2.
//

import Cocoa

class TransparentTextField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        cell?.usesSingleLineMode = true
        // Drawing code here.
    }
    
    /// 控制是否讓事件穿透
    var isMouseTransparent: Bool = false

    override func hitTest(_ point: NSPoint) -> NSView? {
        return isMouseTransparent ? nil : super.hitTest(point)
    }
}
