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
        
        // 設定線條顏色
        color.set()

        var lineStartPoint = CGPoint(x: 0, y:0)
        var lineEndPoint = CGPoint(x: 0, y: 0)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        
        lineStartPoint = CGPoint(x:(dx >= 0 ? 0:bounds.width) , y:( dy >= 0 ? 0:bounds.height))
        lineEndPoint = CGPoint(x: (dx >= 0 ?bounds.width:0), y: (dy >= 0 ? bounds.height:0) )
        
        // 箭頭方向向量
        let adx = lineEndPoint.x - lineStartPoint.x
        let ady = lineEndPoint.y - lineStartPoint.y
        let length = sqrt(adx*adx + ady*ady)
        if length > 0 {
            // 畫箭頭
            let ux = adx / length
            let uy = ady / length
            
            // 箭頭兩邊的向量（旋轉 ±60°）
            func rotatedVector(angle: CGFloat) -> CGPoint {
                let cosA = cos(angle)
                let sinA = sin(angle)
                return CGPoint(
                    x: ux * cosA - uy * sinA,
                    y: ux * sinA + uy * cosA
                )
            }
            
            let arrowLength: CGFloat = min(length, (15 + boardWidth) * ratio)
            let arrowAngle: CGFloat = 30.0 * (.pi / 180.0) // 60° in radians
            
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
                        
            
            // 箭頭（實心三角形）
            let arrowPath = NSBezierPath()
            arrowPath.move(to: lineEndPoint)
            arrowPath.line(to: leftPoint)
            arrowPath.line(to: rightPoint)
            arrowPath.close()

            color.setFill()
            arrowPath.fill()
            
            let inset: CGFloat = boardWidth * ratio
            let adjustedEndPoint = CGPoint(
                x: lineEndPoint.x - inset * ux,
                y: lineEndPoint.y - inset * uy
            )
            
            // 建立主線 path
            let path = NSBezierPath()
            path.move(to: lineStartPoint)
            path.line(to: adjustedEndPoint)
            path.lineWidth = boardWidth * ratio
            path.stroke()
        }
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
