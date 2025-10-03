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
    
    private override init() {
        super .init()
    }
    
    static var share = ScreenCaptureController()
    private var overlayControllers: [OverlayController] = []
    
    /// 截圖完成後的回呼
    var onCaptureComplete: ((NSImage?) -> Void)?

    /// 開始選取截圖流程，並暫時隱藏主視窗
    func startCapture(from window: NSWindow) {
        


        self.mainWindow = window
        
        mainWindow?.orderOut(nil)
        NSApp.activate(ignoringOtherApps: true)

        overlayControllers = NSScreen.screens.map { screen in
            let controller = OverlayController(screen: screen)
            
            controller.onFullCapture = { [weak self] screen in
                self?.captureFullScreen(screen)
            }

            controller.onPartialCapture = { [weak self] screen in
                self?.startPartialCapture(on: screen)
            }
            
            controller.onCancel = { [weak self] in
                self?.overlayControllers.forEach { $0.hide() }
                self?.overlayControllers.removeAll()
                self?.mainWindow?.makeKeyAndOrderFront(nil)
                self?.onCaptureComplete?(nil)
            }

            controller.show()
            return controller
        }
    }
    //全畫面
    private func captureFullScreen(_ screen: NSScreen) {
        prepareForCapture() { [weak self] in
              let rect = screen.frame
              self?.capture(rect: rect)
          }
    }
    //先把目錄畫刪除，等畫面完成後，再進行拮圖
    private func prepareForCapture( completion: @escaping () -> Void) {
        overlayControllers.forEach { $0.hide() }
        overlayControllers.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
        }
    }

    //部份畫面
    private func startPartialCapture(on screen: NSScreen) {
        prepareForCapture(){[weak self] in
            let overlay = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            overlay.isOpaque = false
            overlay.backgroundColor = NSColor.clear
            overlay.level = .screenSaver
            overlay.ignoresMouseEvents = false
            overlay.makeKeyAndOrderFront(nil)

            let selection = SelectionView(frame: screen.frame)
            selection.onSelectionComplete = { [weak self] rect in
                self?.capture(rect: rect)
            }

            overlay.contentView = selection
            self?.overlayWindow = overlay
            self?.selectionView = selection
        }
    }

    // 擷取指定區域並回到主視窗
    private func capture(rect: CGRect) {
        let image = CGWindowListCreateImage(rect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution)
        if let cgImage = image {
            let nsImage = NSImage(cgImage: cgImage, size: rect.size)

            onCaptureComplete?(nsImage)
        }

        overlayWindow?.orderOut(nil)
        selectionView = nil
        mainWindow?.makeKeyAndOrderFront(nil)

    }
}
