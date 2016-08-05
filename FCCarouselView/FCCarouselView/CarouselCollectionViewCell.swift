//
//  CarouselCollectionViewCell.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    
    var placeHolderImage:UIImage?
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    //MARK: getter
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleToFill
        return imageView
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 3
        label.lineBreakMode = .ByTruncatingTail
        return label
    }()
    
    private let detailMaskView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return maskView
    }()
    
    //MARK: setter
    var carouselData:CarouselData! {
        didSet {
            if let image = carouselData.image {
                imageView.image = image
            } else if let imageUrl = carouselData.imageURL {
                ImageManager.shareManager.downloadImageWithURL(imageUrl, placeholder: placeHolderImage, downloadDoneClosure: { [unowned self](image) in
                    self.imageView.image = image
                    })
            }
            if let detail = carouselData.detail {
                detailMaskView.hidden = false
                detailLabel.text = detail
                let labelMargin:CGFloat = 12
                let maskViewHeight = detailLabel.sizeThatFits(CGSize(width: bounds.size.width-labelMargin*2, height: bounds.size.height)).height + 20
                detailMaskView.frame = CGRect(x: 0, y: bounds.height-maskViewHeight, width: bounds.width, height: maskViewHeight)
                detailLabel.frame = CGRect(x: labelMargin, y: 0, width: detailMaskView.bounds.width-labelMargin*2, height: detailMaskView.bounds.height)
                
            } else {
                detailMaskView.hidden = true
            }
        }
    }
}
