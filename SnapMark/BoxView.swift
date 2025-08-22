//
//  BoxView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/20.
//

import Cocoa

class BoxView: NSView {

    var color:NSColor!
    var lineWidth = 2.0
    var cornerRadius = 8.0
    var ratio = 1.0
    

    @IBOutlet weak var theBoxView: NSView!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        theBoxView.wantsLayer = true
        theBoxView.layer?.borderColor = color.cgColor
        theBoxView.layer?.borderWidth = lineWidth * ratio
        theBoxView.layer?.cornerRadius = cornerRadius
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
