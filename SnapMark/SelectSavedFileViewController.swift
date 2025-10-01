//
//  SelectSavedFileViewController.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/9/24.
//

import Cocoa

class SelectSavedFileViewController: NSViewController {

    @IBOutlet weak var theCollectionView: NSCollectionView!
    @IBOutlet weak var fileLocationLabel: NSTextField!
    
    
    var dataFiles:[URL] = []
    
    var selectedFileAction:((URL)->())? = nil
    
    var workingURL:URL? = nil //要排除正在工作中的檔案
    
    //Cell Size
    let cellSize = NSSize(width: 120, height: 170)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theCollectionView.delegate = self
        theCollectionView.dataSource = self
        
        showFileLocation()
        
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
    
    //顯示資料匣位置
    func showFileLocation(){
        if let fileLocation = SMFireManager.shared.snapMarkFolderURL?.absoluteString {
            
            let folderType = SMFireManager.shared.identifyCloudService()
            switch folderType{
            case .GoogleDrive:
                fileLocationLabel.stringValue = "Google Drive【 \(fileLocation) 】"
            case .OneDrive:
                fileLocationLabel.stringValue = "One Drive【 \(fileLocation) 】"
            case .iCloud:
                fileLocationLabel.stringValue = "iCloud【 \(fileLocation) 】"
            case .unknown:
                fileLocationLabel.stringValue = "Local Folder【 \(fileLocation) 】"
            }
            
        }else{
            fileLocationLabel.stringValue = "unknow location"
        }
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
            window.title = "Select Snap"
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        reloadData()
    }
    
    func reloadData(){
        if let folder = SMFireManager.shared.snapMarkFolderURL {
            if let files = listFiles(in: folder){
                self.dataFiles = files.sorted(by: { u1, u2 in
                    u1.lastPathComponent > u2.lastPathComponent
                })
                
                
                if let workingURL{
                    //排除目前的檔案名稱
                    self.dataFiles  = self.dataFiles.filter {
                        $0.lastPathComponent != workingURL.lastPathComponent
                    }
                    //只保留最後的字元
                    self.dataFiles = self.dataFiles.filter {
                        $0.lastPathComponent.contains(".sm")
                    }
                }
                self.theCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func changeFolderAction(_ sender: Any) {
        SMFireManager.shared.promptUserToSelectSnapMarkLocation(view:self.view){
            if SMFireManager.shared.snapMarkFolderURL != nil {
                self.showFileLocation()
            }
            self.reloadData()
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
            let parts = fileURL.lastPathComponent.components(separatedBy: ["_", "."])
            if parts.count >= 2 {
                let timestamp = parts[1]  // "23110747"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyMMdd"  // 假設是「年年月月日日」格式

                if let date = dateFormatter.date(from: parts[0]) {
                    dateFormatter.dateFormat = "yyyy/MM/dd"
                    let formattedDate = dateFormatter.string(from: date)
                    selectViewItem.fileTitle = "\(formattedDate)\n\(timestamp)"
                } else {
                    //print("無法解析日期")
                    selectViewItem.fileTitle = fileURL.lastPathComponent
                }
                
            }else{
                selectViewItem.fileTitle = fileURL.lastPathComponent
            }
        }catch{
            print(error.localizedDescription)
        }
        selectViewItem.fileURL = fileURL
        selectViewItem.reloadMenuAction = {
            self.reloadData()
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
