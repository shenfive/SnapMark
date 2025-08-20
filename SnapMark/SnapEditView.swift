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
    var newView:NSBox!
    var arrowView:ArrowView = ArrowView()
    var boxView:BoxView = BoxView()
    var textView:NSView = NSView()
    var color:NSColor!

    var endAction:((ArrowView)->())? = nil
    var editMode:COMPONET_TYPE = .ARROW
    
    override func mouseDown(with event: NSEvent) {
        NSColorPanel.shared.close()
        startPoint = convert(event.locationInWindow, from: nil)
        print("startPoint:\(startPoint)")
        newView = NSBox(frame: NSRect(origin: startPoint, size: NSSize(width: 10, height: 10)))

        switch editMode {
        case .TEXT:
            break
        case .ARROW:
            arrowView.frame = newView.bounds
            arrowView.color = color
            newView.addSubview(arrowView)
        case .BOX:
            boxView.color = color
            boxView.frame = newView.bounds
            newView.addSubview(boxView)
        }
        
 
        newView.boxType = .custom
        newView.fillColor = NSColor.clear
        newView.borderColor = NSColor.white
        
        addSubview(newView, positioned: .above, relativeTo: nil)
        
    }

    override func mouseDragged(with event: NSEvent) {
        endPoint = convert(event.locationInWindow, from: nil)
        
        // 計算左下角座標與大小
        let width = max(10,abs(startPoint.x - endPoint.x))
        let height = max(10,abs(startPoint.y - endPoint.y))
        
        let originX = min(startPoint.x, endPoint.x)
        let originY = min(startPoint.y, endPoint.y)
        
        arrowView.startPoint = startPoint
        arrowView.endPoint = endPoint
        
        newView.frame = NSRect(x: originX, y: originY, width: width, height: height)
        switch editMode {
        case .TEXT:
            break
        case .ARROW:
            arrowView.frame = newView.contentView!.bounds
        case .BOX:
            boxView.frame = newView.contentView!.bounds
        }

    }

    override func mouseUp(with event: NSEvent) {
        endPoint = convert(event.locationInWindow, from: nil)
        switch editMode {
        case .TEXT:
            break
        case .ARROW:
            endAction?(arrowView)
     
        case .BOX:
            break
        }
        newView.borderColor = NSColor.clear
    }


    override func draw(_ dirtyRect: NSRect) {
        print("Draw")
    }
}
