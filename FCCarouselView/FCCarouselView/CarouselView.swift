//
//  CarouselView.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit

public protocol CarouselViewDelegate:class {
    func registerClass(cellClass: AnyClass?)
    func carouselView(view:CarouselView, cellForItemAtIndex index:NSInteger) -> UICollectionViewCell
}

public class CarouselView: UIView {
    
    public weak var delegate:CarouselViewDelegate?
    private var pageCount = 3
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blueColor()
        setupSubView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubView()
    }
    
    private func setupSubView() {
        addSubview(collectionView)
        addSubview(pageControl)
        collectionView.registerClass(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(CarouselCollectionViewCell))
        collectionView.contentOffset.x = collectionView.bounds.width
    }
    
    //MARK: getter
    private lazy var collectionView: UICollectionView = {
        let flowLayout =  UICollectionViewFlowLayout()
        flowLayout.itemSize = self.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        //        self.flowLayout = flowLayout
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.pagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
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
}

// MARK: - UICollectionViewDataSource
extension CarouselView: UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount+2
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = delegate?.carouselView(self, cellForItemAtIndex: indexPath.row) {
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(CarouselCollectionViewCell), forIndexPath: indexPath) as! CarouselCollectionViewCell
        if indexPath.row < 1 {
            cell.label.text = String(pageCount-1)
        } else if indexPath.row > pageCount {
            cell.label.text = "0"
        } else {
            cell.label.text = String(indexPath.row-1)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CarouselView: UICollectionViewDelegate {
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
