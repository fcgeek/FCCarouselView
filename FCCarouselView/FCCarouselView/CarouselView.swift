//
//  CarouselView.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit

@objc public protocol CarouselViewDelegate: class {
    @objc optional func carouselView(_ view:CarouselView, cellAtIndex index:NSInteger) -> UICollectionViewCell
    @objc optional func carouselView(_ view:CarouselView, didSelectItemAtIndex index:NSInteger)
}

public struct CarouselData {
    public init(image:UIImage? = nil, imageURL:URL? = nil, detail:String? = nil) {
        self.image = image
        self.imageURL = imageURL
        self.detail = detail
    }
    public var image: UIImage!
    public var imageURL: URL!
    public var detail: String!
}

public enum AutoScrollOption {
    case enable(Bool)
    case timeInterval(Foundation.TimeInterval)
}

public enum PageControlOption {
    case hidden(Bool)
    case indicatorTintColor(UIColor)
    case currentIndicatorTintColor(UIColor)
}

open class CarouselView: UIView {
    
    @IBOutlet open weak var delegate:CarouselViewDelegate?
    open var placeholderImage:UIImage?
    
    fileprivate var pageCount = 0
    fileprivate var timeInterval: TimeInterval = 3
    fileprivate var timer: Timer?
    fileprivate var enableAutoScroll = true
    fileprivate var isFirstLayout = true
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubView()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            timer?.invalidate()
        }
    }
    
    fileprivate func setupSubView() {
        addSubview(collectionView)
        addSubview(pageControl)
        startTimer()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = bounds.size
        collectionView.scrollToItem(at: IndexPath(row: pageControl.currentPage+1, section: 0), at: UICollectionViewScrollPosition(), animated: false)
        let size = pageControl.size(forNumberOfPages: pageControl.numberOfPages)
        pageControl.frame.size.height = size.height
        pageControl.frame.origin.y = self.bounds.height - size.height
    }
    
    fileprivate func startTimer() {
        if !enableAutoScroll { return }
        timer?.invalidate()
        timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(scrollNextPage), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func scrollNextPage() {
        let nextPageOffsetX = collectionView.contentOffset.x + collectionView.bounds.width
        collectionView.setContentOffset(CGPoint(x: nextPageOffsetX, y:0), animated: true)
    }
    
    //MARK: - like UICollectionView
    open func registerClass(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    open func dequeueReusableCellWithReuseIdentifier(_ identifier: String, forIndex index: Int) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(row: index, section: 0))
    }
    
    
    //MARK: getter
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout =  UICollectionViewFlowLayout()
        flowLayout.itemSize = self.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal        
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(CarouselCollectionViewCell))
        return collectionView
    }()
    
    fileprivate lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: self.bounds)
        pageControl.pageIndicatorTintColor = UIColor.red
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.numberOfPages = self.pageCount
        pageControl.isUserInteractionEnabled = false
        let size = pageControl.size(forNumberOfPages: pageControl.numberOfPages)
        pageControl.frame.size.height = size.height
        pageControl.frame.origin.y = self.bounds.height - size.height
        return pageControl
    }()
    
    //MARK: setter
    open var dataSource = [Any]() {
        didSet {
            pageCount = dataSource.count
            pageControl.numberOfPages = pageCount
        }
    }
    
    open var autoScrollOptions: [AutoScrollOption]? {
        didSet {
            timer?.invalidate()
            if let options = autoScrollOptions {
                options.forEach({ (option) in
                    switch option {
                    case let .enable(value):
                        enableAutoScroll = value
                        
                    case let .timeInterval(value):
                        timeInterval = value
                    }
                })
            }
            if enableAutoScroll {
                startTimer()
            }
        }
    }
    
    open var pageControlOptions: [PageControlOption]? {
        didSet {
            if let options = pageControlOptions {
                options.forEach({ (option) in
                    switch option {
                    case let .hidden(value):
                        pageControl.isHidden = value
                        
                    case let .indicatorTintColor(value):
                        pageControl.pageIndicatorTintColor = value
                        
                    case let .currentIndicatorTintColor(value):
                        pageControl.currentPageIndicatorTintColor = value
                    }
                })
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CarouselView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount > 1 ? pageCount+2 : pageCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = getIndexWithIndexPath(indexPath)
        if let cell = delegate?.carouselView?(self, cellAtIndex: index) {
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CarouselCollectionViewCell), for: indexPath) as! CarouselCollectionViewCell
        if let carouselData = dataSource[index] as? CarouselData {
            cell.carouselData = carouselData
        }
        return cell
    }
    
    fileprivate func getIndexWithIndexPath(_ indexPath:IndexPath) -> Int {
        var index = (indexPath as NSIndexPath).row
        if (indexPath as NSIndexPath).row < 1 {
            index = pageCount-1
            
        } else if (indexPath as NSIndexPath).row > pageCount {
            index = 0
            
        } else {
            index = (indexPath as NSIndexPath).row-1
        }
        return index
    }
}

// MARK: - UICollectionViewDelegate
extension CarouselView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.carouselView?(self, didSelectItemAtIndex: getIndexWithIndexPath(indexPath))
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculatePage()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        calculatePage()
    }
    
    /**
     计算页，循环
     */
    fileprivate func calculatePage() {
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
