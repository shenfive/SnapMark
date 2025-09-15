//
//  Component.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/22.
//

import Cocoa

enum COMPONET_TYPE: String, Codable {
    case TEXT
    case ARROW
    case BOX
}

struct Component: Codable {
    var componentType = COMPONET_TYPE.ARROW
    var startPoint: NSPoint = .zero
    var endPoint: NSPoint = .zero
    var color: NSColor = .systemRed
    var boardWidth: Double = 2
    var cornerRadius: Double = 5
    var text: String = ""
    var fontName: String = ""
    var fontSize: CGFloat = 14.0
    var isSelected = false
    var isMouseOverMode = false

    enum CodingKeys: String, CodingKey {
        case componentType, startPoint, endPoint, color, boardWidth, cornerRadius,
             text, fontName, fontSize, isSelected, isMouseOverMode
    }
    
    func framRect(ratio:Double) -> NSRect{
        let x = min(startPoint.x,endPoint.x) * ratio
        let y = min(startPoint.y,endPoint.y) * ratio
        let width = abs(startPoint.x - endPoint.x) * ratio
        let height = abs(startPoint.y - endPoint.y) * ratio
        let rect = NSRect(x:x,y:y,width: width,height: height)
        return rect
    }
    

    // Encode
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(componentType, forKey: .componentType)
        try container.encode(startPoint, forKey: .startPoint)
        try container.encode(endPoint, forKey: .endPoint)
        try container.encode(NSColor.CodableWrapper(color), forKey: .color)
        try container.encode(boardWidth, forKey: .boardWidth)
        try container.encode(cornerRadius, forKey: .cornerRadius)
        try container.encode(text, forKey: .text)
        try container.encode(fontName, forKey: .fontName)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(isSelected, forKey: .isSelected)
        try container.encode(isMouseOverMode, forKey: .isMouseOverMode)
    }


    // Decode
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        componentType = try container.decode(COMPONET_TYPE.self, forKey: .componentType)
        startPoint = try container.decode(NSPoint.self, forKey: .startPoint)
        endPoint = try container.decode(NSPoint.self, forKey: .endPoint)
        let colorWrapper = try container.decode(NSColor.CodableWrapper.self, forKey: .color)
        color = colorWrapper.toNSColor()
        boardWidth = try container.decode(Double.self, forKey: .boardWidth)
        cornerRadius = try container.decode(Double.self, forKey: .cornerRadius)
        text = try container.decode(String.self, forKey: .text)
        fontName = try container.decode(String.self, forKey: .fontName)
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
        isMouseOverMode = try container.decode(Bool.self, forKey: .isMouseOverMode)
    }
    
    init() {
        // 使用預設值初始化所有屬性
        self.componentType = .ARROW
        self.startPoint = .zero
        self.endPoint = .zero
        self.color = .systemRed
        self.boardWidth = 2
        self.cornerRadius = 5
        self.text = ""
        self.fontName = ""
        self.fontSize = 14.0
        self.isSelected = false
        self.isMouseOverMode = false
    }
    
    init(
        componentType: COMPONET_TYPE = .ARROW,
        startPoint: NSPoint = .zero,
        endPoint: NSPoint = .zero,
        color: NSColor = .systemRed,
        boardWidth: Double = 2,
        cornerRadius: Double = 5,
        text: String = "",
        fontName: String = "",
        fontSize: CGFloat = 14.0,
        isSelected: Bool = false,
        isMouseOverMode: Bool = false,
        outLine: Bool = true,
        outLineColor: NSColor = .white
    ) {
        self.componentType = componentType
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.color = color
        self.boardWidth = boardWidth
        self.cornerRadius = cornerRadius
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize
        self.isSelected = isSelected
        self.isMouseOverMode = isMouseOverMode
    }

}
extension Component {
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    static func fromJSONString(_ json: String) -> Component? {
        let decoder = JSONDecoder()
        if let data = json.data(using: .utf8),
           let component = try? decoder.decode(Component.self, from: data) {
            return component
        }
        return nil
    }
}
