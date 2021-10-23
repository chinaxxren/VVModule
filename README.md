# VVModule

VVModule是面向协议的iOS模块化框架，同时它还支持URL路由和模块间通信机制，动态加载，优化load加载启动慢的问题。

## 安装

### cocoapods

```ruby
pod 'VVModule'
```

## 特点

* **优化加载**。VVModule组件能够自己决定自己启动阶段和优先级，去中心化，可插拔，称之为启动项的自注册，添加删除启动项都能更加方便。并且启动阶段能够覆盖 main 之前。

* **面向协议**。VVModule中模块和服务都是面向协议的。服务面向协议的好处在于对于接口维护比较友好，任何接口的变动在编译时都是可见的，但是大型项目有可能会面临大量需要维护的协议，这也是不可忽视的缺点。

* **动态化**。VVModule中模块和服务的注册都是在运行时完成的，可以根据具体需要调整模块的注册和启动时间，异步启动模块对于优化APP首屏加载时间会有帮助。

* **路由服务**。我们知道面向协议的服务虽然对于接口维护比较方便，但是模块间相互调用各自服务，通过路由服务则很好地平衡了模块间调用和依赖问题，顺便也解决了跨APP跳转的问题。

* **URL路由**。在路由基础上，只需要再增加简单的1到2行代码就可以实现通过AppScheme的URL路由机制。

* **多级模块有向通信**。一般来说，完全去耦合的模块间通信方案大概是两种：URL和通知```NSNotification```。URL解决了模块间服务相互调用的问题，但是如果想要通过URL实现一个观察者模式则会变得非常复杂。这时候大家可能会偏向于选择通知，但是由于通知是全局性的，这样会导致任何一条通知可能会被APP内任何一个模块所使用，久而久之这些通知会变得难以维护。<br>所谓**多级模块有向通信**，则是在```NSNotification```基础上对通知的传播方向进行了限制，底层模块对上层模块的通知称为**广播**```Broadcast```，上层模块对底层模块或者同层模块的通知称为**上报**```Report```。这样做有两个好处：一方面更利于通知的维护，另一方面可以帮助我们划分模块层级，如果我们发现有一个模块需要向多个同级模块进行```Report```那么这个模块很有可能应该被划分到更底层的模块。


## 感谢
1. HHRouter : https://github.com/lightory/HHRouter
1. fishhook : https://github.com/facebook/fishhook
1. TinyPart : https://github.com/RyanLeeLY/TinyPart
1. GHWAppLaunchManager : https://github.com/guohongwei719/GHWAppLaunchManager
