//
//  ComponentViewItem.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/29.
//

import Cocoa

class ComponentViewItem: NSCollectionViewItem {

    
    @IBOutlet weak var itemBox: NSBox!
    @IBOutlet weak var preView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
