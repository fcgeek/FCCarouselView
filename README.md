# FCCarouselView
![Build Status](https://travis-ci.org/fcgeek/FCCarouselView.svg)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage/)
![CocoaPods](https://img.shields.io/cocoapods/v/FCCarouselView.svg?style=flat)
![Language](https://img.shields.io/badge/language-Swift%203.1-orange.svg)
![Platform](https://img.shields.io/cocoapods/p/FCCarouselView.svg?style=flat)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/fcgeek/FCCarouselView/blob/master/LICENSE)  
Swift实现的循环轮播  
1.简单易用，支持`CocoaPods`、`Carthage`；  
2.自带缓存，缓存参考猫神的Kingfisher；  
3.支持GIF动图，无第三方依赖  
4.也可以自己注册Cell，更灵活的展示自定义View

先不哔哔，上图  

![demo](https://github.com/fcgeek/FCCarouselView/blob/master/pic/demo.gif)  
# Requirements
 - iOS 8+  
 - Swift 3.0.1  
 - Xcode 8.2.1 

# Installation  

### 1.CocoaPods  
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
pod 'FCCarouselView'
```  
### 2.Carthage  
```
github 'fcgeek/FCCarouselView'
```  

### 3.将代码拖到你的项目中  

# Usage  
```Swift
//step 1
import FCCarouselView

//step 2
//MARK: getter 懒加载
fileprivate lazy var carouselView:CarouselView = {
    let carouselView = CarouselView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 200))
    carouselView.delegate = self
    //1
    var carouselData = CarouselData()
    carouselData.image = UIImage(named: "1")
    carouselData.detail = "I created a swift class with string optionals (String?) and instantiated the class in a different swift file and got a compile error."
    carouselView.dataSource.append(carouselData)
    //2
    carouselData = CarouselData()
    carouselData.imageURL = URL(string: "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSMFynE3clrgzCU2ZDw9SDn5gM2JuwEsCE37Qf4S6uBlJljejEYWg")
    carouselData.detail = "When I instantiate the class"
    carouselView.dataSource.append(carouselData)
    //3
    carouselData = CarouselData()
    carouselData.image = UIImage(named: "3")
    carouselView.dataSource.append(carouselData)
    //4
    carouselData = CarouselData()
    carouselData.imageURL = URL(string: "https://g.twimg.com/blog/blog/image/Cat-party.gif")
    carouselData.detail = "If the var item = ShoppingListItem() is done in the appDelegate.swift, from the function application:didFinishLaunchingWithOptions we get the error"
    carouselView.dataSource.append(carouselData)
    //5
    carouselData = CarouselData()
    carouselData.imageURL = URL(string: "https://www.baidu.com/123")
    carouselData.detail = "<class> cannot be initialised because it has no accessible initializers"
    carouselView.dataSource.append(carouselData)
    return carouselView
}()

//step 3
override func viewDidLoad() {
    view.addSubview(carouselView)
}
```  
### AutoScrollOption
```Swift
public enum AutoScrollOption {
    case enable(Bool) //是否开启自动轮播，默认开启
    case timeInterval(Foundation.TimeInterval)  //轮播频率
}

//such as
sbCarouselView.autoScrollOptions = [.enable(false)]
```  
### PageControlOption
```Swift
public enum PageControlOption {
    case hidden(Bool)
    case indicatorTintColor(UIColor)
    case currentIndicatorTintColor(UIColor)
}
//such as
sbCarouselView.pageControlOptions = [.indicatorTintColor(UIColor.greenColor())
            , .currentIndicatorTintColor(UIColor.grayColor())]        
```  
### CarouselViewDelegate
```Swift
@objc public protocol CarouselViewDelegate: class {
    //自定义Cell时才使用到
    @objc optional func carouselView(_ view:CarouselView, cellAtIndexPath indexPath:IndexPath, pageIndex: Int) -> UICollectionViewCell
    //点击事件
    @objc optional func carouselView(_ view:CarouselView, didSelectItemAtIndex index:NSInteger)
}
```  
### Custom Cell Like UICollectionDelegate
```Swift
//step 1 registerClass
carouselView.registerClass(CustomCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(CustomCollectionViewCell.self))

//step 2 
func carouselView(_ view: CarouselView, cellAtIndexPath indexPath: IndexPath, pageIndex: Int) -> UICollectionViewCell {
    let customCell = carouselView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(CustomCollectionViewCell.self), forIndex: pageIndex) as! CustomCollectionViewCell
    if let detail = carouselView.dataSource[pageIndex] as? String {
        customCell.detailLabel.text = detail
    }
    return customCell
}
```  

更多内容请查看Demo

# Contact
有任何问题可以提issues或联系我  
Weibo : [@飛呈jerry](http://weibo.com/2871687492)  
Blog: https://www.fcgeek.com  

# License  

`FCCarouselView` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.

