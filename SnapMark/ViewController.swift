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
    
    var window:NSWindow!
    
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
    
    @objc func windowDidResize(_ notification: Notification) {
        print("Window resized to: \(window.frame.size)")
        setImage()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard let window = view.window else {return}
        self.window = window
        view.window?.title = NSLocalizedString("SnapMark", comment: "Window 標題")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize(_:)),
            name: NSWindow.didResizeNotification,
            object: self.window
        )
    }
    

    var controller:ScreenCaptureController? = ScreenCaptureController()
    

    @objc func ratioSliderDidChange(_ sender:NSSlider){
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
            self.contentWidth.constant = min(self.contentContainerView.frame.width - 16, newImage.size.width - 1) + 16
            self.contentHeight.constant = min(self.contentContainerView.frame.height - 16, newImage.size.height - 1) + 16
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                self.documentView.frame.size = newImage.size
                self.theImageView.image = newImage
                self.theImageView.frame = self.documentView.bounds
            }
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
