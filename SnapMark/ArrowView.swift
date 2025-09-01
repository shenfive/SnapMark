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

        // 主線外框（白色）
        let outerPath = NSBezierPath()
        outerPath.move(to: lineStartPoint)
        outerPath.line(to: adjustedEndPoint)
        outerPath.lineWidth = (boardWidth * ratio) + 2.0
        NSColor.white.setStroke()
        outerPath.stroke()

        // 主線本體（主色）
        let innerPath = NSBezierPath()
        innerPath.move(to: lineStartPoint)
        innerPath.line(to: adjustedEndPoint)
        innerPath.lineWidth = boardWidth * ratio
        color.setStroke()
        innerPath.stroke()

        // 箭頭左右邊緣描邊（避免底部白線）
        let edgePath = NSBezierPath()
        edgePath.move(to: leftPoint)
        edgePath.line(to: lineEndPoint)
        edgePath.line(to: rightPoint)
        NSColor.white.setStroke()
        edgePath.lineWidth = 1.0
        edgePath.stroke()

        // 箭頭主體（實心三角形）
        let arrowPath = NSBezierPath()
        arrowPath.move(to: lineEndPoint)
        arrowPath.line(to: leftPoint)
        arrowPath.line(to: rightPoint)
        arrowPath.close()
        color.setFill()
        arrowPath.fill()
    }

    func setComponentData(component:Component,ratio:Double){
        startPoint = component.startPoint
        endPoint = component.endPoint
        self.ratio = ratio
        color = component.color
        boardWidth = component.boardWidth
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
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.width, .height]
        self.addSubview(contentView)
    }
    
}
