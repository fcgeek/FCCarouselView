//
//  CarouselCollectionViewCell.swift
//  FCCarouselView
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        backgroundColor = UIColor.blueColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: getter
    lazy var label: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.text = "1"
        label.textColor = UIColor.whiteColor()
        return label
    }()
}
