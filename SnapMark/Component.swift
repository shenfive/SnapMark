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
    var startPoint:NSPoint = .zero
    var endPoint:NSPoint = .zero
    var color:NSColor = NSColor.systemRed
    var boardWidth:Double = 2
    var cornerRadius:Double = 5
    var text:String = ""
    var fontName:String = ""
    var fontSize:CGFloat = 14.0
    var isSelected = false
    var isMouseOverMode = false
    var outLine = true
    var outLineColor = NSColor.white
    func framRect(ratio:Double) -> NSRect{
        let x = min(startPoint.x,endPoint.x) * ratio
        let y = min(startPoint.y,endPoint.y) * ratio
        let width = abs(startPoint.x - endPoint.x) * ratio
        let height = abs(startPoint.y - endPoint.y) * ratio
        let rect = NSRect(x:x,y:y,width: width,height: height)
        return rect
    }
}
