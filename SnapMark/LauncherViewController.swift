//
//  LauncherViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/1.
//

import Cocoa
import UniformTypeIdentifiers

class LauncherViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    //拮取畫面控制器
    var controller:ScreenCaptureController? = ScreenCaptureController()
    
    var newImage:NSImage? = nil
    
    var selectedURL:URL? = nil
    
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
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if SMFireManager.shared.snapMarkFolderURL == nil {
            SMFireManager.shared.promptUserToSelectSnapMarkLocation()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "goMain":
            // 確保 newWindow 已經初始化完成
            DispatchQueue.main.async {
                self.view.window?.close()
            }
            let nextVC = segue.destinationController as? MainViewController
            if let newImage{
                nextVC?.editingImage = newImage
            }
            if let selectedURL{
                nextVC?.currentFileUrl = selectedURL
            }
        default:
            break
        }
    }
    



    
    
    
    @IBAction func action(_ sender: Any) {
        performSegue(withIdentifier: "goSelectSavedFile", sender: nil)
    }
    
    @IBAction func actionWithNewSnap(_ sender: Any) {
        guard let mainWindow = self.view.window else { return }
        controller?.onCaptureComplete = { [weak self] image in
            self?.newImage = image
            self?.performSegue(withIdentifier: "goMain", sender: nil)
        }
        controller?.startCapture(from: mainWindow)
    }
    
    @IBAction func actionWithReadFile(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            UTType.png,
            UTType.jpeg,
            UTType.gif,
            UTType.tiff,
            UTType.bmp,
            UTType.heic
        ]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "選擇一張圖片"

        if panel.runModal() == .OK, let url = panel.url {
            if let image  = NSImage(contentsOf: url){
                self.newImage = image
                self.performSegue(withIdentifier: "goMain", sender: nil)
            }
        }
    }
    
    
    @IBAction func actionReadCurrentFile(_ sender: Any) {
        let panel = NSOpenPanel()
        // 建立自訂的 UTType，對應 .sm 副檔名
        let smType = UTType(filenameExtension: "sm") ?? UTType.data
        
        panel.allowedContentTypes = [smType]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "選擇 SnapMark 檔案"

        if panel.runModal() == .OK, let url = panel.url {
            self.selectedURL = url
            self.performSegue(withIdentifier: "goMain", sender: nil)
            
        }
    }
    
    
}
