//
//  FireManager.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/15.
//
import Cocoa


struct SnapMarkPackage {
    let image1: NSImage
    let image2: NSImage
    var metadata: String
//    var components:[Component] {
//        set{
//            
//        }
//        get{
//            
//        }
//    }
}

class SMFireManager{
    
    static let shared = SMFireManager()
    
    private init(){}
    

    //儲存檔案
    func savePackage(to url: URL, image1: NSImage, image2: NSImage, json: String) throws {
        let fileManager = FileManager.default

        // 建立封裝資料匣
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        // 儲存 image1.png
        if let data1 = image1.tiffRepresentation,
           let png1 = NSBitmapImageRep(data: data1)?.representation(using: .png, properties: [:]) {
            let image1URL = url.appendingPathComponent("image1.png")
            try png1.write(to: image1URL)
        }

        // 儲存 image2.png
        if let data2 = image2.tiffRepresentation,
           let png2 = NSBitmapImageRep(data: data2)?.representation(using: .png, properties: [:]) {
            let image2URL = url.appendingPathComponent("image2.png")
            try png2.write(to: image2URL)
        }

        // 儲存 metadata.json
        let jsonURL = url.appendingPathComponent("metadata.json")
        let jsonData = Data(json.utf8)
        try jsonData.write(to: jsonURL)
    }

    func updateJSON(in packageURL: URL, newJSONString: String) throws {
        let jsonURL = packageURL.appendingPathComponent("metadata.json")
        let newData = Data(newJSONString.utf8)
        try newData.write(to: jsonURL, options: .atomic)
    }
    
    //讀取檔案
    func loadPackage(from url: URL) throws -> SnapMarkPackage {
        let fileManager = FileManager.default

        // 檢查資料匣是否存在
        guard fileManager.fileExists(atPath: url.path) else {
            throw NSError(domain: "SnapMarkError", code: 1, userInfo: [NSLocalizedDescriptionKey: "指定的資料匣不存在"])
        }

        // 讀取 image1.png
        let image1URL = url.appendingPathComponent("image1.png")
        guard let image1 = NSImage(contentsOf: image1URL) else {
            throw NSError(domain: "SnapMarkError", code: 2, userInfo: [NSLocalizedDescriptionKey: "無法讀取 image1.png"])
        }

        // 讀取 image2.png
        let image2URL = url.appendingPathComponent("image2.png")
        guard let image2 = NSImage(contentsOf: image2URL) else {
            throw NSError(domain: "SnapMarkError", code: 3, userInfo: [NSLocalizedDescriptionKey: "無法讀取 image2.png"])
        }

        // 讀取 metadata.json
        let jsonURL = url.appendingPathComponent("metadata.json")
        let jsonData = try Data(contentsOf: jsonURL)
        guard let metadata = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "SnapMarkError", code: 4, userInfo: [NSLocalizedDescriptionKey: "無法解析 metadata.json"])
        }

        return SnapMarkPackage(image1: image1, image2: image2, metadata: metadata)
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
    
}
