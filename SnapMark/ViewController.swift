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
    
    @IBOutlet weak var ratioSlider: NSSlider!
    @IBOutlet weak var ratioLabel: NSTextField!
    
    @IBOutlet weak var contentContainerView: NSView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: NSScrollView!
    
    var captureController:ScreenCaptureController? = ScreenCaptureController()
    
    var editingImage:NSImage = NSImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratioSlider.target = self
        ratioSlider.isContinuous = true
        ratioSlider.action = #selector(ratioSliderDidChange(_:))
        
        if let image = theImageView.image{
            editingImage = image
            setImage()
        }
     
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
    

    @objc func ratioSliderDidChange(_ sender:NSSlider){
        print(sender.doubleValue)
        let value = sender.doubleValue * 100
        ratioLabel.stringValue = String(format: "%.1f%%", value).replacingOccurrences(of: ".0%", with: "%")

        setImage()
    }
    
    @IBAction func resetRatio(_ sender: Any) {
        ratioSlider.doubleValue = 1.0
        ratioSliderDidChange(ratioSlider)
    }
    
    func setImage(){
        if let newImage = resizedImage(editingImage, scale: ratioSlider.doubleValue){
            contentWidth.constant = min(contentContainerView.frame.width, newImage.size.width)
            contentHeight.constant = min(contentContainerView.frame.height, newImage.size.height)
            documentView.frame.size = newImage.size
            theImageView.image = newImage
            theImageView.frame = documentView.bounds
  
        }
    }
    
    
    @IBAction func newSnap(_ sender: NSButton) {
        guard let mainWindow = self.view.window else { return }
        controller?.onCaptureComplete = { [weak self] image in
            self?.editingImage = image
            self?.setImage()
        }
        controller?.startCapture(from: mainWindow)
    }
    
    func resizedImage(_ image: NSImage, scale: Double) -> NSImage? {
        guard scale > 0.01, scale <= 2.0 else { return nil }

        let newSize = NSSize(width: image.size.width * scale,
                             height: image.size.height * scale)

        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }

    
}

