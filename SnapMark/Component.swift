//
//  Component.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/22.
//

import Cocoa

enum COMPONET_TYPE{
    case TEXT     //文字框
    case ARROW    //箭頭
    case BOX
}


struct Component{
    var componentType = COMPONET_TYPE.ARROW //元件型別
    var startPoint:NSPoint
    var endPoint:NSPoint
    var color:NSColor
    var boardWidth:Double
    var cornerRadius:Double
    var text:String = ""
    var fontName:String = ""
    var fontSize:CGFloat = 14.0
    var isSelected = false
    func framRect(ratio:Double) -> NSRect{
        let x = min(startPoint.x,endPoint.x) * ratio
        let y = min(startPoint.y,endPoint.y) * ratio
        let width = abs(startPoint.x - endPoint.x) * ratio
        let height = abs(startPoint.y - endPoint.y) * ratio
        var rect = NSRect(x:x,y:y,width: width,height: height)
        return rect
    }
}
