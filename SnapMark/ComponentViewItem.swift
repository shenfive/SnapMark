//
//  ComponentViewItem.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/29.
//

import Cocoa

class ComponentViewItem: NSCollectionViewItem {
    
    private var trackingArea: NSTrackingArea?

    @IBOutlet weak var itemBox: NSBox!
    @IBOutlet weak var preView: PreviewView!
    
    var componentId:Int = 999
    var selectAction:((Int)->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemBox.titlePosition = .atTop

        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        preView.componentId = componentId
    }

    override func mouseDown(with event: NSEvent) {
        print("down:\(componentId)")
        selectAction?(componentId)
    }
    

}
