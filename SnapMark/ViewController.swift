//
//  ViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/7/28.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var theImageView: NSImageView!
    
    
    var captureController:ScreenCaptureController? = ScreenCaptureController()
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = NSLocalizedString("SnapMark", comment: "Window 標題")
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    var controller:ScreenCaptureController? = ScreenCaptureController()
    @IBAction func newSnap(_ sender: NSButton) {

        guard let mainWindow = self.view.window else { return }
        
//        controller = ScreenCaptureController()
        controller?.onCaptureComplete = { [weak self] image in
            self?.theImageView.image = nil
            self?.theImageView.image = image
        }
        
        controller?.startCapture(from: mainWindow)
        
    }
    
}

