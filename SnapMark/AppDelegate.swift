//
//  AppDelegate.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/7/28.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var item : NSStatusItem? = nil
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item?.image = NSImage(systemSymbolName: "laptopcomputer.and.arrow.down", accessibilityDescription: nil)
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open File", action: #selector(openHistoy), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "New Snap", action: #selector(newSnap), keyEquivalent: ""))
        item?.menu = menu
    }
    
    @objc func newSnap(_ sender:Any){
        print("hello")
        // 檢查目前視窗中是否有 MainViewController
        if let mainVC = NSApp.windows
            .compactMap({ $0.contentViewController as? MainViewController})
            .first {
            
            // 可選：確保視窗在最前面
            mainVC.view.window?.makeKeyAndOrderFront(nil)
            
            // ✅ 已存在 → 呼叫你要的 function
            mainVC.newSnap(self as Any)
            return
        }
        
        // 檢查目前所有視窗中是否有 LauncherViewController
        if let launcherVC = NSApp.windows
            .compactMap({ $0.contentViewController as? LauncherViewController })
            .first {
            
            // 可選：確保視窗在最前面
            launcherVC.view.window?.makeKeyAndOrderFront(nil)
            
            // ✅ 已存在 → 呼叫你要的 function
            launcherVC.newSnap()
            
            
            return
        }

        
        // ❌ 不存在 → 重新建立並顯示
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let launcherVC = storyboard.instantiateController(withIdentifier: "launcherViewController") as! LauncherViewController
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.contentViewController = launcherVC
        window.makeKeyAndOrderFront(nil)
        
        // ✅ 呼叫你要的 function
        launcherVC.newSnap()
        
        
    }
    
    @objc func openHistoy(_ sender:Any){
        print("world")
        // 檢查目前視窗中是否有 MainViewController
        if let mainVC = NSApp.windows
            .compactMap({ $0.contentViewController as? MainViewController})
            .first {
            
            // 可選：確保視窗在最前面
//            mainVC.view.window?.makeKeyAndOrderFront(nil)
            
            // ✅ 已存在 → 呼叫你要的 function
            mainVC.readFile( self as Any)
            return
        }
        
        
        // 檢查目前所有視窗中是否有 LauncherViewController
        if let launcherVC = NSApp.windows
            .compactMap({ $0.contentViewController as? LauncherViewController})
            .first {
            
            // 可選：確保視窗在最前面
            launcherVC.view.window?.makeKeyAndOrderFront(nil)
            
            // ✅ 已存在 → 呼叫你要的 function
            launcherVC.openHistory()
            return
        }

        
        // ❌ 不存在 → 重新建立並顯示
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let launcherVC = storyboard.instantiateController(withIdentifier: "launcherViewController") as! LauncherViewController
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.contentViewController = launcherVC
        window.makeKeyAndOrderFront(nil)
        
        // ✅ 呼叫你要的 function
        launcherVC.openHistory()
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    
}

