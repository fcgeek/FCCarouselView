//
//  ImageManager.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/3.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit
import Foundation

class ImageManager {
    static let shareManager = ImageManager()
    var imageDict = [String:UIImage]()
    private let notFoundImage: UIImage = {
        let frameworkBundle = NSBundle(forClass: FCCarouselView.ImageManager.self)
        let imagePath = frameworkBundle.pathForResource("imageNotFound", ofType: "png")!
        return UIImage(contentsOfFile: imagePath)!
    }()
    
    typealias DownloadClosure = (UIImage)->()
    func downloadImageWithURL(url: NSURL, downloadClosure: DownloadClosure) {
        if let image = imageDict[url.absoluteString] {
            downloadClosure(image)
            return
        }
        NSURLSession.sharedSession().dataTaskWithURL(url) { [unowned self](data, response, error) in
            if let error = error {
                self.imageUrlNotFound(url, downloadClosure: downloadClosure)
                return
            }
            guard let data = data else { return }
            guard let image = UIImage(data: data) else {
                self.imageUrlNotFound(url, downloadClosure: downloadClosure)
                return
            }
            self.imageDict[url.absoluteString] = image
            dispatch_async(dispatch_get_main_queue(), { 
                downloadClosure(image)
            })
            }.resume()
    }
    
    private func imageUrlNotFound(url:NSURL, downloadClosure: DownloadClosure) {
        self.imageDict[url.absoluteString] = notFoundImage
        downloadClosure(notFoundImage)
    }
}
