//
//  ViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/7/28.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var theImageView: NSImageView!
    @IBOutlet weak var documentView: NSView!
    
    @IBOutlet weak var contentScrollView: NSScrollView!
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
        controller?.onCaptureComplete = { [weak self] image in
            self?.theImageView.image = nil
            self?.theImageView.image = image
            self?.theImageView.frame.size = image.size
            self?.documentView.frame.size = image.size
        }
        controller?.startCapture(from: mainWindow)
    }
    
}

