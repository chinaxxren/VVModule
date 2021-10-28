
Pod::Spec.new do |spec|
  spec.name         = "VVModule"
  spec.version      = "0.1.0"
  spec.summary      = "VVModule是面向协议的iOS模块化框架，同时它还支持URL路由和模块间通信机制,并且覆盖启动阶段的main函数的前后"
  spec.homepage     = "https://github.com/chinaxxren/VVModule"
  spec.license      = "MIT"
  spec.author       = { "chinaxxren" => "jiangmingz@qq.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "git@github.com:chinaxxren/VVModule.git", :tag => "#{spec.version}" }
  spec.source_files = 'Source/Classes/**/*'
  spec.public_header_files = 'Source/Classes/**/*.h'
  spec.frameworks  = "UIKit"
  
  spec.subspec 'Module' do |ss|
    ss.source_files = 'Source/Module/**/*.{h,m}'
    ss.public_header_files = 'Source/Modul/**/*.h'
  end
  
  spec.subspec 'EventBus' do |ss|
    ss.source_files = 'Source/EventBus/**/*.{h,m}'
    ss.public_header_files = 'Source/EventBus/**/*.h'
  end
end
