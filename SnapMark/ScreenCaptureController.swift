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
//                self?.captureFullScreen(screen)
                ScreenCaptureController.share.onDelayFullCapture(screen: screen, delay: 2.0)

            }

            controller.onPartialCapture = { [weak self] screen in
//                self?.startPartialCapture(on: screen)
                ScreenCaptureController.share.onDelayPartialCapture(screen: screen, delay: 2.0)
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
    
    
    //先把目錄畫刪除，等畫面完成後，再進行拮圖
    private func prepareForCapture( completion: @escaping () -> Void) {
        overlayControllers.forEach { $0.hide() }
        overlayControllers.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
        }
    }
    
    
    //全畫面
    private func captureFullScreen(_ screen: NSScreen) {
        prepareForCapture() { [weak self] in
              let rect = screen.frame
              self?.capture(rect: rect)
          }
    }
    //延時全畫面
    func onDelayFullCapture(screen: NSScreen, delay: TimeInterval) {
        prepareForCapture() { [weak self] in
            self?.showCountdownOverlay(on: screen, seconds: Int(delay)) {
                self?.captureFullScreen(screen)
            }
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
                self?.delayPartialCaptureOverlayWindow?.orderOut(nil)
                self?.overlayWindow = nil
            }

            overlay.contentView = selection
            self?.overlayWindow = overlay
            self?.selectionView = selection
        }
    }
    private var delayPartialCaptureOverlayWindow:NSWindow? = nil
    //延時部份畫面
    func onDelayPartialCapture(screen: NSScreen, delay: TimeInterval) {
        prepareForCapture() { [weak self] in
            self?.showCountdownOverlay(on: screen, seconds: Int(delay)) {
                // Step 1: 截全螢幕
                let fullImage = CGWindowListCreateImage(screen.frame, .optionOnScreenOnly, kCGNullWindowID, .bestResolution)
                guard let cgImage = fullImage else { return }
      
                let nsImage = NSImage(cgImage: cgImage, size: screen.frame.size)
                // Step 2: 建立覆蓋視窗貼上截圖
//                let overlay = NSWindow(
//                    contentRect: screen.frame,
//                    styleMask: [.borderless],
//                    backing: .buffered,
//                    defer: false
//                )
//                overlay.isOpaque = false
//                overlay.backgroundColor = .red
//                overlay.level = .screenSaver
//                overlay.ignoresMouseEvents = false
//                let imageView = NSImageView(frame:screen.frame)
//                let imageView = NSImageView(frame: NSRect(origin: .zero, size: screen.frame.size))
//                imageView.image = nsImage
//                imageView.imageScaling = .scaleNone
//                overlay.contentView = imageView
//                overlay.makeKeyAndOrderFront(nil)
            

                let overlay = NSWindow(
                    contentRect: screen.frame,
                    styleMask: [.borderless],
                    backing: .buffered,
                    defer: false
                )
                overlay.isOpaque = false
                overlay.backgroundColor = .red
                overlay.level = .screenSaver
                overlay.ignoresMouseEvents = false

                let imageView = NSImageView(frame: NSRect(origin: .zero, size: screen.frame.size))
                imageView.image = nsImage
                imageView.imageScaling = .scaleProportionallyUpOrDown
                overlay.contentView = imageView
                overlay.makeKeyAndOrderFront(nil)

                self?.delayPartialCaptureOverlayWindow = overlay
                
                
                print("Overlay frame: \(overlay.frame)")
                print("ContentView frame: \(overlay.contentView?.frame ?? .zero)")
                print("ImageView frame: \(imageView.frame)")


                // Step 3: 開始選取區域
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                    self?.startPartialCapture(on: screen)
//                    self?.overlayWindow?.orderOut(nil)
//                    self?.overlayWindow = nil
                }
            }
        }
        
    }

    //顯示延時畫面
    private func showCountdownOverlay(on screen: NSScreen, seconds: Int, completion: @escaping () -> Void) {
        // 計算顯示位置：螢幕中央上方 1/3 處
        let windowSize = NSSize(width: 400, height: 160)
        let centerX = screen.frame.midX - windowSize.width / 2
        let centerY = screen.frame.maxY - screen.frame.height / 3

        // 建立浮動視窗
        let window = NSWindow(
            contentRect: NSRect(x: centerX, y: centerY, width: windowSize.width, height: windowSize.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .transient]

        // 建立倒數 Label
        let label = NSTextField(labelWithString: "\(seconds)")
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: 100, weight: .bold)
        label.textColor = .white
        label.backgroundColor = NSColor.black.withAlphaComponent(0.5)
        label.wantsLayer = true
        label.layer?.cornerRadius = 12
        label.layer?.masksToBounds = true
        label.frame = NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height)

        window.contentView?.addSubview(label)
        window.makeKeyAndOrderFront(nil)

        // 啟動倒數 Timer（使用 .common 模式避免 run loop 被切換影響）
        var remaining = seconds
        let timer = Timer(timeInterval: 1.0, repeats: true) { timer in
            remaining -= 1
            label.stringValue = "\(remaining)"
            if remaining <= 0 {
                label.stringValue = ""
                window.orderOut(nil)
                timer.invalidate()
                label.displayIfNeeded()

                completion()
                
//                CATransaction.begin()
//                CATransaction.setCompletionBlock {
//                    print("View 已完成繪製")
//                    // 在這裡執行後續操作，例如截圖、動畫、轉場等
//                    
//                }
//                CATransaction.commit()

                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    completion()
                }
            }
        }
        RunLoop.current.add(timer, forMode: .common)
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
