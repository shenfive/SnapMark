//
//  ScreenCaptureController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/13.
//
import Cocoa

class ScreenCaptureController: NSObject {
    private var overlayWindow: NSWindow?
    private var selectionView: SelectionView?
    private weak var mainWindow: NSWindow?

    /// 截圖完成後的回呼
    var onCaptureComplete: ((NSImage) -> Void)?

    /// 開始選取截圖流程，並暫時隱藏主視窗
    func startCapture(from window: NSWindow) {
        self.mainWindow = window
        window.orderOut(nil) // 隱藏主視窗

        guard let screen = NSScreen.main else { return }
        let screenRect = screen.frame

        let overlay = NSWindow(
            contentRect: screenRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        overlay.isOpaque = false
        overlay.backgroundColor = NSColor.clear
        overlay.level = .screenSaver
        overlay.ignoresMouseEvents = false
        overlay.makeKeyAndOrderFront(nil)

        let selection = SelectionView(frame: screenRect)
        selection.onSelectionComplete = { [weak self] rect in
            self?.capture(rect: rect)
        }

        overlay.contentView = selection
        overlayWindow = overlay
        selectionView = selection
    }

    /// 擷取指定區域並回到主視窗
    private func capture(rect: CGRect) {
        let image = CGWindowListCreateImage(rect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution)
        if let cgImage = image {
            let nsImage = NSImage(cgImage: cgImage, size: rect.size)
            onCaptureComplete?(nsImage)
        }

        
        overlayWindow?.orderOut(nil)
        mainWindow?.makeKeyAndOrderFront(nil)
    }
}
