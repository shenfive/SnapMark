//
//  AboutViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/10/7.
//

import Cocoa

class AboutViewController: NSViewController,NSWindowDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if let window = self.view.window ,
           let screenFrame = NSScreen.main?.frame {
            // 固定視窗大小
            let windowSize = NSSize(width: 600, height: 300)
            let originX = (screenFrame.width - windowSize.width) / 2
            let originY = (screenFrame.height - windowSize.height) / 2
            let centeredRect = NSRect(origin: CGPoint(x: originX, y: originY), size: windowSize)
            
            window.setFrame(centeredRect, display: true)
            
            let fixedSize = NSSize(width: 600, height: 300)
            window.setContentSize(fixedSize)
            window.minSize = fixedSize
            window.maxSize = fixedSize
            window.styleMask.remove(.resizable)
            
            // 右上角三個按鈕
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            // 可選：移除標題欄互動
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
        }
    }
}
