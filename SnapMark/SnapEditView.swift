//
//  SnapEditView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/15.
//

import Cocoa
class SnapEditView: NSView {
    
    var theImageView:NSImageView!
    
    var startPoint: NSPoint = .zero
    var endPoint: NSPoint = .zero
    var onSelectionComplete: ((CGRect) -> Void)?
    var newView:NSView!
    var arrowView:ArrowView = ArrowView()
    var boxView:BoxView = BoxView()
    var textView:TextView = TextView()
    var color:NSColor!
    var lineWidth = 2.0
    var cornerRadius = 8.0
    var ratio = 1.0
    var font = NSFont.systemFont(ofSize: 14)
    
    var endAction:((NSView)->())? = nil
    var startAction:(()->())? = nil
    
    var editMode:COMPONET_TYPE = .ARROW

    
    override func mouseDown(with event: NSEvent) {
        NSColorPanel.shared.close()
        startAction?()
        startPoint = convert(event.locationInWindow, from: nil)
        print("startPoint:\(startPoint)")
        newView = NSView(frame: NSRect(origin: startPoint, size: NSSize(width: 0, height: 0)))

        switch editMode {
        case .TEXT:
            textView.frame.origin = newView.frame.origin
            textView.setFont(font: font)
            textView.textField.textColor = color
            textView.fitSize()
            addSubview(textView, positioned: .above, relativeTo: nil)
        case .ARROW:
            arrowView.ratio = ratio
            arrowView.frame = newView.bounds
            arrowView.color = color
            arrowView.boardWidth = lineWidth
            arrowView.ratio = ratio
            newView.addSubview(arrowView)
        case .BOX:
            boxView.color = color
            boxView.boardWidth = lineWidth
            boxView.ratio = ratio
            boxView.frame = newView.bounds
            boxView.cornerRadius = cornerRadius
            newView.addSubview(boxView)
        }
        
 
        //新增元件的外框
        newView.wantsLayer = true
        newView.layer?.borderColor = .white
        switch editMode {
        case .TEXT:
            newView.layer?.borderWidth = 1
        case .ARROW:
            newView.layer?.borderWidth = 1
        case .BOX:
            newView.layer?.borderWidth = 0
        }

        
//        newView.boxType = .custom
//        newView.fillColor = NSColor.clear
//        newView.borderColor = NSColor.white
        
        addSubview(newView, positioned: .above, relativeTo: nil)
        
    }

    override func mouseDragged(with event: NSEvent) {
        endPoint = convert(event.locationInWindow, from: nil)
        print("endPoint:\(endPoint)")
        // 計算左下角座標與大小
        let width = abs(startPoint.x - endPoint.x)//max(10,abs(startPoint.x - endPoint.x))
        let height = abs(startPoint.y - endPoint.y)//max(10,abs(startPoint.y - endPoint.y))
        
        let originX = min(startPoint.x, endPoint.x)
        let originY = min(startPoint.y, endPoint.y)
        

        
        newView.frame = NSRect(x: originX, y: originY, width: width, height: height)
        switch editMode {
        case .TEXT:
            break
        case .ARROW:
            arrowView.startPoint = startPoint
            arrowView.endPoint = endPoint
            arrowView.frame = NSRect(x: 0   , y: 0, width: width, height: height)
            
            
        case .BOX:
            boxView.frame = newView.bounds
        }

    }

    override func mouseUp(with event: NSEvent) {
        newView.removeFromSuperview()
        endPoint = convert(event.locationInWindow, from: nil)
        switch editMode {
        case .TEXT:
            break
        case .ARROW:
            endAction?(arrowView)
            arrowView.removeFromSuperview()
        case .BOX:
            endAction?(boxView)
            boxView.removeFromSuperview()
        }
//        newView.borderColor = NSColor.clear
    }


    override func draw(_ dirtyRect: NSRect) {
        print("Draw")
    }
    
    func getComponet(ratio:Double) -> Component{
        switch editMode {
        case .TEXT:
            return Component(componentType: .TEXT,
                             startPoint: NSPoint(x: startPoint.x / ratio, y: startPoint.y / ratio) ,
                             endPoint: NSPoint(x: endPoint.x / ratio, y: endPoint.y / ratio) ,
                             color: color,
                             boardWidth: lineWidth,
                             cornerRadius: cornerRadius)
        case .ARROW:
            return Component(componentType: .ARROW,
                             startPoint: NSPoint(x: startPoint.x / ratio, y: startPoint.y / ratio) ,
                             endPoint: NSPoint(x: endPoint.x / ratio, y: endPoint.y / ratio) ,
                             color: color,
                             boardWidth: lineWidth,
                             cornerRadius: cornerRadius)
        case .BOX:
            return Component(componentType: .BOX,
                             startPoint: NSPoint(x: startPoint.x / ratio, y: startPoint.y / ratio) ,
                             endPoint: NSPoint(x: endPoint.x / ratio, y: endPoint.y / ratio) ,
                             color: color,
                             boardWidth: lineWidth,
                             cornerRadius: cornerRadius)
        }

    }
}
