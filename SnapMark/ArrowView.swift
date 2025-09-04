//
//  ArrowView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/18.
//

import Cocoa


class ArrowView: NSView {
    
    var boardWidth = 4.0
    var startPoint = CGPoint(x: 0, y: 0)
    var endPoint = CGPoint(x: 0, y: 0)
    var color:NSColor = NSColor.systemRed
    var ratio:Double = 1
    var outLine = true
    var outLineColor = NSColor.white
    var _enableEdit = false
    @IBOutlet weak var startPointerView:NSImageView!
    @IBOutlet weak var endPointerView:NSImageView!
    
    var enableEdit:Bool {
        get{
            _enableEdit
        }
        set{
            _enableEdit = newValue
            startPointerView.isHidden = !newValue
            endPointerView.isHidden = !newValue
        }
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // 計算方向向量
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y

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

        let arrowLength: CGFloat = min(length, (15 + boardWidth) * ratio)
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
        let inset: CGFloat = boardWidth * ratio
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
        innerPath.lineWidth = boardWidth * ratio
        color.setStroke()
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
        color.setFill()
        arrowPath.fill()
        
        layer?.shadowColor = NSColor.white.cgColor
        layer?.shadowOpacity = 1
        layer?.shadowOffset = .zero
        layer?.shadowRadius = 1 * ratio
        if enableEdit == true{
            updatePointerViews()
        }
    }
    
    func updatePointerViews() {
        // 計算方向向量
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y

        let lineStartPoint = CGPoint(
            x: dx >= 0 ? 0 : bounds.width,
            y: dy >= 0 ? 0 : bounds.height
        )
        let lineEndPoint = CGPoint(
            x: dx >= 0 ? bounds.width : 0,
            y: dy >= 0 ? bounds.height : 0
        )

        // 設定 ImageView 的大小（可依照圖片大小或固定尺寸）
        let pointerSize = NSSize(width: 20, height: 20)

        // 更新 startPointerView 的位置
        startPointerView.frame = NSRect(
            origin: CGPoint(
                x: lineStartPoint.x - pointerSize.width / 2,
                y: lineStartPoint.y - pointerSize.height / 2
            ),
            size: pointerSize
        )

        // 更新 endPointerView 的位置
        endPointerView.frame = NSRect(
            origin: CGPoint(
                x: lineEndPoint.x - pointerSize.width / 2,
                y: lineEndPoint.y - pointerSize.height / 2
            ),
            size: pointerSize
        )
    }


    func setComponentData(component:Component,ratio:Double){
        startPoint = component.startPoint
        endPoint = component.endPoint
        self.ratio = ratio
        color = component.color
        boardWidth = component.boardWidth
    }
    
    
    var draggingStart = false
    var draggingEnd = false

    override func mouseDown(with event: NSEvent) {
        print("arrow mouse down")
        let location = convert(event.locationInWindow, from: nil)
        print("location:\(location)\nstart:\(startPointerView.frame)\nend\(endPointerView.frame)")
        
        if startPointerView.frame.contains(location) {
            draggingStart = true
        } else if endPointerView.frame.contains(location) {
            draggingEnd = true
        }
    }

    override func mouseDragged(with event: NSEvent) {
        print("arrow mouse Dragged")
        let location = convert(event.locationInWindow, from: nil)
        
        if draggingStart {
            print("s:\(startPoint):L:\(location)")
            startPoint = location
            needsDisplay = true
        } else if draggingEnd {
            endPoint = location
            needsDisplay = true
        }
    }

    override func mouseUp(with event: NSEvent) {
        print("arrow mouse UP")
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
//        startPointerView.addTrackingArea(...) // 可選

        endPointerView.wantsLayer = true
        endPointerView.canDrawSubviewsIntoLayer = true

    }
}
