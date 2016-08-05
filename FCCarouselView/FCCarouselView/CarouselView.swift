//
//  CarouselView.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit

@objc public protocol CarouselViewDelegate: class {
    optional func carouselView(view:CarouselView, cellForItemAtIndex index:NSInteger) -> UICollectionViewCell
    optional func carouselView(view:CarouselView, didSelectItemAtIndex index:NSInteger)
}

public struct CarouselData {
    public init() {}
    public var image: UIImage!
    public var imageURL: NSURL!
    public var detail: String!
}

public enum AutoScrollOption {
    case Enable(Bool)
    case TimeInterval(NSTimeInterval)
}

public enum PageControlOption {
    case Hidden(Bool)
    case IndicatorTintColor(UIColor)
    case CurrentIndicatorTintColor(UIColor)
    //    public var pageIndicatorTintColor: UIColor? { didSet { pageControl.pageIndicatorTintColor = pageIndicatorTintColor } }
    //    public var currentPageIndicatorTintColor: UIColor? { didSet { pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor } }
}

public class CarouselView: UIView {
    
    public weak var delegate:CarouselViewDelegate?
    private var pageCount = 0
    private var timeInterval:NSTimeInterval = 3
    private var timer: NSTimer?
    public var placeholderImage:UIImage?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubView()
    }
    
    private func setupSubView() {
        addSubview(collectionView)
        addSubview(pageControl)
        startTimer()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = bounds.size        
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = NSTimer(timeInterval: timeInterval, target: self, selector: #selector(scrollNextPage), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func scrollNextPage() {
        let nextPageOffsetX = collectionView.contentOffset.x + collectionView.bounds.width
        collectionView.setContentOffset(CGPoint(x: nextPageOffsetX, y:0), animated: true)
    }
    
    public func registerClass(cellClass: AnyClass) {
        collectionView.registerClass(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
    }
    
    //MARK: getter
    private lazy var collectionView: UICollectionView = {
        let flowLayout =  UICollectionViewFlowLayout()
        flowLayout.itemSize = self.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .Horizontal        
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.pagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(CarouselCollectionViewCell))
        collectionView.contentOffset.x = self.bounds.width
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: self.bounds)
        pageControl.pageIndicatorTintColor = UIColor.redColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.numberOfPages = self.pageCount
        pageControl.userInteractionEnabled = false
        let size = pageControl.sizeForNumberOfPages(pageControl.numberOfPages)
        pageControl.frame.size.height = size.height
        pageControl.frame.origin.y = self.bounds.height - size.height
        return pageControl
    }()
    
    //MARK: setter
    public var carouselDatas = [CarouselData]() {
        didSet {
            pageCount = carouselDatas.count
            pageControl.numberOfPages = pageCount
        }
    }
    
    public var autoScrollOptions: [AutoScrollOption]? {
        didSet {
            timer?.invalidate()
            var enable = true
            if let options = autoScrollOptions {
                options.forEach({ (option) in
                    switch option {
                    case let .Enable(value):
                        enable = value
                        
                    case let .TimeInterval(value):
                        timeInterval = value
                    }
                })
            }
            if enable {
                startTimer()
            }
        }
    }
    
    public var pageControlOptions: [PageControlOption]? {
        didSet {
            if let options = pageControlOptions {
                options.forEach({ (option) in
                    switch option {
                    case let .Hidden(value):
                        pageControl.hidden = value
                        
                    case let .IndicatorTintColor(value):
                        pageControl.pageIndicatorTintColor = value
                        
                    case let .CurrentIndicatorTintColor(value):
                        pageControl.currentPageIndicatorTintColor = value
                    }
                })
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CarouselView: UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount > 1 ? pageCount+2 : pageCount
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = getIndexWithIndexPath(indexPath)
        if let cell = delegate?.carouselView?(self, cellForItemAtIndex: index) {
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(CarouselCollectionViewCell), forIndexPath: indexPath) as! CarouselCollectionViewCell
        cell.carouselData = carouselDatas[index]
        return cell
    }
    
    private func getIndexWithIndexPath(indexPath:NSIndexPath) -> Int {
        var index = indexPath.row
        if indexPath.row < 1 {
            index = pageCount-1
            
        } else if indexPath.row > pageCount {
            index = 0
            
        } else {
            index = indexPath.row-1
        }
        return index
    }
}

// MARK: - UICollectionViewDelegate
extension CarouselView: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.carouselView?(self, didSelectItemAtIndex: getIndexWithIndexPath(indexPath))
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        timer?.invalidate()
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        calculatePage()
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        calculatePage()
    }
    
    /**
     计算页，循环
     */
    private func calculatePage() {
        let realCurrentPage = Int(collectionView.contentOffset.x/collectionView.frame.width)
        if realCurrentPage < 1 {
            pageControl.currentPage = pageCount - 1
            collectionView.contentOffset.x = collectionView.bounds.width*CGFloat(pageCount)
            
        } else if realCurrentPage > pageCount {
            pageControl.currentPage = 0
            collectionView.contentOffset.x = collectionView.bounds.width
            
        } else {
            pageControl.currentPage = realCurrentPage - 1
        }
    }
}
