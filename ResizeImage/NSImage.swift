//
//  NSImage.swift
//  ResizeImage
//
//  Created by Steven on 15/12/9.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Cocoa

public extension NSImage {
    /**
     保存NSImage到文件
     
     - parameter path:       路径
     - parameter atomically: atomically
     
     - returns: 是否成功
     */
    public func saveAsPNGatPath(path:String, atomically: Bool = true) -> Bool {
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(self.size.width), pixelsHigh: Int(self.size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bytesPerRow: 0, bitsPerPixel: 0)!
        bitmap.size = self.size
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrentContext(NSGraphicsContext(bitmapImageRep: bitmap))
        self.drawAtPoint(CGPoint.zero, fromRect: NSRect.zero, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        if let imagePGNData: NSData = bitmap.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: [NSImageCompressionFactor: 1.0]) {
            return imagePGNData.writeToFile((path as NSString).stringByStandardizingPath, atomically: atomically)
        } else {
            return false
        }
    }
}
