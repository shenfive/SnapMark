//
//  BoxView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/20.
//

import Cocoa

class BoxView: NSView {


    var ratio = 1.0
    var boxComponent:Component = Component()
    var _enableEdit = false
    
    var startMouseDownLocation:CGPoint = .zero
    
    var endEditAction:((Component)->())? = nil
    
    
    @IBOutlet weak var startPointerView:NSImageView!
    @IBOutlet weak var endPointerView:NSImageView!
    @IBOutlet weak var selectView: SelectView!
    
    var enableEdit:Bool {
        get{
            _enableEdit
        }
        set{
            _enableEdit = newValue
            startPointerView.isHidden = !newValue
            endPointerView.isHidden = !newValue
            selectView.isHidden = !newValue
            
        }
    }
    

    @IBOutlet weak var theBoxView: NSView!
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return enableEdit &&  bounds.contains(point) ? self : nil
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        theBoxView.wantsLayer = true
        theBoxView.layer?.borderColor = boxComponent.color.cgColor
        theBoxView.layer?.borderWidth = boxComponent.boardWidth * ratio
        theBoxView.layer?.shadowColor = NSColor.white.cgColor
        theBoxView.layer?.shadowOpacity = 1
        theBoxView.layer?.shadowOffset = .zero
        theBoxView.layer?.shadowRadius = 1 * ratio

 
        //藥丸形狀就是實體短邊的一半
        if boxComponent.cornerRadius == 100000.1{
            theBoxView.layer?.cornerRadius = min(theBoxView.frame.height,theBoxView.frame.width) / 2
        }else{
            //圓角最大不得超過實體的一半
            let displayConerRadius = min(boxComponent.cornerRadius * ratio,theBoxView.frame.size.height / 2.0,theBoxView.frame.size.width / 2.0)
            theBoxView.layer?.cornerRadius = displayConerRadius
        }

        if enableEdit {
            updatePointerViews()
        }

    }
    
    
    //繪製編輯控制項
    func updatePointerViews() {
        let pointerSize = NSSize(width: 20, height: 20)
        startPointerView.frame = NSRect(origin: .zero, size: pointerSize)
        endPointerView.frame = NSRect(origin: CGPoint(x: frame.size.width - 20.0,
                                                      y: frame.size.height - 20.0),
                                      size: pointerSize)
    }

    
    var draggingStart = false
    var draggingEnd = false
    var startMouseDownStartPoint:CGPoint = .zero
    var startMouseDownEndPoint:CGPoint = .zero


    override func mouseDown(with event: NSEvent) {
        let location = superview!.convert(event.locationInWindow, from: nil)
        startMouseDownLocation = location
        
        startMouseDownEndPoint = boxComponent.endPoint
        startMouseDownStartPoint = boxComponent.startPoint
        
        
        draggingStart = false
        draggingEnd = false
        let locationInView = convert(event.locationInWindow, from: nil)
        if startPointerView.frame.contains(locationInView) {
            print("STARTPoint")
            draggingStart = true
        } else if endPointerView.frame.contains(locationInView) {
            print("EndPoint")
            draggingEnd = true
        }else{
            print("BothPoing")
            draggingStart = true
            draggingEnd = true
        }
    }

    override func mouseDragged(with event: NSEvent) {
        let location = superview!.convert(event.locationInWindow, from: nil)
        
        let offsetX = (location.x - startMouseDownLocation.x) / ratio
        let offsetY = (location.y - startMouseDownLocation.y) / ratio
            print("offsetBox:\(offsetX):\(offsetY)")
        
        if draggingStart {
            boxComponent.startPoint = CGPoint(x: startMouseDownStartPoint.x + offsetX,
                                                y: startMouseDownStartPoint.y + offsetY)
        }
        if draggingEnd{
            boxComponent.endPoint = CGPoint(x: startMouseDownEndPoint.x + offsetX,
                                              y: startMouseDownEndPoint.y + offsetY)
        }
        self.frame = boxComponent.framRect(ratio: ratio)
    }
    
    override func mouseUp(with event: NSEvent) {
        print("arrow mouse UP")
        let minX = min(boxComponent.startPoint.x, boxComponent.endPoint.x)
        let maxX = max(boxComponent.startPoint.x, boxComponent.endPoint.x)
        let minY = min(boxComponent.startPoint.y, boxComponent.endPoint.y)
        let maxY = max(boxComponent.startPoint.y, boxComponent.endPoint.y)
        
        boxComponent.startPoint = NSPoint(x: minX / ratio, y: minY / ratio)
        boxComponent.endPoint = NSPoint(x: maxX / ratio, y: maxY / ratio)
        
        endEditAction?(boxComponent)
        draggingStart = false
        draggingEnd = false
    }

    
    
    // MARK: - Initializers
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    func setComponentData(component:Component,ratio:Double){
        self.ratio = ratio
        boxComponent = component
    }
    
    private func commonInit() {
        var topLevelObjects: NSArray?
        Bundle.main.loadNibNamed("BoxView", owner: self, topLevelObjects: &topLevelObjects)
        
        guard let views = topLevelObjects as? [Any],
              let contentView = views.first(where: { $0 is NSView }) as? NSView else {
            return
        }
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.width, .height]
        self.addSubview(contentView)
    }
}
