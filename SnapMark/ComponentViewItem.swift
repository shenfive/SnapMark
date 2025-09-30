//
//  ComponentViewItem.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/29.
//

import Cocoa

class ComponentViewItem: NSCollectionViewItem {
    


    @IBOutlet weak var itemBox: NSBox!
    @IBOutlet weak var preView: PreviewView!
    @IBOutlet weak var deleteButton: NSButton!
    
    var component = Component()
    
    var componentId:Int = 999
    var selectAction:((Int)->())? = nil
    var mouseOverEnterAction:((Int)->())? = nil
    var mouseOverExitAction:((Int)->())? = nil
    var deleteAction:(()->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do view setup here.
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        print("right click")
        
        let menu = makeContextMenu()
        NSMenu.popUpContextMenu(menu, with: event, for: self.view)
    }

    func makeContextMenu() -> NSMenu {
        let menu = NSMenu(title: "Menu")
        menu.addItem(withTitle: "Delete Component", action: #selector(deleteItem(_:)), keyEquivalent: "")
        return menu
    }

    
    
    
    @objc func deleteItem(_ sender:Any?){
        deleteAction?()
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        preView.componentId = componentId
        preView.mouseOverEnterAction = mouseOverEnterAction
        preView.mouseOverExitAction = mouseOverExitAction
        deleteButton.isHidden = true
        
        
        if component.isSelected {
            itemBox.borderColor = .red
            itemBox.borderWidth = 3
        }
        
        switch self.component.componentType{
        case .ARROW:
            let arrowView = ArrowView(frame: component.framRect(ratio: 1))
            arrowView.setComponentData(component: component, ratio: 1)
            let newVeiwSeting = aspectFitRectAndScale(contentRect: arrowView.frame, containerRect: self.preView.bounds)
            arrowView.ratio = newVeiwSeting.scale
            arrowView.frame = newVeiwSeting.rect
            self.preView.addSubview(arrowView)
        case .BOX:
            let boxView = BoxView(frame: component.framRect(ratio: 1))
            boxView.setComponentData(component: component, ratio: 1)
            let newVeiwSeting = aspectFitRectAndScale(contentRect: boxView.frame, containerRect: self.preView.bounds)
            boxView.ratio = newVeiwSeting.scale
            boxView.frame = newVeiwSeting.rect
            self.preView.addSubview(boxView)
            
        case .TEXT:
            let textView = TextView()
            textView.setComponentData(component: component, ratio: 1)
            textView.frame = self.preView.bounds
            textView.isMouseTransparent = true
            self.preView.addSubview(textView)
            
        }
        
        
        
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
    

    override func mouseDown(with event: NSEvent) {
        print("down:\(componentId)")
        selectAction?(componentId)
    }
    
    @IBAction func menuAction(_ sender: NSButton) {
        let menu = makeContextMenu()
            let location = sender.convert(NSPoint(x: 0, y: sender.bounds.height), to: nil)
            let event = NSEvent.mouseEvent(
                with: .rightMouseDown,
                location: location,
                modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: sender.window?.windowNumber ?? 0,
                context: nil,
                eventNumber: 0,
                clickCount: 1,
                pressure: 1.0
            )

            if let event = event {
                NSMenu.popUpContextMenu(menu, with: event, for: sender)
            }
    }
    
}
