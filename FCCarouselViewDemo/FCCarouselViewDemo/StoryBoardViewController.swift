//
//  StoryBoardViewController.swift
//  FCCarouselViewDemo
//
//  Created by liujianlin on 16/8/5.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit
import FCCarouselView

class StoryBoardViewController: UIViewController, CarouselViewDelegate {
    
    @IBOutlet weak var sbCarouselView: CarouselView!
    
    deinit {
        print(#function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = false
        sbCarouselView.delegate = self
        sbCarouselView.dataSource.append(CarouselData(image: UIImage(named: "1")))
        sbCarouselView.dataSource.append(CarouselData(image: UIImage(named: "2")))
        sbCarouselView.dataSource.append(CarouselData(image: UIImage(named: "3")))
        sbCarouselView.dataSource.append(CarouselData(image: UIImage(named: "4")))
        sbCarouselView.autoScrollOptions = [.Enable(false)]
        sbCarouselView.pageControlOptions = [.IndicatorTintColor(UIColor.greenColor())
            , .CurrentIndicatorTintColor(UIColor.grayColor())]        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CarouselViewDelegate
    func carouselView(view: CarouselView, didSelectItemAtIndex index: NSInteger) {
        print(index)
    }
}
