//
//  ArrowView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/18.
//

import Cocoa


class ArrowView: NSView {
    
    var arrowComponent:Component = Component()
    var ratio:Double = 1
    var outLine = true
    var outLineColor = NSColor.white
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
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return enableEdit &&  bounds.contains(point) ? self : nil
    }
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        

        // 計算方向向量
        let dx = arrowComponent.endPoint.x - arrowComponent.startPoint.x
        let dy = arrowComponent.endPoint.y - arrowComponent.startPoint.y

        let lineStartPoint = CGPoint(
            x: dx >= 0 ? 0 : bounds.width,
            y: dy >= 0 ? 0 : bounds.height
        )
        let lineEndPoint = CGPoint(
            x: dx >= 0 ? bounds.width : 0,
            y: dy >= 0 ? bounds.height : 0
        )

        let adx = lineEndPoint.x - lineStartPoint.x
        let ady = lineEndPoint.y - lineStartPoint.y
        let length = sqrt(adx * adx + ady * ady)
        guard length > 0 else { return }

        let ux = adx / length
        let uy = ady / length

        // 箭頭旋轉向量
        func rotatedVector(angle: CGFloat) -> CGPoint {
            let cosA = cos(angle)
            let sinA = sin(angle)
            return CGPoint(
                x: ux * cosA - uy * sinA,
                y: ux * sinA + uy * cosA
            )
        }

        let arrowLength: CGFloat = min(length, (15 + arrowComponent.boardWidth) * ratio)
        let arrowAngle: CGFloat = 30.0 * (.pi / 180.0)

        let leftVector = rotatedVector(angle: arrowAngle)
        let rightVector = rotatedVector(angle: -arrowAngle)

        let leftPoint = CGPoint(
            x: lineEndPoint.x - arrowLength * leftVector.x,
            y: lineEndPoint.y - arrowLength * leftVector.y
        )
        let rightPoint = CGPoint(
            x: lineEndPoint.x - arrowLength * rightVector.x,
            y: lineEndPoint.y - arrowLength * rightVector.y
        )

        // 主線端點微調（避免箭頭重疊）
        let inset: CGFloat = arrowComponent.boardWidth * ratio
        let adjustedEndPoint = CGPoint(
            x: lineEndPoint.x - inset * ux,
            y: lineEndPoint.y - inset * uy
        )

//        if outLine{
//            // 主線外框
//            let outerPath = NSBezierPath()
//            outerPath.move(to: lineStartPoint)
//            outerPath.line(to: adjustedEndPoint)
//            outerPath.lineWidth = (boardWidth * ratio) + 2.0
//            outLineColor.setStroke()
//            outerPath.stroke()
//        }


        // 主線本體（主色）
        let innerPath = NSBezierPath()
        innerPath.move(to: lineStartPoint)
        innerPath.line(to: adjustedEndPoint)
        innerPath.lineWidth = arrowComponent.boardWidth * ratio
        arrowComponent.color.setStroke()
        innerPath.stroke()

        
//        if outLine{
//            // 箭頭左右邊緣描邊
//            let edgePath = NSBezierPath()
//            edgePath.move(to: leftPoint)
//            edgePath.line(to: lineEndPoint)
//            edgePath.line(to: rightPoint)
//            outLineColor.setStroke()
//            edgePath.lineWidth = 1.0
//            edgePath.stroke()
//        }

        // 箭頭主體（實心三角形）
        let arrowPath = NSBezierPath()
        arrowPath.move(to: lineEndPoint)
        arrowPath.line(to: leftPoint)
        arrowPath.line(to: rightPoint)
        arrowPath.close()
        arrowComponent.color.setFill()
        arrowPath.fill()
        
        layer?.shadowColor = NSColor.white.cgColor
        layer?.shadowOpacity = 1
        layer?.shadowOffset = .zero
        layer?.shadowRadius = 1 * ratio
        if enableEdit == true{
            updatePointerViews()
        }
    }

    //繪製編輯控制項
    func updatePointerViews() {
        let dx = arrowComponent.endPoint.x - arrowComponent.startPoint.x
        let dy = arrowComponent.endPoint.y - arrowComponent.startPoint.y

        let inset: CGFloat = 5  // 內縮量

        let lineStartPoint = CGPoint(
            x: dx >= 0 ? inset : bounds.width - inset,
            y: dy >= 0 ? inset : bounds.height - inset
        )
        let lineEndPoint = CGPoint(
            x: dx >= 0 ? bounds.width - inset : inset,
            y: dy >= 0 ? bounds.height - inset : inset
        )

        let pointerSize = NSSize(width: 20, height: 20)

        startPointerView.frame = NSRect(
            origin: CGPoint(
                x: lineStartPoint.x - pointerSize.width / 2,
                y: lineStartPoint.y - pointerSize.height / 2
            ),
            size: pointerSize
        )

        endPointerView.frame = NSRect(
            origin: CGPoint(
                x: lineEndPoint.x - pointerSize.width / 2,
                y: lineEndPoint.y - pointerSize.height / 2
            ),
            size: pointerSize
        )
    }



    func setComponentData(component:Component,ratio:Double){
        arrowComponent = component
        self.ratio = ratio
    }
    
    
    var draggingStart = false
    var draggingEnd = false
    var startMouseDownStartPoint:CGPoint = .zero
    var startMouseDownEndPoint:CGPoint = .zero

    override func mouseDown(with event: NSEvent) {
        let location = superview!.convert(event.locationInWindow, from: nil)
        
        startMouseDownLocation = location
        startMouseDownEndPoint = arrowComponent.endPoint
        startMouseDownStartPoint = arrowComponent.startPoint
        
        
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
        
        
        if draggingStart {
            arrowComponent.startPoint = CGPoint(x: startMouseDownStartPoint.x + offsetX,
                                                y: startMouseDownStartPoint.y + offsetY)
        }
        if draggingEnd{
            arrowComponent.endPoint = CGPoint(x: startMouseDownEndPoint.x + offsetX,
                                              y: startMouseDownEndPoint.y + offsetY)
        }
        self.frame = arrowComponent.framRect(ratio: ratio)

    }

    override func mouseUp(with event: NSEvent) {
        print("arrow mouse UP")
        endEditAction?(arrowComponent)
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

    private func commonInit() {
        var topLevelObjects: NSArray?
        Bundle.main.loadNibNamed("ArrowView", owner: self, topLevelObjects: &topLevelObjects)

        guard let views = topLevelObjects as? [Any],
              let contentView = views.first(where: { $0 is NSView }) as? NSView else {
            return
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        startPointerView.wantsLayer = true
        startPointerView.canDrawSubviewsIntoLayer = true
        startPointerView.postsFrameChangedNotifications = true
        endPointerView.wantsLayer = true
        endPointerView.canDrawSubviewsIntoLayer = true

    }
}
