//
//  ViewController.swift
//  ResizeImage
//
//  Created by Steven on 15/12/9.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let suportList = ["JPG", "jpg", "png", "PNG", "jpeg", "JPEG"]
    
    var inputFileList = [String]() {
        didSet {
            outputToUserLab.stringValue = "已经选择 \(inputFileList.count) 张图片"
            switch inputFileList.count {
            case 0:
                outputToUserLab.stringValue = "请选择需要转换的图片..."
                inputLab.stringValue = ""
            case 1:
                inputLab.stringValue = inputFileList[0]
            default:
                inputLab.stringValue = inputFileList.debugDescription
            }
        }
    }
    
    var outputDirPath: String? {
        didSet {
            outputLab.stringValue = outputDirPath ?? ""
        }
    }
    
    @IBOutlet weak var inputLab: NSTextField!
    @IBOutlet weak var outputLab: NSTextField!
    
    @IBOutlet weak var widthLab: NSTextField!
    @IBOutlet weak var heightLab: NSTextField!
    
    @IBOutlet weak var outputToUserLab: NSTextField!
    
    @IBAction func onStartBtnClick(sender: NSButton) {

        let list = inputFileList
        let width = Int(widthLab.stringValue)
        let height = Int(heightLab.stringValue)
        
        if list.count == 0 {
            outputToUserLab.stringValue = "请选择输入文件"
            return
        } else if outputDirPath == nil {
            outputToUserLab.stringValue = "请选择输出目录"
            return
        } else if width == nil || height == nil {
            outputToUserLab.stringValue = "请输入: width,height"
            return
        }
        
        // 压缩图片
        let size = NSSize(width: width!, height: height!)
        sender.enabled = false
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            for var i = 0; i < list.count; i++ {
                let path = list[i]
                let fileName = (path as NSString).lastPathComponent
                let savePath = (self.outputDirPath! as NSString).stringByAppendingPathComponent(fileName)
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.outputToUserLab.stringValue = "\(fileName)\n\(i)/\(list.count)"
                })
                if let image = NSImage(contentsOfFile: path) {
                    image.resizingMode = .Stretch
                    image.size = size
                    image.saveAsPNGatPath(savePath)
                }
            }
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.inputFileList.removeAll()
                sender.enabled = true
            })
        }
    }
    
    // 选择输入文件
    @IBAction func onInputBtnTouch(sender: AnyObject) {
        inputFileList.removeAll()
        let panel = createPlanel(true)
        if panel.runModal() == NSModalResponseOK {
            // 遍历出文件
            var fileList = [String]()
            let fileManager = NSFileManager.defaultManager()
            var isDirectory : ObjCBool = false
            for url in panel.URLs {
                if let path = url.path where fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) {
                    if (isDirectory) {
                        fileList.appendContentsOf(recursiveFileList(url.path!))
                    } else {
                        fileList.append(url.path!)
                    }
                }
            }
            inputFileList = fileList
        }
    }
    
    // 选择输出目录
    @IBAction func onOutputBtnTouch(sender: AnyObject) {
        outputDirPath = nil
        let panel = createPlanel(false)
        if panel.runModal() == NSModalResponseOK {
            if let path = panel.URLs[0].path {
                outputDirPath = path
            }
        }
    }
    
    // 递归获取目录下的所有图片文件
    func recursiveFileList(dir: String) -> [String] {
        var fileList = [String]()
        let fileManager = NSFileManager.defaultManager()
        let directoryEnumerator = fileManager.enumeratorAtPath(dir)
        var isDirectory : ObjCBool = false
        if let directoryEnumerator = directoryEnumerator {
            var file = directoryEnumerator.nextObject() as? String
            while file != nil {
                file = (dir as NSString).stringByAppendingPathComponent(file!)
                
                if fileManager.fileExistsAtPath(file!, isDirectory: &isDirectory) {
                    if isDirectory {
                        // 目录
                        fileList.appendContentsOf( recursiveFileList(file!) )
                    } else if suportList.contains( (file! as NSString).pathExtension ) {
                        // 文件
                        fileList.append(file! as String)
                    }
                }
                // 下一个文件
                file = directoryEnumerator.nextObject() as? String
            }
        }
        return fileList
    }

    // 创建一个文件选择面板
    func createPlanel(isIn: Bool) -> NSOpenPanel {
        let panel = NSOpenPanel()
        panel.canChooseFiles = isIn
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = isIn
        panel.allowsOtherFileTypes = false
        panel.allowedFileTypes = suportList
        panel.canCreateDirectories = !isIn
        return panel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    

}

