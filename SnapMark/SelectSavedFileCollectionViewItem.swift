//
//  SelectSavedFileCollectionViewItem.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/23.
//

import AppKit

class SelectSavedFileCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var theImage: NSImageView!
    
    @IBOutlet weak var fileLabel: NSTextField!
    
    var fileThumb:NSImage? = nil
    var fileTitle = ""
    var fileURL:URL? = nil
    var reloadMenuAction:(()->())? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        theImage.image = fileThumb
        fileLabel.stringValue = fileTitle
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        print("right click")
        
        let menu = NSMenu(title: "選單")
        
        menu.addItem(withTitle: "將元件移到垃圾桶", action: #selector(deleteItem(_:)), keyEquivalent: "")
        
        NSMenu.popUpContextMenu(menu, with: event, for: self.view)
    }
    
    @objc func deleteItem(_ sender: Any?) {
        print("執行動作一")
        
        let alert = NSAlert()
        alert.messageText = "提示"
        alert.informativeText = "移到垃圾桶？"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "確定")
        alert.addButton(withTitle: "取消")
        
        // 指定圖示
        alert.icon = theImage.image
        
        
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // 使用者按下「確定」
            
            if let fileURL{
                //取得版本案例
//                let osVersion = ProcessInfo.processInfo.operatingSystemVersion
//                let major = osVersion.majorVersion
//                let minor = osVersion.minorVersion
                
                // macOS 13+ 使用 NSWorkspace.recycle
                if #available(macOS 13.0, *) {
                    NSWorkspace.shared.recycle([fileURL]) { recycledURLs, error in
                        if let error = error {
                            print("移到垃圾桶失敗：\(error)")
                        } else {
                            print("檔案已移到垃圾桶：\(recycledURLs)")
                            self.reloadMenuAction?()
                        }
                    }
                }else{
                    // macOS 11–12 手動搬移到 ~/.Trash
                    let trashURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")
                    let destinationURL = trashURL.appendingPathComponent(fileURL.lastPathComponent)
                    
                    do {
                        try FileManager.default.moveItem(at: fileURL, to: destinationURL)
                        print("已手動移到垃圾桶：\(destinationURL.path)")
                    } catch {
                        print("搬移失敗：\(error)")
                    }
                }
            }
        }
    }
    
}
