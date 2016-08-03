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
        let carouselView = CarouselView(frame: CGRectMake(0,30, UIScreen.mainScreen().bounds.width, 200))
        var carouselData1 = CarouselData()
        carouselData1.image = UIImage(named: "1")
        carouselData1.detail = "I created a swift class with string optionals (String?) and instantiated the class in a different swift file and got a compile error."
        carouselView.carouselDatas.append(carouselData1)
        carouselData1 = CarouselData()
        carouselData1.image = UIImage(named: "2")
        carouselData1.detail = "When I instantiate the class"
        carouselView.carouselDatas.append(carouselData1)
        carouselData1 = CarouselData()
        carouselData1.image = UIImage(named: "3")
        carouselView.carouselDatas.append(carouselData1)
        carouselData1 = CarouselData()
        carouselData1.image = UIImage(named: "4")
        carouselData1.detail = "If the var item = ShoppingListItem() is done in the appDelegate.swift, from the function application:didFinishLaunchingWithOptions we get the error"
        carouselView.carouselDatas.append(carouselData1)
        carouselData1 = CarouselData()
        carouselData1.image = UIImage(named: "5")
        carouselData1.detail = "<class> cannot be initialised because it has no accessible initializers"
        carouselView.carouselDatas.append(carouselData1)
        return carouselView
    }()
    
}

