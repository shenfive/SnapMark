//
//  SelectSavedFileViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/24.
//

import Cocoa

class SelectSavedFileViewController: NSViewController {

    @IBOutlet weak var theCollectionView: NSCollectionView!
    
    
    var dataFiles:[URL] = []
    
    var selectedFileAction:((URL)->())? = nil
    
    //Cell Size
    let cellSize = NSSize(width: 150, height: 200)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theCollectionView.delegate = self
        theCollectionView.dataSource = self
        

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = cellSize
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        theCollectionView.collectionViewLayout = flowLayout
        theCollectionView.isSelectable = true
        theCollectionView.allowsMultipleSelection = false
        theCollectionView.enclosingScrollView?.hasHorizontalScroller = false
        theCollectionView.enclosingScrollView?.hasVerticalScroller = true
     
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if let window = self.view.window ,
           let screenFrame = NSScreen.main?.frame {
            // 固定視窗大小
            let windowSize = NSSize(width: 800, height: 600)
            let originX = (screenFrame.width - windowSize.width) / 2
            let originY = (screenFrame.height - windowSize.height) / 2
            let centeredRect = NSRect(origin: CGPoint(x: originX, y: originY), size: windowSize)
            
            window.setFrame(centeredRect, display: true)
            
            let fixedSize = NSSize(width: 800, height: 600)
            window.setContentSize(fixedSize)
            window.minSize = fixedSize
            window.maxSize = fixedSize
            window.styleMask.remove(.resizable)
            
            // 移除三個按鈕
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            // 可選：移除標題欄互動
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let folder = SMFireManager.shared.snapMarkFolderURL {
            if let files = listFiles(in: folder){
                self.dataFiles = files.sorted(by: { u1, u2 in
                    u1.lastPathComponent > u2.lastPathComponent
                })
                self.theCollectionView.reloadData()
            }
        }
    }
    
    func listFiles(in folderURL: URL) -> [URL]? {
        let fileManager = FileManager.default

        do {
            let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            return contents
        } catch {
            print("❌ 無法讀取資料匣內容：\(error)")
            return nil
        }
    }

    
    @IBAction func closeAction(_ sender: Any) {
        view.window?.close()
    }
    
    
}
extension SelectSavedFileViewController:NSCollectionViewDelegate,NSCollectionViewDataSource{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        dataFiles.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        let fileURL = dataFiles[indexPath.item]

        let selectViewItem = SelectSavedFileCollectionViewItem(nibName: "SelectSavedFileCollectionViewItem",
                                              bundle: nil)
        do {
            let snap = try SMFireManager.shared.loadPackage(from: fileURL)
            selectViewItem.fileThumb = snap.thumb
            selectViewItem.fileTitle = fileURL.lastPathComponent
        }catch{
            print(error.localizedDescription)
        }
        
        
        return selectViewItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        print("cL:\(indexPaths.first!.item)")
        let fileURL = dataFiles[indexPaths.first!.item]
        selectedFileAction?(fileURL)
        view.window?.close()
    }
    
    
}
