//
//  TextView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/26.
//

import Cocoa

class TextView: NSView {

    @IBOutlet weak var textField: NSTextField!
    
    
    var startPoint:NSPoint = .zero
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    

    func fitSize(){
        print("string\(textField.stringValue)")
        textField.sizeToFit()
        let newSize = textField.frame.size
        self.frame.size = NSSize(width: newSize.width + 20,
                                 height: newSize.height + 20)
    }
    
    func setFont(font:NSFont){
        textField.font = font
    }
    
    func setTextDelegate(){
        
        if let editor = textField.window?.fieldEditor(true, for: textField) as? NSTextView {
            editor.delegate = self
        }
    }
    
    
    @IBAction func updateText(_ sender: Any) {
        fitSize()
    }
    
    
    
    
    // MARK: - Initializers
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        var topLevelObjects: NSArray?
        Bundle.main.loadNibNamed("TextView", owner: self, topLevelObjects: &topLevelObjects)
        
        guard let views = topLevelObjects as? [Any],
              let contentView = views.first(where: { $0 is NSView }) as? NSView else {
            return
        }
        
        textField.delegate = self
        
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.width, .height]
        self.addSubview(contentView)
    }
    
    
}
extension TextView: NSTextFieldDelegate, NSTextViewDelegate {
        func controlTextDidBeginEditing(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField,
                  let editor = textField.window?.fieldEditor(true, for: textField) as? NSTextView else {
                print("尚未取得編輯器")
                return
            }

            editor.delegate = self
            print("成功取得 NSTextView 編輯器：\(editor)")
        }

        func textDidChange(_ notification: Notification) {
            print("文字已變更")
        }

        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            print("即將插入：\(replacementString ?? "")")
            
            // 模擬輸入後的文字
            let currentText = (textView.string as NSString).replacingCharacters(in: affectedCharRange, with: replacementString ?? "")
            
            // 建立 AttributedString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: textView.font ?? NSFont.systemFont(ofSize: 14)
            ]
            let attributed = NSAttributedString(string: currentText, attributes: attributes)
            
            // 計算文字尺寸
            let maxWidth: CGFloat = 1000 // 可自訂最大寬度
            let boundingRect = attributed.boundingRect(
                with: NSSize(width: maxWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading]
            )
            
            let paddedSize = NSSize(width: ceil(boundingRect.width) + 20,
                                    height: ceil(boundingRect.height) + 20)
            
            // 更新 textField 和父視圖大小
            textField.frame.size = paddedSize
            self.frame.size = paddedSize
            return true
        }
    }

