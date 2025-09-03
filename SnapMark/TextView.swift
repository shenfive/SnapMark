//
//  TextView.swift
//  SnapMark
//
//  Created by Danny Shen on 2025/8/26.
//

import Cocoa

class TextView: NSView {
    
    @IBOutlet weak var textField: TransparentTextField!
    @IBOutlet weak var frontBox: NSBox!
    @IBOutlet weak var endBox: NSBox!
    
    
    var startPoint:NSPoint = .zero
    var color:NSColor = NSColor.blue
    var ratio:CGFloat = 1.0
    
    var strokeColor:NSColor = .white
    var strokeWidth:CGFloat = 2.0
    
    var dataIndex:Int = 99999
    var changeTextCallBack:((String,Int)->())? = nil
    var endEdingCallBack:((String,Int)->())? = nil
    
    var enableEdit:Bool  {
        get{
            return frontBox.isHidden
        }
        set{
            frontBox.isHidden = !newValue
            endBox.isHidden = !newValue
            textField.isEditable = newValue
            textField.isSelectable = true
            
            //自動開始編輯
            if newValue == true {
                if let window = textField.window {
                    window.makeFirstResponder(textField)
                }
            }
        }
    }
    
    /// 控制是否讓事件穿透
    var isMouseTransparent: Bool  {
        get{
            return textField.isMouseTransparent
        }
        set{
            textField.isMouseTransparent = newValue
        }
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    
    func fitSize(){
        print("string\(textField.stringValue)")
        textField.sizeToFit()
        textField.textColor = color
        let newSize = textField.frame.size
        self.frame.size = NSSize(width: newSize.width + 20,
                                 height: newSize.height + 20)
    }
    
    func setEditMode(on:Bool){
        
    }
    
    func setFont(font:NSFont){
        textField.textColor = color
        if let theFont = NSFont(name: font.fontName, size: font.pointSize * ratio){
            textField.font = theFont
        }else{
            textField.font = NSFont.systemFont(ofSize: font.pointSize * ratio)
        }
        fitSize()
        applyStroke()
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
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        
        textField.delegate = self
        textField.isEditable = false
        textField.isSelectable = false
        
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func applyStroke() {
        let text = textField.stringValue
        let font = textField.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = strokeWidth * ratio
        shadow.shadowOffset = .zero
        shadow.shadowColor = strokeColor
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .shadow: shadow
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        textField.attributedStringValue = attributedString
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
        
        
        print("文字已變更完成")
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
        let maxWidth: CGFloat = 1920 // 可自訂最大寬度
        let boundingRect = attributed.boundingRect(
            with: NSSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        
        let paddedSize = NSSize(width: ceil(boundingRect.width) + 20,
                                height: ceil(boundingRect.height) + 20)
        
        // 更新 textField 和父視圖大小
        textField.frame.size = paddedSize
        self.frame.size = paddedSize
        
        //完成文字修改回Call
        self.changeTextCallBack?(currentText,dataIndex)
        return true
    }
}

