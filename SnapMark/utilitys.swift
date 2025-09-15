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

extension NSColor {
    struct CodableWrapper: Codable {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat

        init(_ color: NSColor) {
            let rgb = color.usingColorSpace(.deviceRGB) ?? NSColor.black
            red = rgb.redComponent
            green = rgb.greenComponent
            blue = rgb.blueComponent
            alpha = rgb.alphaComponent
        }

        func toNSColor() -> NSColor {
            return NSColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}
//
//extension NSPoint: Codable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(x, forKey: .x)
//        try container.encode(y, forKey: .y)
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let x = try container.decode(CGFloat.self, forKey: .x)
//        let y = try container.decode(CGFloat.self, forKey: .y)
//        self.init(x: x, y: y)
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case x, y
//    }
//}

