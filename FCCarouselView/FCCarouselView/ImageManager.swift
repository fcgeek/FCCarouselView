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
    fileprivate let memoryCache = NSCache<AnyObject, AnyObject>()
    ///The disk cache location.
    fileprivate let diskCachePath: String
    fileprivate let ioQueue: DispatchQueue
    fileprivate var fileManager: FileManager!
    typealias DownloadDoneClosure = (UIImage)->()
    
    init() {
        let cacheName = "FCCarouselView.ImageManager.memoryCache.by.liujianlin"
        memoryCache.name = cacheName
        memoryCache.countLimit = 20
        let dstPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        diskCachePath = (dstPath as NSString).appendingPathComponent(cacheName)
        ioQueue = DispatchQueue(label: "\(cacheName).ioQueue", attributes: [])
        ioQueue.sync(execute: { () -> Void in
            self.fileManager = FileManager()
        })
    }
    
    func downloadImageWithURL(_ url: URL, placeholder: UIImage?, downloadDoneClosure: @escaping DownloadDoneClosure) {
        func completed(_ image:UIImage) {
            DispatchQueue.main.async { 
                downloadDoneClosure(image)
            }
        }
        if let image = memoryCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            completed(image)
            return
            
        } else if let image = diskImageForKey(url.absoluteString) {
            memoryCache.setObject(image, forKey: url.absoluteString as AnyObject)
            completed(image)
            return
        }
        completed(placeholder ?? placeholderImage)
        URLSession.shared.dataTask(with: url, completionHandler: { [unowned self](data, response, error) in
            if error != nil {
                self.imageUrlNotFound(url, downloadClosure: completed)
                return
            }
            guard let data = data else { return }
            guard let image = self.getImageWithData(data) else {
                self.imageUrlNotFound(url, downloadClosure: completed)
                return
            }
            self.storeImage(image, forKey: url.absoluteString)
            completed(image)
            
            }) .resume()
    }
    
    fileprivate func getImageWithData(_ data:Data) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(imageSource)
        if count > 1 {
            var images = [UIImage]()
            var duration:Float = 0
            for index in 0...count {
                guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else { continue }
                duration += durationWithSourceAtIndex(imageSource, index: index)
                images.append(UIImage(cgImage: cgImage))
            }
            if duration.isZero { duration = 0.1*Float(count) }
            return UIImage.animatedImage(with: images, duration: TimeInterval(duration))
            
        } else {
            return UIImage(data: data)
        }
    }
    
    /**
     获取每一帧图片的时长
     */
    fileprivate func durationWithSourceAtIndex(_ source: CGImageSource, index: Int) -> Float {
        let duration: Float = 0.1
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
    fileprivate func imageUrlNotFound(_ url:URL, downloadClosure: DownloadDoneClosure) {
        memoryCache.setObject(notFoundImage, forKey: url.absoluteString as AnyObject)
        downloadClosure(notFoundImage)
    }
    
    /**
     Store an image to cache. It will be saved to both memory and disk. It is an async operation.
     
     - parameter image:             The image to be stored.
     - parameter originalData:      The original data of the image.
     - parameter key:               Key for the image.
     */
    fileprivate func storeImage(_ image: UIImage, originalData: Data? = nil, forKey key: String) {
        memoryCache.setObject(image, forKey: key as AnyObject)
        ioQueue.async(execute: {
            if let data = originalData {
                if !self.fileManager.fileExists(atPath: self.diskCachePath) {
                    do {
                        try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                    } catch _ {}
                }
                
                self.fileManager.createFile(atPath: self.cachePathForKey(key), contents: data, attributes: nil)
            }
        })
    }
    
    /**
     从手机储存中拿图片
     */
    fileprivate func diskImageForKey(_ key: String) -> UIImage? {
        let filePath = cachePathForKey(key)
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return nil }
        return UIImage(data: data)
    }
    
    fileprivate func cachePathForKey(_ key: String) -> String {
        return (diskCachePath as NSString).appendingPathComponent(key)
    }
    
    //MARK: getter
    /// 找不到图片
    fileprivate let notFoundImage: UIImage = {
        let frameworkBundle = Bundle(for: FCCarouselView.ImageManager.self)
        let imagePath = frameworkBundle.path(forResource: "imageNotFound", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()
    
    
    fileprivate let placeholderImage: UIImage = {
        let frameworkBundle = Bundle(for: FCCarouselView.ImageManager.self)
        let imagePath = frameworkBundle.path(forResource: "placeholder", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()
}
