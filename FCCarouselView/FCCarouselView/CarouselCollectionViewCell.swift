//
//  CarouselCollectionViewCell.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupSubView() {
        contentView.addSubview(imageView)
        contentView.addSubview(detailMaskView)
        detailMaskView.addSubview(detailLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    //MARK: getter 懒加载    
    private lazy var detailLabel: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 3
        label.lineBreakMode = .ByTruncatingTail
        return label
    }()
    
    private lazy var detailMaskView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return maskView
    }()
    
    //MARK: setter
    var carouselData:CarouselData! {
        didSet {
            if let image = carouselData.image {
                imageView.image = image
            } else {
                //TODO: URL Image
            }
            if let detail = carouselData.detail {
                detailMaskView.hidden = false
                detailLabel.text = detail
                let maskViewHeight = detailLabel.sizeThatFits(bounds.size).height + 20
                detailMaskView.frame = CGRect(x: 0, y: bounds.height-maskViewHeight, width: bounds.width, height: maskViewHeight)
                let labelMargin:CGFloat = 12
                detailLabel.frame = CGRect(x: labelMargin, y: 0, width: detailMaskView.bounds.width-labelMargin*2, height: detailMaskView.bounds.height)
                
            } else {
                detailMaskView.hidden = true
            }
        }
    }
}
