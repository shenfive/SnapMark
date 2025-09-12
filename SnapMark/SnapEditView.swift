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
    var boardWidth = 2.0
    var cornerRadius = 8.0
    var ratio = 1.0
    var font = NSFont.systemFont(ofSize: 40) 
    
    var endAction:((NSView)->())? = nil
    var startAction:(()->())? = nil
    
    var editMode:COMPONET_TYPE = .ARROW
    var selectedSubView:NSView? = nil

    
    override func hitTest(_ point: NSPoint) -> NSView? {
        
        if let subView = selectedSubView{
            // 將點轉換到 subView 的座標系
            let pointInSubView = convert(point, to: subView)
            
            // 檢查是否點在 subView 上
            if subView.hitTest(pointInSubView) != nil {
                return subView
            }
        }
        
        // 否則由自己處理
        return self
    }
    
    override func mouseDown(with event: NSEvent) {
        NSColorPanel.shared.close()
        startAction?()
        startPoint = convert(event.locationInWindow, from: nil)
        print("Snap startPoint:\(startPoint)")
        newView = NSView(frame: NSRect(origin: startPoint, size: NSSize(width: 0, height: 0)))

        switch editMode {
        case .TEXT:
            textView.frame.origin = newView.frame.origin
            textView.textComponent.color = color
            textView.ratio = ratio
            textView.setFont(font: font)
            addSubview(textView, positioned: .above, relativeTo: nil)
        case .ARROW:
            arrowView.ratio = ratio
            arrowView.frame = newView.bounds
            arrowView.arrowComponent.color = color
            arrowView.arrowComponent.boardWidth = boardWidth
            arrowView.ratio = ratio
            newView.addSubview(arrowView)
        case .BOX:
            boxView.boxComponent.color = color
            boxView.boxComponent.boardWidth = boardWidth
            boxView.ratio = ratio
            boxView.frame = newView.bounds
            boxView.boxComponent.cornerRadius = cornerRadius
            newView.addSubview(boxView)
        }
        
 
        //新增元件的外框
        newView.wantsLayer = true
        newView.layer?.borderColor = .white
        switch editMode {
        case .TEXT:
            newView.layer?.borderWidth = 0
        case .ARROW:
            newView.layer?.borderWidth = 1
        case .BOX:
            newView.layer?.borderWidth = 0
        }
        
        addSubview(newView, positioned: .above, relativeTo: nil)
        
    }
    
    func redraw(){
        switch editMode {
        case .TEXT:
            textView.ratio = ratio
            textView.textComponent.color = color
            textView.setFont(font: font)
        case .ARROW:
            arrowView.arrowComponent.color = color
            arrowView.arrowComponent.boardWidth = boardWidth
        case .BOX:
            boxView.boxComponent.color = color
            boxView.boxComponent.cornerRadius = cornerRadius
            boxView.boxComponent.boardWidth = boardWidth
        }  
    }

    override func mouseDragged(with event: NSEvent) {
        endPoint = convert(event.locationInWindow, from: nil)
//        print("endPoint:\(endPoint)")
        // 計算左下角座標與大小
        let width = abs(startPoint.x - endPoint.x)//max(10,abs(startPoint.x - endPoint.x))
        let height = abs(startPoint.y - endPoint.y)//max(10,abs(startPoint.y - endPoint.y))
        
        let originX = min(startPoint.x, endPoint.x)
        let originY = min(startPoint.y, endPoint.y)
        

        
        newView.frame = NSRect(x: originX, y: originY, width: width, height: height)
        switch editMode {
        case .TEXT:
            textView.frame.origin = endPoint
        case .ARROW:
            arrowView.arrowComponent.startPoint = startPoint
            arrowView.arrowComponent.endPoint = endPoint
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
            endAction?(textView)
            arrowView.removeFromSuperview()
        case .ARROW:
            if sqrt(arrowView.frame.width * arrowView.frame.width + arrowView.frame.height  * arrowView.frame.height ) > 25 {
                endAction?(arrowView)
            }
            arrowView.removeFromSuperview()
        case .BOX:
            if boxView.frame.width > (boardWidth + 4) && boxView.frame.height > (boardWidth + 4){
                endAction?(boxView)
            }
            boxView.removeFromSuperview()
        }
    }


    override func draw(_ dirtyRect: NSRect) {
        print("Draw")
    }
    
    func getComponet(ratio:Double) -> Component{
        switch editMode {
        case .TEXT:
            return Component(componentType: .TEXT,
                             startPoint: NSPoint(x: endPoint.x / ratio, y: endPoint.y / ratio) ,
                             endPoint: NSPoint(x: endPoint.x / ratio, y: endPoint.y / ratio) ,
                             color: color,
                             boardWidth: boardWidth,
                             cornerRadius: cornerRadius,
                             text: textView.textField.stringValue,
                             fontName: font.fontName,
                             fontSize: font.pointSize)
        case .ARROW:
            
            return Component(componentType: .ARROW,
                             startPoint: NSPoint(x: startPoint.x / ratio, y: startPoint.y / ratio) ,
                             endPoint: NSPoint(x: endPoint.x / ratio, y: endPoint.y / ratio) ,
                             color: color,
                             boardWidth: boardWidth,
                             cornerRadius: cornerRadius)
        case .BOX:
            let minX = min(startPoint.x, endPoint.x)
            let maxX = max(startPoint.x, endPoint.x)
            let minY = min(startPoint.y, endPoint.y)
            let maxY = max(startPoint.y, endPoint.y)
            return Component(componentType: .BOX,
                             startPoint: NSPoint(x:minX / ratio, y: minY / ratio) ,
                             endPoint: NSPoint(x: maxX / ratio, y: maxY / ratio) ,
                             color: color,
                             boardWidth: boardWidth,
                             cornerRadius: cornerRadius)
        }

    }
}
