//
//  SelectView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/2.
//

import Cocoa

class SelectView: NSView {

    @IBOutlet weak var outlineBox: NSBox!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        

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
        Bundle.main.loadNibNamed("SelectView", owner: self, topLevelObjects: &topLevelObjects)

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
