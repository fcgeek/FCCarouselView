//
//  CarouselView.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit

@objc public protocol CarouselViewDelegate: class {
    optional func carouselView(view:CarouselView, cellAtIndex index:NSInteger) -> UICollectionViewCell
    optional func carouselView(view:CarouselView, didSelectItemAtIndex index:NSInteger)
}

public struct CarouselData {
    public init(image:UIImage? = nil, imageURL:NSURL? = nil, detail:String? = nil) {
        self.image = image
        self.imageURL = imageURL
        self.detail = detail
    }
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
}

public class CarouselView: UIView {
    
    @IBOutlet public weak var delegate:CarouselViewDelegate?
    public var placeholderImage:UIImage?
    
    private var pageCount = 0
    private var timeInterval: NSTimeInterval = 3
    private var timer: NSTimer?
    private var enableAutoScroll = true
    private var isFirstLayout = true
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubView()
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview == nil {
            timer?.invalidate()
        }
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
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: pageControl.currentPage+1, inSection: 0), atScrollPosition: .None, animated: false)
        let size = pageControl.sizeForNumberOfPages(pageControl.numberOfPages)
        pageControl.frame.size.height = size.height
        pageControl.frame.origin.y = self.bounds.height - size.height
    }
    
    private func startTimer() {
        if !enableAutoScroll { return }
        timer?.invalidate()
        timer = NSTimer(timeInterval: timeInterval, target: self, selector: #selector(scrollNextPage), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func scrollNextPage() {
        let nextPageOffsetX = collectionView.contentOffset.x + collectionView.bounds.width
        collectionView.setContentOffset(CGPoint(x: nextPageOffsetX, y:0), animated: true)
    }
    
    //MARK: - like UICollectionView
    public func registerClass(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCellWithReuseIdentifier(identifier: String, forIndex index: Int) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: NSIndexPath(forRow: index, inSection: 0))
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
    public var dataSource = [Any]() {
        didSet {
            pageCount = dataSource.count
            pageControl.numberOfPages = pageCount
        }
    }
    
    public var autoScrollOptions: [AutoScrollOption]? {
        didSet {
            timer?.invalidate()
            if let options = autoScrollOptions {
                options.forEach({ (option) in
                    switch option {
                    case let .Enable(value):
                        enableAutoScroll = value
                        
                    case let .TimeInterval(value):
                        timeInterval = value
                    }
                })
            }
            if enableAutoScroll {
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
        if let cell = delegate?.carouselView?(self, cellAtIndex: index) {
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(CarouselCollectionViewCell), forIndexPath: indexPath) as! CarouselCollectionViewCell
        if let carouselData = dataSource[index] as? CarouselData {
            cell.carouselData = carouselData
        }
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
