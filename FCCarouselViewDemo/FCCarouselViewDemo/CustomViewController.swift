//
//  CustomViewController.swift
//  FCCarouselViewDemo
//
//  Created by liujianlin on 16/8/5.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit
import FCCarouselView

class CustomViewController: UIViewController, CarouselViewDelegate {
    
    deinit {
        print(#function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(carouselView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CarouselViewDelegate
    func carouselView(view: CarouselView, didSelectItemAtIndex index: NSInteger) {
        print(index)
    }
    
    func carouselView(view: CarouselView, cellAtIndex index: NSInteger) -> UICollectionViewCell {
        let customCell = carouselView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(CustomCollectionViewCell), forIndex: index) as! CustomCollectionViewCell
        if let detail = carouselView.dataSource[index] as? String {
            customCell.detailLabel.text = detail
        }
        return customCell
    }
    
    //MARK: getter
    private lazy var carouselView:CarouselView = {
        let carouselView = CarouselView(frame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, 200))
        carouselView.registerClass(CustomCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(CustomCollectionViewCell))
        carouselView.delegate = self
        //1
        carouselView.dataSource = ["I created a swift class with string optionals (String?) and instantiated the class in a different swift file and got a compile error.",
                                   " appDelegate.swift, from the function app When I instantiate the class",
                                   "When I instantiate the class",
                                   "If the var item = ShoppingListItem() is done in the appDelegate.swift, from the function application:didFinishLaunchingWithOptions we get the error"]
        return carouselView
    }()
}
