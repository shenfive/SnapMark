//
//  FireManager.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/15.
//
import Cocoa

class SMFireManager{
    
    static let shared = SMFireManager()
    
    private init(){}
    
    
//    func savePackage(to url: URL, image1: NSImage, image2: NSImage, json: String) throws {
//        let wrapper = FileWrapper(directoryWithFileWrappers: [:])
//
//        // 儲存圖片
//        if let data1 = image1.tiffRepresentation,
//           let png1 = NSBitmapImageRep(data: data1)?.representation(using: .png, properties: [:]) {
//            wrapper.addRegularFile(withContents: png1, preferredFilename: "image1.png")
//        }
//
//        if let data2 = image2.tiffRepresentation,
//           let png2 = NSBitmapImageRep(data: data2)?.representation(using: .png, properties: [:]) {
//            wrapper.addRegularFile(withContents: png2, preferredFilename: "image2.png")
//        }
//
//        // 儲存 JSON
//        if let jsonData = json.data(using: .utf8) {
//            wrapper.addRegularFile(withContents: jsonData, preferredFilename: "metadata.json")
//        }
//
//        try wrapper.write(to: url, options: .atomic, originalContentsURL: nil)
//    }
//
//        
//
//    func updateJSON(in packageURL: URL, newJSONString: String) throws {
//        let wrapper = try FileWrapper(url: packageURL, options: .immediate)
//
//        // 移除舊的 metadata.json
//        if let old = wrapper.fileWrappers?["metadata.json"] {
//            wrapper.removeFileWrapper(old)
//        }
//
//        // 建立新的 metadata.json
//        if let jsonData = newJSONString.data(using: .utf8) {
//            let newWrapper = FileWrapper(regularFileWithContents: jsonData)
//            newWrapper.preferredFilename = "metadata.json"
//            wrapper.addFileWrapper(newWrapper)
//        }
//
//        // 寫回封裝檔案
//        try wrapper.write(to: packageURL, options: .atomic, originalContentsURL: nil)
//    }

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
