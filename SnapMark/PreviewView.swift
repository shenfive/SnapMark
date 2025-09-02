//
//  PreviewView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/1.
//

import Cocoa

class PreviewView: NSView {
    
    private var trackingArea: NSTrackingArea?
    
    var mouseOverEnterAction:((Int)->())? = nil
    var mouseOverExitAction:((Int)->())? = nil
    
    var componentId:Int = 999
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateTrackingAreas()
    }
    
    
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeInActiveApp,
            .inVisibleRect
        ]
        
        trackingArea = NSTrackingArea(rect: bounds,
                                      options: options,
                                      owner: self,
                                      userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("hover enter:\(componentId)")
        mouseOverEnterAction?(componentId)
    }
    
    override func mouseExited(with event: NSEvent) {
        print("hover exit:\(componentId)")
        mouseOverExitAction?(componentId)
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
        Bundle.main.loadNibNamed("PreviewView", owner: self, topLevelObjects: &topLevelObjects)

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
    }

}
