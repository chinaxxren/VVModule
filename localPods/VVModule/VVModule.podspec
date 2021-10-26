
Pod::Spec.new do |spec|
  spec.name         = "VVModule"
  spec.version      = "0.0.8"
  spec.summary      = "VVModule是面向协议的iOS模块化框架，同时它还支持URL路由和模块间通信机制,并且覆盖启动阶段的main函数的前后"
  spec.homepage     = "https://github.com/chinaxxren/VVModule"
  spec.license      = "MIT"
  spec.author       = { "chinaxxren" => "jiangmingz@qq.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "git@github.com:chinaxxren/VVModule.git", :tag => "#{spec.version}" }
  spec.source_files = 'VVModule/Classes/**/*'
  spec.public_header_files = 'VVModule/Classes/**/*.h'
  spec.frameworks  = "UIKit"
end
