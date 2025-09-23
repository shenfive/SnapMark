//
//  SelectSavedFileCollectionViewItem.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/23.
//

import Cocoa

class SelectSavedFileCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var theImage: NSImageView!
    
    @IBOutlet weak var fileLabel: NSTextField!
    
    var fileThumb:NSImage? = nil
    var fileTitle = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        theImage.image = fileThumb
        fileLabel.stringValue = fileTitle
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
}
