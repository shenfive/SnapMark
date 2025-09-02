//
//  BoxView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/20.
//

import Cocoa

class BoxView: NSView {

    var color:NSColor!
    var         boardWidth = 2.0
    var cornerRadius = 8.0
    var ratio = 1.0
    var startPoint = CGPoint(x: 0, y: 0)
    var endPoint = CGPoint(x: 0, y: 0)
    

    @IBOutlet weak var theBoxView: NSView!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        theBoxView.wantsLayer = true
        theBoxView.layer?.borderColor = color.cgColor
        
        theBoxView.layer?.borderWidth = boardWidth
        
        theBoxView.layer?.shadowColor = NSColor.white.cgColor
        theBoxView.layer?.shadowOpacity = 1
        theBoxView.layer?.shadowOffset = .zero
        theBoxView.layer?.shadowRadius = 1 * ratio
        
        let c = min(cornerRadius * ratio,theBoxView.frame.size.height / 2.0,theBoxView.frame.size.width / 2.0)
        theBoxView.layer?.cornerRadius = c
        
        if cornerRadius == 100000.1{
            theBoxView.layer?.cornerRadius = min(theBoxView.frame.height,theBoxView.frame.width) / 2
        }



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
        startPoint = component.startPoint
        endPoint = component.endPoint
        self.ratio = ratio
        cornerRadius = component.cornerRadius
        color = component.color
        boardWidth = component.boardWidth
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
