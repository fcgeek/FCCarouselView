//
//  ImageManager.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/3.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit
import Foundation
import ImageIO

class ImageManager {
    
    static let shareManager = ImageManager()
    //Memory
    private let memoryCache = NSCache()
    ///The disk cache location.
    public let diskCachePath: String
    private let ioQueue: dispatch_queue_t
    private var fileManager: NSFileManager!
    typealias DownloadClosure = (UIImage)->()
    
    init() {
        let cacheName = "FCCarouselView.ImageManager.memoryCache.by.liujianlin"
        memoryCache.name = cacheName
        let dstPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        diskCachePath = (dstPath as NSString).stringByAppendingPathComponent(cacheName)
        ioQueue = dispatch_queue_create("\(cacheName).ioQueue", DISPATCH_QUEUE_SERIAL)
        dispatch_sync(ioQueue, { () -> Void in
            self.fileManager = NSFileManager()
        })
    }
    
    func downloadImageWithURL(url: NSURL, downloadClosure: DownloadClosure) {
        if let image = memoryCache.objectForKey(url.absoluteString) as? UIImage {
            downloadClosure(image)
            return
            
        } else if let image = diskImageForKey(url.absoluteString) {
            downloadClosure(image)
            return
        }
        NSURLSession.sharedSession().dataTaskWithURL(url) { [unowned self](data, response, error) in
            if let error = error {
                self.imageUrlNotFound(url, downloadClosure: downloadClosure)
                return
            }
            guard let data = data else { return }
            guard let image = self.getImageWithData(data) else {
                self.imageUrlNotFound(url, downloadClosure: downloadClosure)
                return
            }
            self.storeImage(image, forKey: url.absoluteString)
            dispatch_async(dispatch_get_main_queue(), {
                downloadClosure(image)
            })
            }.resume()
    }
    
    private func getImageWithData(data:NSData) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithData(data, nil) else { return nil }
        let count = CGImageSourceGetCount(imageSource)
        if count > 1 {
            var images = [UIImage]()
            var duration:Float = 0
            for index in 0...count {
                guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else { continue }
                duration += durationWithSourceAtIndex(imageSource, index: index)
                images.append(UIImage(CGImage: cgImage))
            }
            if duration.isZero { duration = 0.1*Float(count) }
            return UIImage.animatedImageWithImages(images, duration: NSTimeInterval(duration))
            
        } else {
            return UIImage(data: data)
        }
    }
    
    /**
     获取每一帧图片的时长
     */
    private func durationWithSourceAtIndex(source: CGImageSource, index: Int) -> Float {
        var duration: Float = 0.1
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: AnyObject] else { return duration }
        guard let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: AnyObject] else { return duration }
        if let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
            return delayTime.floatValue
            
        } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime  as String] as? NSNumber {
            return delayTime.floatValue
        }
        return duration
    }
    
    /**
     找不到图片或者图片有问题
     */
    private func imageUrlNotFound(url:NSURL, downloadClosure: DownloadClosure) {
        memoryCache.setObject(notFoundImage, forKey: url.absoluteString)
        downloadClosure(notFoundImage)
    }
    
    /**
     Store an image to cache. It will be saved to both memory and disk. It is an async operation.
     
     - parameter image:             The image to be stored.
     - parameter originalData:      The original data of the image.
     Kingfisher will use it to check the format of the image and optimize cache size on disk.
     If `nil` is supplied, the image data will be saved as a normalized PNG file.
     It is strongly suggested to supply it whenever possible, to get a better performance and disk usage.
     - parameter key:               Key for the image.
     */
    private func storeImage(image: UIImage, originalData: NSData? = nil, forKey key: String) {
        memoryCache.setObject(image, forKey: key)
        dispatch_async(ioQueue, {
            if let data = originalData {
                if !self.fileManager.fileExistsAtPath(self.diskCachePath) {
                    do {
                        try self.fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                    } catch _ {}
                }
                
                self.fileManager.createFileAtPath(self.cachePathForKey(key), contents: data, attributes: nil)
            }
        })
    }
    
    /**
     从手机储存中拿图片
     */
    private func diskImageForKey(key: String) -> UIImage? {
        let filePath = cachePathForKey(key)
        guard let data = NSData(contentsOfFile: filePath) else { return nil }
        return UIImage(data: data)
    }
    
    private func cachePathForKey(key: String) -> String {
        return (diskCachePath as NSString).stringByAppendingPathComponent(key)
    }
    
    //MARK: getter
    /// 找不到图片
    private let notFoundImage: UIImage = {
        let frameworkBundle = NSBundle(forClass: FCCarouselView.ImageManager.self)
        let imagePath = frameworkBundle.pathForResource("imageNotFound", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()
}
