//
//  LauncherViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/1.
//

import Cocoa

class LauncherViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    //拮取畫面控制器
    var controller:ScreenCaptureController? = ScreenCaptureController()
    
    var newImage:NSImage? = nil
    
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
            
            // 移除三個按鈕
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            // 可選：移除標題欄互動
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "goMain" {
            // 確保 newWindow 已經初始化完成
            DispatchQueue.main.async {
                self.view.window?.close()
            }
            let nextVC = segue.destinationController as? MainViewController
            if let newImage{
                nextVC?.editingImage = newImage
            }
            
        }
    }
    
    @IBAction func action(_ sender: Any) {
        performSegue(withIdentifier: "goMain", sender: nil)
    }
    
    @IBAction func actionWithNewSnap(_ sender: Any) {
        guard let mainWindow = self.view.window else { return }
        controller?.onCaptureComplete = { [weak self] image in
            self?.newImage = image
            self?.performSegue(withIdentifier: "goMain", sender: nil)
        }
        controller?.startCapture(from: mainWindow)
    }
}
