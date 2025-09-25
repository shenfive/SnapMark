//
//  ViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/7/28.
//

import Cocoa




class MainViewController: NSViewController {

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
    @IBOutlet weak var fontSampleLabel: NSTextField!
    
    @IBOutlet weak var itemCollectionView: NSCollectionView!
    
    
    //附加元件
    var components:[Component] = []
    
    // 正在進行的操作檔案位置
    var currentFileUrl:URL? = nil
    
    //拮取畫面控制器
    var controller:ScreenCaptureController? = ScreenCaptureController()
    
    //編輯中的影像
    var editingImage:NSImage = NSImage()
    
    //頁面的 Window
//    var window:NSWindow!
    
    //line width
    let boardWidthSelectMenuList = [2.0,5.0,10.0]

    //cornerRadius
    let conerRadiusSelectMenuList = [0.0,5.0,10.0,20.0,100000.1] //最後一項是取半徑，即藥丸形
    
    //FontFemily
    var fontFemilySelectMenuList = ["System Font"]
    
    //Cell Size
    let cellSize = NSSize(width: 86.0 / 3.0 * 4.0, height: 86.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Collection View 設定
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = cellSize
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        itemCollectionView.collectionViewLayout = flowLayout
        itemCollectionView.isSelectable = true
        itemCollectionView.enclosingScrollView?.hasHorizontalScroller = false
        itemCollectionView.enclosingScrollView?.hasVerticalScroller = true

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
        documentView.boardWidth = boardWidthSelectMenuList[selectLineButton.indexOfSelectedItem]
        documentView.cornerRadius = conerRadiusSelectMenuList[selectConerRadius.indexOfSelectedItem]
        documentView.editMode = .ARROW


        //新增物件時的動作
        documentView.startAction = {
            //移除空白字串的 TextView
            self.components.removeAll {
                $0.componentType == .TEXT && $0.text.isEmpty
            }
            
            //先設定取消選取
            for i in self.components.indices {
                self.components[i].isSelected = false
            }
            //結束所有編輯
            for view in self.documentView.subviews{
                view.window?.makeFirstResponder(nil)
            }
            self.itemCollectionView.reloadData()
        }
        
        //完成新增物件時的動作
        documentView.endAction = {

                        
            self.components.append(self.documentView.getComponet(ratio: self.ratioSlider.doubleValue))
            switch self.components.last?.componentType{
            case .TEXT:
                self.components[self.components.count-1].isSelected = true
            default:
                break
            }
            DispatchQueue.main.async {
                self.reDrawComponts()
                self.itemCollectionView.reloadData()
            }

            //回傳物件View
            print($0)
        }
     
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
        //初始化晝面大小 與標題
        if let window = self.view.window ,
           let screenFrame = NSScreen.main?.frame {
            
            let windowSize = NSSize(width: 1400, height: 800)
            let originX = (screenFrame.width - windowSize.width) / 2
            let originY = (screenFrame.height - windowSize.height) / 2
            let centeredRect = NSRect(origin: CGPoint(x: originX, y: originY), size: windowSize)
            window.minSize = NSSize(width: 700, height: 500)
            window.setFrame(centeredRect, display: true)
            window.title = "Snap Mark‼️  💻 👀" //NSLocalizedString("SnapMark", comment: "Window 標題")
            setModeDisplayUI()
            //初始化編輯區
//            if let image = theImageView.image{
//                editingImage = image
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
//                    self.setImage()
//                }
//            }

        }
        

        //抓取外部視窗動作
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize(_:)),
            name: NSWindow.didResizeNotification,
            object: self.view.window
        )
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        initView()
    
    }
    
    func initView(){
        //若沒有檔名，建立新檔案
        if let url = currentFileUrl{
            do {
                let snap = try SMFireManager.shared.loadPackage(from: url)
                self.editingImage = snap.bg
                self.setImage()
                let theComponents =  Component.decodeComponents(from: snap.metadata) ?? []
                self.components = theComponents
                self.reDrawComponts()
                self.itemCollectionView.reloadData()
            }catch{
                print(error.localizedDescription)
            }

        }else{
            openFile()
        }
    }
    
    //於預設資料匣建立檔案
    func openFile(){
        self.setImage()
        if let url = SMFireManager.shared.getDefaultFileURL() {
            self.currentFileUrl = url
            do {
                try SMFireManager.shared.savePackage(to: url,
                                                     bgImage: self.editingImage,
                                                     thumbIamge: self.editingImage,
                                                     json: "")
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    
    //MARK: 重畫所有元件
    func reDrawComponts(){

        //移除標註文件
        self.documentView.subviews.forEach {
            if $0.isKind(of: ArrowView.self) { $0.removeFromSuperview() }
            if $0.isKind(of: BoxView.self) { $0.removeFromSuperview() }
            if $0.isKind(of: TextView.self) { $0.removeFromSuperview() }
            if $0.isKind(of: SelectView.self) {$0.removeFromSuperview()}
        }
     

        documentView.selectedSubView = nil
        
        //重繪標註文件
        for index in 0..<components.count{
            let component = components[index]
            switch component.componentType{
            case .ARROW:
                let arrowView = ArrowView(frame: component.framRect(ratio: ratioSlider.doubleValue))
                arrowView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
                self.documentView.addSubview(arrowView)
                if component.isMouseOverMode{
                    let editView = SelectView(frame: arrowView.frame)
                    self.documentView.addSubview(editView)
                }
                arrowView.enableEdit =  component.isSelected
                if component.isSelected {
                    documentView.selectedSubView = arrowView
                    
                    //設定 UI
                    self.colorWell.color = component.color
                    if let boardIndex = boardWidthSelectMenuList.firstIndex(of: component.boardWidth){
                        self.selectLineButton.selectItem(at: boardIndex)
                    }
                    
                 
                }
                arrowView.endEditAction = {
                    self.components[index] = $0
                    self.reDrawComponts()
                    self.itemCollectionView.reloadData()
                }
            
            case .BOX:
                let boxView = BoxView(frame: component.framRect(ratio: ratioSlider.doubleValue))
                boxView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
       
                self.documentView.addSubview(boxView)
                if component.isMouseOverMode{
                    let editView = SelectView(frame: boxView.frame)
                    print("e:\(editView.frame)")
                    self.documentView.addSubview(editView)
                }
                boxView.enableEdit = component.isSelected
                if component.isSelected {
                    documentView.selectedSubView = boxView
                    
                    //設定 UI
                    self.colorWell.color = component.color
                    if let boardIndex = boardWidthSelectMenuList.firstIndex(of: component.boardWidth){
                        self.selectLineButton.selectItem(at: boardIndex)
                    }
                    if let conerIndex = conerRadiusSelectMenuList.firstIndex(of: component.cornerRadius){
                        self.selectConerRadius.selectItem(at: conerIndex)
                    }
                    
                }
                boxView.endEditAction = {
                    self.components[index] = $0
                    self.reDrawComponts()
                    self.itemCollectionView.reloadData()
                }
                
       
            case .TEXT:
                print("show:\(index) string:\(component.text)")
                let textView = TextView()
                textView.dataIndex = index
                textView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
                textView.changeTextCallBack = { newString, dataIndex in
                    self.components[dataIndex].text = newString
                    self.itemCollectionView.reloadItems(at: [IndexPath(item: dataIndex, section: 0)])
                }
                textView.endEdingCallBack = { newString, dataIndex in
                    
                    self.components[dataIndex].text = newString
                    self.itemCollectionView.reloadItems(at: [IndexPath(item: dataIndex, section: 0)])
                    self.reDrawComponts()
                }
                self.documentView.addSubview(textView)

                if component.isSelected{
                    documentView.selectedSubView = textView
                    
                    //設定 UI
                    self.colorWell.color = component.color
                    if let boardIndex = boardWidthSelectMenuList.firstIndex(of: component.boardWidth){
                        self.selectLineButton.selectItem(at: boardIndex)
                    }
                    self.fontSizeSlider.doubleValue = component.fontSize
                    self.fontSizeLabel.stringValue = "\(fontSizeSlider.intValue)"
                    
                }
                textView.enableEdit = component.isSelected
                textView.endEditAction = {
                    self.components[index] = $0
                    self.reDrawComponts()
                    self.itemCollectionView.reloadData()
                }
                if component.isMouseOverMode{
                    let editView = SelectView(frame: textView.frame)
                    self.documentView.addSubview(editView)
                }

            }
        }
        
        //更新實體檔案
        if let url = self.currentFileUrl {
            self.currentFileUrl = url
            do {
                try SMFireManager.shared.updateJSON(in: url,
                                                    newJSONString: getComponentsJSON() ?? "")
                if let image = snapshot(of: documentView){
                    if let thumbImage = resizeToFitThumb(image){
                        try SMFireManager.shared.updateThumb(in: url, newThumb:thumbImage)
                    }
                }
            }catch{
                print(error.localizedDescription)
            }
        }
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
            fontSampleLabel.font = font
            fontSampleLabel.textColor = colorWell.color
            documentView.redraw()
            if let index = components.firstIndex(where: { $0.isSelected }) {
                components[index].fontName = font.fontName
                components[index].fontSize = font.pointSize
                reDrawComponts()
            }
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
            self.fontFemilySelectMenuList.append(family)
            let item = NSMenuItem()
            item.attributedTitle = attrTitle
            item.representedObject = font
            item.action = #selector(fontSelected(_:))
            item.target = self

            fontMenu.addItem(item)
        }
        print(self.fontFemilySelectMenuList)
        fontButton.menu = fontMenu
    }

    
    

    
    //設定顏色
    @IBAction func changeColor(_ sender: Any) {
        documentView.color = colorWell.color
        documentView.redraw()
        if let index = components.firstIndex(where: { $0.isSelected }) {
            components[index].color = documentView.color
            reDrawComponts()
        }

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
        setRatio()
    }
    func setRatio(){
        documentView.ratio = ratioSlider.doubleValue
        setImage()
        documentView.redraw()
    }
    
    //MARK:設定線寬
    @IBAction func changeLineWidth(_ sender: Any) {
        documentView.boardWidth = boardWidthSelectMenuList[selectLineButton.indexOfSelectedItem]
        documentView.redraw()
    
        if let index = components.firstIndex(where: { $0.isSelected }) {
            components[index].boardWidth = documentView.boardWidth
            reDrawComponts()
        }
        
    }
    
    //選擇圓角
    @IBAction func changeConerRadius(_ sender: Any) {
        documentView.cornerRadius = conerRadiusSelectMenuList[selectConerRadius.indexOfSelectedItem]
        documentView.redraw()
        if let index = components.firstIndex(where: { $0.isSelected }) {
            components[index].cornerRadius = documentView.cornerRadius
            reDrawComponts()
        }
    }

    //重繪底圖
    func setImage(){
        if let newImage = resizedImage(editingImage, scale: ratioSlider.doubleValue){
            //因為與 UI 相關，放在主執行緒才會出現預期的畫面，並利用時間差來正確製造正確的順序與大小
            self.theImageView.image = newImage
            
            self.contentWidth.constant = min(self.contentContainerView.frame.width, newImage.size.width + 16)
            self.contentHeight.constant = min(self.contentContainerView.frame.height, newImage.size.height + 16)
            self.contentContainerView.layoutSubtreeIfNeeded()
            self.setModeDisplayUI()
            self.documentView.frame.size = newImage.size
            self.documentView.layoutSubtreeIfNeeded()
            self.theImageView.frame = self.documentView.bounds
//            self.reDrawComponts()
            
        }
    }
    
    
    //MARK: 新增拮圖
    @IBAction func newSnap(_ sender: Any) {
        guard let mainWindow = self.view.window else { return }
        controller?.onCaptureComplete = { [weak self] image in
            self?.editingImage = image
            self?.components.removeAll()
            self?.itemCollectionView.reloadData()
            self?.openFile()
//            self?.setFitWindowRatio(self as Any)
        }
        controller?.startCapture(from: mainWindow)
    }
    
    //MARK: 設定編輯模式
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
    
    //MARK: 讀檔
    @IBAction func readFile(_ sender: Any) {
        let nextVC = SelectSavedFileViewController()
        nextVC.selectedFileAction = {
            self.currentFileUrl = $0
            self.initView()
        }
        self.presentAsModalWindow(nextVC)
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
    
    


    //外部視窗大小改變
    @objc func windowDidResize(_ notification: Notification) {
        setImage()
    }
    
    /// 計算 aspectFit 並回傳 rect 與縮放比例
    func aspectFitRectAndScale(contentRect: NSRect, containerRect: NSRect) -> (rect: NSRect, scale: CGFloat) {
        let contentSize = contentRect.size
        let containerSize = containerRect.size

        let contentAspect = contentSize.width / contentSize.height
        let containerAspect = containerSize.width / containerSize.height

        var fitSize: NSSize
        var scale: CGFloat

        if contentAspect > containerAspect {
            // 限制寬度
            scale = containerSize.width / contentSize.width
            fitSize = NSSize(width: containerSize.width,
                             height: contentSize.height * scale)
        } else {
            // 限制高度
            scale = containerSize.height / contentSize.height
            fitSize = NSSize(width: contentSize.width * scale,
                             height: containerSize.height)
        }

        // 計算置中位置
        let originX = containerRect.origin.x + (containerSize.width - fitSize.width) / 2
        let originY = containerRect.origin.y + (containerSize.height - fitSize.height) / 2

        let newRect = NSRect(origin: NSPoint(x: originX, y: originY), size: fitSize)
        
        return (rect: newRect, scale: scale)
    }
    
    
    func getComponentsJSON()->String?{
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let jsonData = try encoder.encode(components)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("JSON 字串：\n\(jsonString)")
                return jsonString
            }
        } catch {
            print("編碼失敗：\(error)")
            return nil
        }
        return nil
    }
    
    

}

extension MainViewController:NSCollectionViewDelegate,NSCollectionViewDataSource{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        components.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let component = components[indexPath.item]
        let componentViewItem = ComponentViewItem(nibName: "ComponentViewItem", bundle: nil)
        componentViewItem.view.bounds.size = cellSize
        componentViewItem.itemBox.bounds.size = cellSize
        componentViewItem.componentId = indexPath.item
        
        //按下去時的動作
        componentViewItem.selectAction = {
            if self.components[$0].isSelected == true {
                self.components[$0].isSelected = false
            }else{
                for index in 0..<self.components.count{
                    self.components[index].isSelected = false
                }
                self.components[$0].isSelected = true
            }
            self.itemCollectionView.reloadData()
            self.reDrawComponts()
        }
        
        if component.isSelected {
            componentViewItem.itemBox.borderColor = .red
            componentViewItem.itemBox.borderWidth = 3
        }
        componentViewItem.mouseOverEnterAction = {
            print("on Main Enter:\($0)")
            if self.components[$0].isSelected != true{
                self.components[$0].isMouseOverMode = true
                self.reDrawComponts()
            }
            componentViewItem.deleteButton.isHidden = false
        }
        componentViewItem.mouseOverExitAction = {
            print("on Main Exit:\($0)")
            self.components[$0].isMouseOverMode = false
            componentViewItem.deleteButton.isHidden = true
            self.reDrawComponts()
        }
        componentViewItem.deleteAction = {
            let alert = NSAlert()
            alert.messageText = "提示"
            alert.informativeText = "刪除這個元件？"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "確定")
            alert.addButton(withTitle: "取消")

            // 指定圖示
            if let image = snapshot(of: componentViewItem.preView) {
                alert.icon = image
            }
            
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // 使用者按下「確定」
                self.components.remove(at: indexPath.item)
                self.reDrawComponts()
                self.itemCollectionView.reloadData()
            }
        }

        switch component.componentType{
        case .ARROW:
            componentViewItem.itemBox.title = "Arrow"
            let arrowView = ArrowView(frame: component.framRect(ratio: 1))
            arrowView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
            let newVeiwSeting = aspectFitRectAndScale(contentRect: arrowView.frame, containerRect: componentViewItem.preView.bounds)
            arrowView.ratio = newVeiwSeting.scale
            arrowView.frame = newVeiwSeting.rect
            componentViewItem.preView.addSubview(arrowView)
        case .BOX:
            componentViewItem.itemBox.title = "Box"
            let boxView = BoxView(frame: component.framRect(ratio: 1))
            boxView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
            let newVeiwSeting = aspectFitRectAndScale(contentRect: boxView.frame, containerRect: componentViewItem.preView.bounds)
            boxView.ratio = newVeiwSeting.scale
            boxView.frame = newVeiwSeting.rect
            componentViewItem.preView.addSubview(boxView)
       
        case .TEXT:
            let textView = TextView()
            textView.setComponentData(component: component, ratio: ratioSlider.doubleValue)
            textView.frame = componentViewItem.preView.bounds
            textView.isMouseTransparent = true
            componentViewItem.preView.addSubview(textView)
        }
        return componentViewItem
    }
}
