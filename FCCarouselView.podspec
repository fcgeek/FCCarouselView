Pod::Spec.new do |s|
  s.name         = "FCCarouselView"
  s.version      = "1.0.2"
  s.summary      = "This library is implemented Swift cycle carousel"
  s.homepage     = "http://www.fcgeek.com"
  s.license      = "MIT"
  s.authors      = { 'liujianlin' => 'ljlin1520@gmail.com'}
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/fcgeek/FCCarouselView.git", :tag => s.version }
  s.source_files = 'FCCarouselView/FCCarouselView/*.swift', 'FCCarouselView/FCCarouselView.h'
  s.resources = ['FCCarouselView/FCCarouselView/*.png']

  s.requires_arc = true
end
