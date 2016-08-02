//
//  ViewController.swift
//  FCCarouselViewDemo
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit
import FCCarouselView

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(carouselView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: getter
    private lazy var carouselView:CarouselView = {
        let carouselView = CarouselView(frame: CGRectMake(0,30, UIScreen.mainScreen().bounds.width, 100))
        
        return carouselView
    }()
    
}

