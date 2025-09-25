//
//  FireManager.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/15.
//
import Cocoa


struct SnapMarkPackage {
    let bg: NSImage
    let thumb: NSImage
    var metadata: String
}

class SMFireManager{
    
    static let shared = SMFireManager()
    
    private init(){}
    

    //儲存檔案
    func savePackage(to url: URL, bgImage: NSImage, thumbIamge: NSImage, json: String) throws {
        let fileManager = FileManager.default

        // 建立封裝資料匣
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        // 儲存 image1.png
        if let data1 = bgImage.tiffRepresentation,
           let png1 = NSBitmapImageRep(data: data1)?.representation(using: .png, properties: [:]) {
            let image1URL = url.appendingPathComponent("bg.png")
            try png1.write(to: image1URL)
        }

        // 儲存 image2.png
        if let data2 = thumbIamge.tiffRepresentation,
           let png2 = NSBitmapImageRep(data: data2)?.representation(using: .png, properties: [:]) {
            let image2URL = url.appendingPathComponent("thumb.png")
            try png2.write(to: image2URL)
        }

        // 儲存 metadata.json
        let jsonURL = url.appendingPathComponent("metadata.json")
        let jsonData = Data(json.utf8)
        try jsonData.write(to: jsonURL)
    }

    //更新 JSON
    func updateJSON(in packageURL: URL, newJSONString: String) throws {
        let jsonURL = packageURL.appendingPathComponent("metadata.json")
        let newData = Data(newJSONString.utf8)
        try newData.write(to: jsonURL, options: .atomic)
    }
    
    //更新縮圖
    func updateThumb(in packageURL: URL, newThumb:NSImage) throws {
        
        
        if let data2 = newThumb.tiffRepresentation,
           let png2 = NSBitmapImageRep(data: data2)?.representation(using: .png, properties: [:]) {
            let image2URL = packageURL.appendingPathComponent("thumb.png")
            try png2.write(to: image2URL)
        }
    }
    
    
    
    //讀取檔案
    func loadPackage(from url: URL) throws -> SnapMarkPackage {
        let fileManager = FileManager.default

        // 檢查資料匣是否存在
        guard fileManager.fileExists(atPath: url.path) else {
            throw NSError(domain: "SnapMarkError", code: 1, userInfo: [NSLocalizedDescriptionKey: "指定的資料匣不存在"])
        }

        // 讀取 image1.png
        let image1URL = url.appendingPathComponent("bg.png")
        guard let image1 = NSImage(contentsOf: image1URL) else {
            throw NSError(domain: "SnapMarkError", code: 2, userInfo: [NSLocalizedDescriptionKey: "無法讀取 bg.png"])
        }

        // 讀取 image2.png
        let image2URL = url.appendingPathComponent("thumb.png")
        guard let image2 = NSImage(contentsOf: image2URL) else {
            throw NSError(domain: "SnapMarkError", code: 3, userInfo: [NSLocalizedDescriptionKey: "無法讀取 thumb.png"])
        }

        // 讀取 metadata.json
        let jsonURL = url.appendingPathComponent("metadata.json")
        let jsonData = try Data(contentsOf: jsonURL)
        guard let metadata = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "SnapMarkError", code: 4, userInfo: [NSLocalizedDescriptionKey: "無法解析 metadata.json"])
        }

        return SnapMarkPackage(bg: image1, thumb: image2, metadata: metadata)
    }

    //選擇檔案
    func showSavePanel(completion: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.title = "儲存封裝檔案"
        panel.allowedFileTypes = ["sm"] // 自訂副檔名
        panel.nameFieldStringValue = "MyComponentPackage"
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        
        panel.begin { response in
            if response == .OK {
                completion(panel.url)
            } else {
                completion(nil)
            }
        }
    }
    
    //設定預設資料夾
    func promptUserToSelectSnapMarkLocation() {
        let panel = NSOpenPanel()
        panel.title = "選擇 SnapMark 儲存位置"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
    
        

        panel.begin { result in
            if result == .OK, let baseFolderURL = panel.url {
                let snapMarkFolderURL = baseFolderURL.appendingPathComponent("SnapMark")
                self.createSnapMarkFolder(at: snapMarkFolderURL)
            }else{
                
                
                // 使用者取消 → 可提示或再次開啟
                let alert = NSAlert()
                alert.messageText = "必須選擇檔案才能繼續使用 SnapMark"
                alert.addButton(withTitle: "重新選擇")
                alert.addButton(withTitle: "離開")
                alert.alertStyle = .warning
                alert.icon = NSImage(named: "arrow2")
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    self.promptUserToSelectSnapMarkLocation() // 再次開啟
                } else {
                    NSApp.terminate(nil)
                }
            }
        }
        
        

    }

    //建立預設資料夾
    func createSnapMarkFolder(at url: URL) {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            try saveFolderBookmark(url)
            print("✅ SnapMark 資料匣建立成功：\(url.path)")
        } catch {
            print("❌ 建立 SnapMark 資料匣失敗：\(error)")
        }
    }
    
    
    //記錄預設資料匣
    func saveFolderBookmark(_ url: URL) throws {
        let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(bookmarkData, forKey: "SnapMarkFolderBookmark")
    }
    
    //預設資料夾的位置
    var snapMarkFolderURL: URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "SnapMarkFolderBookmark") else {
            return nil
        }

        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                print("⚠️ Bookmark 已過期")
                return nil
            }

            if url.startAccessingSecurityScopedResource() {
                return url
            } else {
                print("❌ 無法存取 bookmark 路徑")
                return nil
            }
        } catch {
            print("❌ 還原 bookmark 失敗：\(error)")
            return nil
        }
    }
    
    // 定義基準時間：2025-01-01 00:00:01 為第一秒，產出的秒數
    func getDefaultFileURL() -> URL? {
        if snapMarkFolderURL == nil { return nil}
        // 定義基準時間：2025-01-01 00:00:01
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 1

        let calendar = Calendar(identifier: .gregorian)
        guard let epoch = calendar.date(from: components) else {
            return nil
        }

        // 計算目前時間與基準時間的秒數差
        let now = Date()
        let seconds = Int(now.timeIntervalSince(epoch))

        // 第一秒為 1，所以 +1
        let adjusted = max(0, seconds) + 1
        
        // 年月日格式
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        let datePrefix = formatter.string(from: now)
        
        return snapMarkFolderURL?.appendingPathComponent("\(datePrefix)_\(adjusted).sm")
  
    }


    
    
}
