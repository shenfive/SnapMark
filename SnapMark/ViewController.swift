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
    @IBOutlet weak var fontButton: NSPopUpButton!
    @IBOutlet weak var fontSizeSlider: NSSlider!
    @IBOutlet weak var fontSizeLabel: NSTextField!
    
    
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
    let conerRadiusSelected = [0.0,5.0,10.0,20.0,100000.1] //最後一項是取半徑，即藥丸形
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

 
        //設定字型選擇器
        setFontButton()
        

        
        //設定字型大小
        fontSizeSlider.target = self
        fontSizeSlider.isContinuous = true
        fontSizeSlider.action = #selector(fontSizeChanged(_:))
        
        //顯示比例按制
        ratioSlider.target = self
        ratioSlider.isContinuous = true
        ratioSlider.action = #selector(ratioSliderDidChange(_:))
        
        //編輯區關連
        documentView.theImageView = self.theImageView
        documentView.color = colorWell.color
        documentView.boardWidth = boardWidthSelected[selectLineButton.indexOfSelectedItem]
        documentView.cornerRadius = conerRadiusSelected[selectConerRadius.indexOfSelectedItem]
        documentView.editMode = .ARROW

        //初始化編輯區
        if let image = theImageView.image{
            editingImage = image
            setImage()
        }

        //新增物件時的動作
        documentView.startAction = {
            self.documentView.subviews.forEach { view in
                if view.isKind(of: ControlView.self){
                    view.removeFromSuperview()
                }
            }
        }
        
        //完成新增物件時的動作
        documentView.endAction = {
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
            if $0.isKind(of: TextView.self) { $0.removeFromSuperview() }
        }
        components.forEach { component in
            switch component.componentType{
            case .ARROW:
                let arrowView = ArrowView(frame: component.framRect(ratio: ratioSlider.doubleValue))
                arrowView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
                arrowView.ratio = ratioSlider.doubleValue
                arrowView.color = component.color
                self.documentView.addSubview(arrowView)
                break
            case .BOX:
                let boxView = BoxView(frame: component.framRect(ratio: ratioSlider.doubleValue))
                boxView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
                boxView.ratio = ratioSlider.doubleValue
                boxView.color = component.color
                self.documentView.addSubview(boxView)
                break
            case .TEXT:
                let textView = TextView(frame: component.framRect(ratio: ratioSlider.doubleValue))
                textView.ratio = ratioSlider.doubleValue
                textView.setFont(font: NSFont(name: component.fontName, size: component.fontSize) ?? NSFont.systemFont(ofSize: component.fontSize))
                textView.color = component.color
                textView.enableEdit = false
                textView.fitSize()
                self.documentView.addSubview(textView)
            }
        }
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
    


    //MARK: 字形相關
    
    //設定字型大小動作
    @objc func fontSizeChanged(_ sender: Any){
        fontSizeLabel.stringValue = "\(fontSizeSlider.intValue)"
        setFont()
    }
    
    //選擇字形選單動作
    @objc func fontSelected(_ sender: NSMenuItem) {
        guard let font = sender.representedObject as? NSFont else { return }
        print("選擇字型：\(font.fontName), 大小：\(fontSizeSlider.intValue)")
        setFont()
    }
    
    //實作設定字形
    func setFont(){
        if let font = NSFont(name: fontButton.selectedItem?.title ?? "",
                             size: CGFloat(fontSizeSlider.doubleValue)){
            documentView.font = font
            documentView.redraw()
        }
    }
    
    //設定字形選單
    func setFontButton(){
        //設定選字型
        let fontMenu = NSMenu()
        // 加入 System Font 項目
        let systemFont = NSFont.systemFont(ofSize: 14)
        let systemAttrTitle = NSAttributedString(string: "System Font", attributes: [.font: systemFont])

        let systemItem = NSMenuItem()
        systemItem.attributedTitle = systemAttrTitle
        systemItem.representedObject = systemFont
        systemItem.action = #selector(fontSelected(_:))
        systemItem.target = self

        fontMenu.addItem(systemItem)

        // 加入其他字型家族
        for family in NSFontManager.shared.availableFontFamilies {
            guard let font = NSFont(name: family, size: 14) else { continue }
            let attrTitle = NSAttributedString(string: family, attributes: [.font: font])

            let item = NSMenuItem()
            item.attributedTitle = attrTitle
            item.representedObject = font
            item.action = #selector(fontSelected(_:))
            item.target = self

            fontMenu.addItem(item)
        }
        fontButton.menu = fontMenu
    }

    
    

    
    //設定顏色
    @IBAction func changeColor(_ sender: Any) {
        documentView.color = colorWell.color
        documentView.redraw()
    }
    
    
    //MARK:設定顯示比例
    
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
    //依 Slider 設定編輯區大小
    @objc func ratioSliderDidChange(_ sender:NSSlider){
        let value = sender.doubleValue * 100
        ratioLabel.stringValue = String(format: "%.1f%%", value).replacingOccurrences(of: ".0%", with: "%")
        documentView.ratio = sender.doubleValue
        setImage()
        documentView.redraw()
    }
    
    
    @IBAction func changeLineWidth(_ sender: Any) {
        documentView.boardWidth = boardWidthSelected[selectLineButton.indexOfSelectedItem]
        documentView.redraw()
    }
    
    //選擇圓角
    @IBAction func changeConerRadius(_ sender: Any) {
        documentView.cornerRadius = conerRadiusSelected[selectConerRadius.indexOfSelectedItem]
        documentView.redraw()
    }
    

    
    
    

    //重繪底圖
    func setImage(){
        if let newImage = resizedImage(editingImage, scale: ratioSlider.doubleValue){
            self.contentWidth.constant = min(self.contentContainerView.frame.width - 16, newImage.size.width - 1) + 16
            self.contentHeight.constant = min(self.contentContainerView.frame.height - 16, newImage.size.height - 1) + 16
            self.setModeDisplayUI()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01){
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
            self?.setFitWindowRatio(image)
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
    
    //設定編輯模式
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
        //箭頭移動的動畫
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            modeArrowPosition.animator().constant = sender.frame.minY + 20
        }
    }
    
    
    //修改圖片大小
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

    //外部視窗大小改變
    @objc func windowDidResize(_ notification: Notification) {
        setImage()
    }
}
