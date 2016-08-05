//
//  ViewController.swift
//  FCCarouselViewDemo
//
//  Created by liujianlin on 16/8/2.
//  Copyright © 2016年 fcgeek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func codeBtnAction(sender: AnyObject) {
        navigationController?.pushViewController(CodeViewController(), animated: true)
    }
    
    @IBAction func customBtnAction(sender: AnyObject) {
        navigationController?.pushViewController(CustomViewController(), animated: true)
    }
    
}

