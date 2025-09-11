//
//  utilitys.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/10.
//
import Cocoa

func snapshot(of view: NSView) -> NSImage? {
    let bounds = view.bounds

    // 建立一個適合快取的 bitmap representation
    guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: bounds) else {
        return nil
    }

    // 將 view 的內容繪製到 bitmapRep 中
    view.cacheDisplay(in: bounds, to: bitmapRep)

    // 建立 NSImage 並加入 bitmapRep
    let image = NSImage(size: bounds.size)
    image.addRepresentation(bitmapRep)
    return image
}

