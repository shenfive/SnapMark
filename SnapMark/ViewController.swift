//
//  ViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/7/28.
//

import Cocoa




class ViewController: NSViewController {

    @IBOutlet weak var theImageView: NSImageView!
    @IBOutlet weak var documentView: SnapEditView!
    
    @IBOutlet weak var ratioSlider: NSSlider!
    @IBOutlet weak var ratioLabel: NSTextField!
    
    @IBOutlet weak var contentContainerView: NSView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: NSScrollView!
    @IBOutlet weak var colorWell: NSColorWell!
    
    @IBOutlet weak var modeImage: NSImageView!
    @IBOutlet weak var selectLineButton: NSPopUpButton!
    
    @IBOutlet weak var arrowModeButton: NSButton!
    @IBOutlet weak var textModeButton: NSButton!
    @IBOutlet weak var boxModeButton: NSButton!
    @IBOutlet weak var modeArrowPosition: NSLayoutConstraint!
    
    @IBOutlet weak var selectConerRadius: NSPopUpButton!
    
    
//    //控制顯示
//    let cView = ControlView()
    
    //附加元件
    var components:[Component] = []
    
    
    //拮取畫面控制器
    var controller:ScreenCaptureController? = ScreenCaptureController()
    
    //編輯中的影像
    var editingImage:NSImage = NSImage()
    
    //頁面的 Window
    var window:NSWindow!
    
    //line width
    let boardWidthSelected = [2.0,5.0,10.0]

    //cornerRadius
    let conerRadiusSelected = [0.0,5.0,10.0,20.0,100000.1]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        // 設定 FontManager 的 target
        NSFontManager.shared.target = self
        
        
        //顯示比例按制
        ratioSlider.target = self
        ratioSlider.isContinuous = true
        ratioSlider.action = #selector(ratioSliderDidChange(_:))
        
        //編輯區關連
        documentView.theImageView = self.theImageView
        documentView.color = colorWell.color
        documentView.lineWidth = boardWidthSelected[selectLineButton.indexOfSelectedItem]
        documentView.cornerRadius = conerRadiusSelected[selectConerRadius.indexOfSelectedItem]
        documentView.editMode = .ARROW

        //初始化編輯區
        if let image = theImageView.image{
            editingImage = image
            setImage()
        }

        
        documentView.startAction = {
            self.documentView.subviews.forEach { view in
                if view.isKind(of: ControlView.self){
                    view.removeFromSuperview()
                }
            }
        }
        
        documentView.endAction = {
//            let controlViewRect = NSRect(x: self.documentView.newView.frame.minX - 20,
//                                 y: self.documentView.newView.frame.minY - 20,
//                                 width: self.documentView.newView.frame.width + 40,
//                                 height: self.documentView.newView.frame.height + 40)
//
//            cView.componentType = self.documentView.editMode
//
//            self.documentView.addSubview(cView)
     
            self.components.append(self.documentView.getComponet(ratio: self.ratioSlider.doubleValue))
            
            self.reDrawComponts()
            //回傳物件View
            print($0)
            
        }
     
    }
    
    func reDrawComponts(){
        self.documentView.subviews.forEach {
            if $0.isKind(of: ArrowView.self) { $0.removeFromSuperview() }
            if $0.isKind(of: BoxView.self) { $0.removeFromSuperview() }
        }
        components.forEach { component in
            switch component.componentType{
            case .ARROW:
                let arrowView = ArrowView(frame: component.framRect(ratio: ratioSlider.doubleValue))
                arrowView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
                arrowView.ratio = ratioSlider.doubleValue
                self.documentView.addSubview(arrowView)
                break
            case .BOX:
                let boxView = BoxView(frame: component.framRect(ratio: ratioSlider.doubleValue))
                boxView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
                boxView.ratio = ratioSlider.doubleValue
                self.documentView.addSubview(boxView)
                break
            case .TEXT:
                break
            }
        }
    }

    
    //外部視窗大小改變
    @objc func windowDidResize(_ notification: Notification) {
        setImage()
      
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard let window = view.window else {return}
        self.window = window
        view.window?.title = "Snap Mark‼️  💻 👀" //NSLocalizedString("SnapMark", comment: "Window 標題")
        //抓取外部視窗動作
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize(_:)),
            name: NSWindow.didResizeNotification,
            object: self.window
        )
      
        
    }
    


    @IBAction func callFontSetting(_ sender: Any) {
        NSFontManager.shared.orderFrontFontPanel(self)
    }

    @objc func changeFont(_ sender: Any?) {
        documentView.font = NSFontManager.shared.selectedFont ?? NSFont.systemFont(ofSize: 14)
    }
    

    
    //設定顏色
    @IBAction func changeColor(_ sender: Any) {
        documentView.color = colorWell.color
    }
    
    
    //設定顯示比例
    
    //符合目前視窗
    @IBAction func setFitWindowRatio(_ sender: Any) {
        let original = NSSize(width: self.theImageView.image!.size.width / self.ratioSlider.doubleValue  + 14,
                              height: self.theImageView.image!.size.height / self.ratioSlider.doubleValue + 14)
        let target = NSSize(width: self.contentContainerView.frame.size.width ,
                            height: self.contentContainerView.frame.size.height )
        let widthScale = target.width / original.width
        let heightScale = target.height / original.height
        
        let scale = min(widthScale, heightScale)
        
        self.ratioSlider.doubleValue = scale
        self.documentView.ratio = scale
        self.ratioSliderDidChange(self.ratioSlider)
    }
    //原始解析度
    @IBAction func resetRatio(_ sender: Any) {
        ratioSlider.doubleValue = 1.0
        documentView.ratio = 1.0
        ratioSliderDidChange(ratioSlider)
    }
    //依 Slider 設定
    @objc func ratioSliderDidChange(_ sender:NSSlider){
        let value = sender.doubleValue * 100
        ratioLabel.stringValue = String(format: "%.1f%%", value).replacingOccurrences(of: ".0%", with: "%")
        documentView.ratio = sender.doubleValue
        setImage()
    }
    
    
    @IBAction func changeLineWidth(_ sender: Any) {
        documentView.lineWidth = boardWidthSelected[selectLineButton.indexOfSelectedItem]
    }
    
    @IBAction func changeConerRadius(_ sender: Any) {
        documentView.cornerRadius = conerRadiusSelected[selectConerRadius.indexOfSelectedItem]
    }
    
    
    
    
    func setImage(){
        if let newImage = resizedImage(editingImage, scale: ratioSlider.doubleValue){
            self.contentWidth.constant = min(self.contentContainerView.frame.width - 16, newImage.size.width - 1) + 16
            self.contentHeight.constant = min(self.contentContainerView.frame.height - 16, newImage.size.height - 1) + 16
            self.setModeDisplayUI()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001){
                self.documentView.frame.size = newImage.size
                self.theImageView.image = newImage
                self.theImageView.frame = self.documentView.bounds
                self.reDrawComponts()
            }
        }
    }
    
    
    @IBAction func newSnap(_ sender: NSButton) {
        guard let mainWindow = self.view.window else { return }
        controller?.onCaptureComplete = { [weak self] image in
            self?.editingImage = image
            self?.components.removeAll()
            self?.setImage()
            
        }
        controller?.startCapture(from: mainWindow)
    }
    
    
    @IBAction func setArrowMode(_ sender: Any) {
        documentView.editMode = .ARROW
        setModeDisplayUI()
    }
    
    @IBAction func setTextMode(_ sender: Any) {

        documentView.editMode = .TEXT
        setModeDisplayUI()
    }
    @IBAction func setBoxMode(_ sender: Any) {
        documentView.editMode = .BOX
        setModeDisplayUI()
    }
    
    func setModeDisplayUI(){
        var sender = NSButton()
        switch documentView.editMode {
        case .TEXT:
            sender = textModeButton
        case .ARROW:
            sender = arrowModeButton
        case .BOX:
            sender = boxModeButton
        }
        
        modeArrowPosition.constant = sender.frame.minY + 20
    }
    
    
    func resizedImage(_ image: NSImage, scale: Double) -> NSImage? {
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
