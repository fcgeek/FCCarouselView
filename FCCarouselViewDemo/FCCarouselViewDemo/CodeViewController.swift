//
//  CodeViewController.swift
//  FCCarouselViewDemo
//
//  Created by liujianlin on 16/8/5.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit
import FCCarouselView

class CodeViewController: UIViewController, CarouselViewDelegate {
    
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
    
    //MARK: getter
    private lazy var carouselView:CarouselView = {
        let carouselView = CarouselView(frame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, 200))
        carouselView.delegate = self
        //1
        var carouselData = CarouselData()
        carouselData.image = UIImage(named: "1")
        carouselData.detail = "I created a swift class with string optionals (String?) and instantiated the class in a different swift file and got a compile error."
        carouselView.dataSource.append(carouselData)
        //2
        carouselData = CarouselData()
        carouselData.imageURL = NSURL(string: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSMFynE3clrgzCU2ZDw9SDn5gM2JuwEsCE37Qf4S6uBlJljejEYWg")
        carouselData.detail = "When I instantiate the class"
        carouselView.dataSource.append(carouselData)
        //3
        carouselData = CarouselData()
        carouselData.image = UIImage(named: "3")
        carouselView.dataSource.append(carouselData)
        //4
        carouselData = CarouselData()
        carouselData.imageURL = NSURL(string: "https://g.twimg.com/blog/blog/image/Cat-party.gif")
        carouselData.detail = "If the var item = ShoppingListItem() is done in the appDelegate.swift, from the function application:didFinishLaunchingWithOptions we get the error"
        carouselView.dataSource.append(carouselData)
        //5
        carouselData = CarouselData()
        carouselData.imageURL = NSURL(string: "https://www.baidu.com/123")
        carouselData.detail = "<class> cannot be initialised because it has no accessible initializers"
        carouselView.dataSource.append(carouselData)
        return carouselView
    }()
    
}
