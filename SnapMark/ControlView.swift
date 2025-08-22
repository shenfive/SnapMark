//
//  ControlView.swift
//  Wow  Artist!
//
//  Created by 申潤五 on 2017/7/11.
//  Copyright © 2017年 申潤五. All rights reserved.
//

import Cocoa


class ControlView: NSView {
    
//    weak var sourceVC:ViewController? = nil
    
    var componentView:NSView = NSView()
    var componentType:COMPONET_TYPE = .ARROW
    
    @IBOutlet var view: NSView!
    
    var startViewRect = NSRect()
    var startContentRect = NSRect()
    var actionID = ""
    var startMousePoint = NSPoint(x: 0, y: 0)
//    var startCenter = NSPoint(x: 0, y: 0)
//    var startOrginNoRotate = NSPoint(x: 0, y: 0)
//    var startRotate = CGFloat(0)
//    var holdedView:NSView? = nil
//    var startHoldedViewRect = NSRect(x: 0, y: 0, width: 0, height: 0)
//    var startHoldedViewNoRotate = NSRect(x: 0, y: 0, width: 0, height: 0)
//    var startComPositionX = 0
//    var startComPositionY = 0
//    var startComWidth = 0
//    var startComHeight = 0
//    var startPlayItemPostionX = 0
//    var startPlayItemPostionY = 0
//    var startPlayItemHeight = 0
//    var startPlayItemWidth = 0
//    var startPlayItemRotation = 0.0
//    var componentIslock = false
   
    

    //了解目前鍵盤狀況
    var cmdFlag = false
    var shiftFlag = false
    var ctrlFlag = false
    var optionFlag = false

    var conviews:[NSImageView] = [NSImageView]()
    var sizeviews:[NSImageView] = [NSImageView]()

    @IBOutlet weak var contentArea: NSView!
    
    @IBOutlet weak var cont1: NSImageView!
    @IBOutlet weak var cont2: NSImageView!
    @IBOutlet weak var cont3: NSImageView!
    @IBOutlet weak var cont4: NSImageView!
    @IBOutlet weak var cont6: NSImageView!
    @IBOutlet weak var cont7: NSImageView!
    @IBOutlet weak var cont8: NSImageView!
    @IBOutlet weak var cont9: NSImageView!

    @IBOutlet weak var size1: NSImageView!
    @IBOutlet weak var size2: NSImageView!
    @IBOutlet weak var size3: NSImageView!
    @IBOutlet weak var size4: NSImageView!
    @IBOutlet weak var size6: NSImageView!
    @IBOutlet weak var size7: NSImageView!
    @IBOutlet weak var size8: NSImageView!
    @IBOutlet weak var size9: NSImageView!
    
    @IBOutlet weak var rotateLT: NSImageView!
    @IBOutlet weak var rotateRT: NSImageView!
    @IBOutlet weak var rotateRB: NSImageView!
    @IBOutlet weak var rotateLB: NSImageView!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Bundle.main.loadNibNamed("ControlView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        self.view.frame = contentFrame
        self.translatesAutoresizingMaskIntoConstraints = true

        self.addSubview(self.view)

        let outsize:CGFloat = 5
        let rect = NSRect(x: contentArea.frame.origin.x - outsize,
                          y: contentArea.frame.origin.y - outsize,
                          width: contentArea.frame.size.width + outsize + outsize,
                          height: contentArea.frame.size.height + outsize + outsize)

        self.addTrackingArea(NSTrackingArea(rect: rect, options: [.activeAlways,.mouseEnteredAndExited,.mouseMoved], owner: self, userInfo: nil))
        
        self.addTrackingArea(NSTrackingArea(rect:cont1.frame, options:[.activeAlways,.mouseMoved],owner:self,userInfo: nil ))
        self.addTrackingArea(NSTrackingArea(rect:cont2.frame, options:[.activeAlways,.mouseMoved],owner:self,userInfo: nil ))
        self.addTrackingArea(NSTrackingArea(rect:cont3.frame, options:[.activeAlways,.mouseMoved],owner:self,userInfo: nil ))
        self.addTrackingArea(NSTrackingArea(rect:cont4.frame, options:[.activeAlways,.mouseMoved],owner:self,userInfo: nil ))
        self.addTrackingArea(NSTrackingArea(rect:cont6.frame, options:[.activeAlways,.mouseMoved],owner:self,userInfo: nil ))
        self.addTrackingArea(NSTrackingArea(rect:cont7.frame, options:[.activeAlways,.mouseMoved],owner:self,userInfo: nil ))
        self.addTrackingArea(NSTrackingArea(rect:cont8.frame, options:[.activeAlways,.mouseMoved],owner:self,userInfo: nil ))
        self.addTrackingArea(NSTrackingArea(rect:cont9.frame, options:[.activeAlways,.mouseMoved],owner:self,userInfo: nil ))

        startViewRect = self.frame
        contentArea.wantsLayer = true
        contentArea.layer?.borderColor = hexToCGColor(hexColor: "#4990e2")
        contentArea.layer?.borderWidth = 1
        hideControls()

        conviews.removeAll()
        sizeviews.removeAll()
        conviews = [cont1,cont2,cont3,cont4,cont6,cont7,cont8,cont9]
        sizeviews = [size1,size2,size3,size4,size6,size7,size8,size9]
        
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        print("TrackingAreas")
    }

   



    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed("ControlView", owner: self, topLevelObjects: nil)
        view.frame = self.bounds
        self.addSubview(self.view)
        self.addTrackingArea(NSTrackingArea(rect: self.frame, options: [.activeAlways,.mouseEnteredAndExited,.mouseMoved], owner: self, userInfo: nil))
        startViewRect = self.frame
        contentArea.wantsLayer = true
        contentArea.layer?.borderColor = CGColor.white
        contentArea.layer?.borderWidth = 4
        hideControls()

        conviews.removeAll()
        sizeviews.removeAll()
        conviews = [cont1,cont2,cont3,cont4,cont6,cont7,cont8,cont9]
        sizeviews = [size1,size2,size3,size4,size6,size7,size8,size9]

    }
    
    //不顯示所有的控制
    func hideControls(){
        size1.isHidden = true
        size2.isHidden = true
        size3.isHidden = true
        size4.isHidden = true
        size6.isHidden = true
        size7.isHidden = true
        size8.isHidden = true
        size9.isHidden = true

        rotateLB.isHidden = true
        rotateLT.isHidden = true
        rotateRB.isHidden = true
        rotateRT.isHidden = true
    }

    //顯示所有的控制
    func showSizeControls(){
        size1.isHidden = false
        size2.isHidden = false
        size3.isHidden = false
        size4.isHidden = false
        size6.isHidden = false
        size7.isHidden = false
        size8.isHidden = false
        size9.isHidden = false
    }
    
    //顯示轉
    func showRotate(){
        rotateLB.isHidden = false
        rotateLT.isHidden = false
        rotateRB.isHidden = false
        rotateRT.isHidden = false
    }

    //MARK:Keboard Events
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        let code = event.keyCode
        print("keyDown:\(code)")
        switch code{
        case 126://上
            print("上")
            break
        case 123://左
            print("左")
            break
        case 125://下
            print("下")
            break
        case 124://右
            print("右")
            break
        default:
            break
        }
    }
    
    

    func checkControlKeys(event:NSEvent){
        cmdFlag = event.modifierFlags.contains(.command) == true
        shiftFlag = event.modifierFlags.contains(.shift) == true
        optionFlag = event.modifierFlags.contains(.option) == true
        ctrlFlag = event.modifierFlags.contains(.control) == true
    }
    
    //MARK:MOUSE Events

    //滑鼠移動到
    override func mouseMoved(with event: NSEvent) {
        //滑鼠移動到控制點時出現大小控制標誌
        for i in 0...conviews.count-1{
            if isHover(checkView: conviews[i], position: event.locationInWindow) {
                if cmdFlag == true{
                    sizeviews[i].isHidden = true
                    showRotate()
                }else{
                    sizeviews[i].isHidden = false
                }
            }else{
                sizeviews[i].isHidden = true
            }
        }
        print("mouseMoved")
    }

    override func mouseDown(with event: NSEvent) {
//        if componentIslock == true { return }else{
            //print("no Lock")
//        }
        print("mouse down")
        
        //開始按下去的點
        startMousePoint = event.locationInWindow
        startViewRect = self.frame
        startContentRect = self.componentView.frame
        
        // 偵測按下去的區域 因為區域可能重疊，所以不可以改變順序
        if (isHover(checkView: contentArea, position: startMousePoint)){
            actionID = "5"}
        if (isHover(checkView: cont1, position: startMousePoint)){
            actionID = "1"
            size1.isHidden = false}
        if (isHover(checkView: cont2, position: startMousePoint)){
            actionID = "2"
            size2.isHidden = false}
        if (isHover(checkView: cont3, position: startMousePoint)){
            actionID = "3"
            size3.isHidden = false}
        if (isHover(checkView: cont4, position: startMousePoint)){
            actionID = "4"
            size4.isHidden = false}
        if (isHover(checkView: cont6, position: startMousePoint)){
            actionID = "6"
            size6.isHidden = false}
        if (isHover(checkView: cont7, position: startMousePoint)){
            actionID = "7"
            size7.isHidden = false}
        if (isHover(checkView: cont8, position: startMousePoint)){
            actionID = "8"
            size8.isHidden = false}
        if (isHover(checkView: cont9, position: startMousePoint)){
            actionID = "9"
            size9.isHidden = false}

        print("Mouse down ID:\(actionID)")
    }

    //抓移項目
    override func mouseDragged(with event: NSEvent) {
        print("mouseDragged")
        let currentMousePoint = event.locationInWindow
        let offsetX = currentMousePoint.x - startMousePoint.x
        let offsetY = currentMousePoint.y - startMousePoint.y
        print("OF:\(offsetX):\(offsetY)")
        
        
        switch actionID{
        case "5": // 移動
            let rect = NSRect(x:startViewRect.minX + offsetX,
                                y:startViewRect.minY + offsetY,
                                width: startViewRect.width,
                                height: startViewRect.height)
            self.frame = rect
            self.view.frame = self.bounds
            moveComponentOffset(offsetX:offsetX,offsetY: offsetY)
        case "1":
            let rect = NSRect(x:startViewRect.minX + offsetX,
                                y:startViewRect.minY,
                                width: startViewRect.width - offsetX,
                                height: startViewRect.height + offsetY)
            
            
            self.frame = rect
            self.view.frame = self.bounds
            print("rect:\(rect)")
            moveComponentOffset(offsetX:offsetX,offsetWidth: -offsetX,offsetHeight: offsetY)
        case "2":
            let rect = NSRect(x:startViewRect.minX,
                                y:startViewRect.minY,
                                width: startViewRect.width,
                                height: startViewRect.height + offsetY)
            self.frame = rect
            self.view.frame = self.bounds
            print("rect:\(rect)")
            moveComponentOffset(offsetHeight: offsetY)
        case "3"://
            let rect = NSRect(x:startViewRect.minX,
                                y:startViewRect.minY,
                                width: startViewRect.width + offsetX,
                                height: startViewRect.height + offsetY)
            self.frame = rect
            self.view.frame = self.bounds
            print("f:\(self.frame)")
            moveComponentOffset(offsetWidth: offsetX,offsetHeight: offsetY)
        case "4":
            let rect = NSRect(x:startViewRect.minX + offsetX,
                                y:startViewRect.minY,
                                width: startViewRect.width - offsetX,
                                height: startViewRect.height )
            self.frame = rect
            self.view.frame = self.bounds
            print("f:\(self.frame)")
            moveComponentOffset(offsetX: offsetX,offsetWidth: -offsetX)
        case "6":
            let rect = NSRect(x:startViewRect.minX,
                                y:startViewRect.minY,
                                width: startViewRect.width + offsetX,
                                height: startViewRect.height )
            self.frame = rect
            self.view.frame = self.bounds
            print("f:\(self.frame)")
            moveComponentOffset(offsetWidth: offsetX)
        case "7":
            let rect = NSRect(x:startViewRect.minX + offsetX,
                                y:startViewRect.minY + offsetY,
                                width: startViewRect.width - offsetX,
                                height: startViewRect.height - offsetY)
            self.frame = rect
            self.view.frame = self.bounds
            print("f:\(self.frame)")
            moveComponentOffset(offsetX: offsetX,offsetY: offsetY, offsetWidth: -offsetX, offsetHeight: -offsetY)
        case "8":
            let rect = NSRect(x:startViewRect.minX,
                                y:startViewRect.minY + offsetY,
                                width: startViewRect.width,
                                height: startViewRect.height - offsetY)
            self.frame = rect
            self.view.frame = self.bounds
            print("f:\(self.frame)")
            moveComponentOffset(offsetY: offsetY,  offsetHeight: -offsetY)
        case "9":
            let rect = NSRect(x:startViewRect.minX,
                                y:startViewRect.minY + offsetY,
                                width: startViewRect.width + offsetX,
                                height: startViewRect.height - offsetY)
            self.frame = rect
            self.view.frame = self.bounds
            print("f:\(self.frame)")
            moveComponentOffset(offsetY:offsetY,offsetWidth: offsetX,  offsetHeight: -offsetY)
        default:
            break
        }
        
        
    }
    
    func moveComponentOffset(offsetX x:CGFloat = 0,
                             offsetY y:CGFloat = 0,
                             offsetWidth width:CGFloat = 0,
                             offsetHeight height:CGFloat = 0){

//        let newRect = NSRect(x: startContentRect.minX + x ,
//                             y: startContentRect.minY + y ,
//                             width: startContentRect.width + width,
//                             height: startContentRect.height + height)
//        let newRect = NSRect(x:20,
//                             y:20,
//                             width: view.frame.width - 40,
//                             height: view.frame.height - 40)
        print("newRect:\(view.bounds)")
        switch componentType {
        case .TEXT:
            break
        case .ARROW:
            componentView.frame = self.frame
        case .BOX:
            componentView.frame = self.frame
        }
        
    }


    
    override func mouseUp(with event: NSEvent) {
        print("mouseUP")
        

    }
    
    
    func isHover(checkView:NSView,position:NSPoint)->Bool{
        var isHover = false
        let viewFrame = checkView.convert(checkView.bounds, to: nil)
        let viewOriginX = viewFrame.origin.x
        let viewOriginY = viewFrame.origin.y
        let viewMaxX = viewOriginX + viewFrame.size.width
        let viewMaxY = viewOriginY + viewFrame.size.height
        if( position.x >= viewOriginX &&
            position.x <= viewMaxX    &&
            position.y >= viewOriginY &&
            position.y <= viewMaxY ){
            isHover = true
        }
        return isHover
    }
}

extension ControlView{
    //將網頁用的 Hex Color 字串轉成 NSColor
    func hexToCGColor(hexColor:String,alpha:Int = 0) -> CGColor{
        //若空白就回透明
        if hexColor == ""{
            return CGColor.clear
        }
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var theAlpha:CGFloat = 0.0
        if let redDec = Int((hexColor as NSString).substring(with: NSMakeRange(1, 2)), radix:16),
            let greenDec = Int((hexColor as NSString).substring(with: NSMakeRange(3, 2)), radix:16),
            let blueDec = Int((hexColor as NSString).substring(with: NSMakeRange(5, 2)), radix:16)
        {
            red = CGFloat(redDec) / 255
            green = CGFloat(greenDec) / 255
            blue = CGFloat(blueDec) / 255
            print("alpha:\(alpha)")
            theAlpha = 1 - (CGFloat(alpha) / 255)
        }
        return CGColor(red: red, green: green, blue: blue, alpha: theAlpha)
    }

}
