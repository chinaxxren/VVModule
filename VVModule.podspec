
Pod::Spec.new do |spec|
  spec.name         = "VVModule"
  spec.version      = "0.0.1"
  spec.summary      = "VVModule是面向协议的iOS模块化框架，同时它还支持URL路由和模块间通信机制,并且启动阶段能够覆盖 main 之前"
  spec.homepage     = "https://github.com/chinaxxren/VVModule"
  spec.license      = "MIT"
  spec.author       = { "chinaxxren" => "182421693@qq.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "git@github.com:chinaxxren/VVModule.git", :tag => "#{spec.version}" }
  spec.source_files  = "VVModule/Source", "VVModule/Source/**/*.*"
  spec.frameworks  = "UIKit"
end
