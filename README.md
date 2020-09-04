# FindUnusedClasses 查找ios项目无用类工具


[![CI Status](https://img.shields.io/travis/sea777777/FindUnusedClasses.svg?style=flat)](https://travis-ci.org/sea777777/FindUnusedClasses)
[![Version](https://img.shields.io/cocoapods/v/FindUnusedClasses.svg?style=flat)](https://cocoapods.org/pods/FindUnusedClasses)
[![License](https://img.shields.io/cocoapods/l/FindUnusedClasses.svg?style=flat)](https://cocoapods.org/pods/FindUnusedClasses)
[![Platform](https://img.shields.io/cocoapods/p/FindUnusedClasses.svg?style=flat)](https://cocoapods.org/pods/FindUnusedClasses)

## Example

✅ 支持查找 Object-C 无用类
❎ 支持查找 Swift 无用类（待更新）
❎ 支持查找 C++ 无用类 （待更新）

注意：`Build Settings` 选择 `Other C Flags`  添加配置选项：`-fsanitize-coverage=func,trace-pc-guard`

在任意主线程，调用 `FindUnusedClasses allUnusedClasses` 即可， 参数是任意自定义类，只要不是系统类即可；


原理：利用编译器在每个方法调用处进行插桩，然后记录次函数指针，最后利用`dladdr`解析函数指针的具体信息，拿到类名称，也就是被执行的类。最后再拿到所有类对象列表，取差集即可，剩下的就是无用类，暂时只支持 objc，swift 后续会支持。



例 1：

```
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //耗时操作，尽量放在子线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [FindUnusedClasses allUnusedClasses:[self class]];
    });
}
```

```
输出如下：
YCUnused2,
YCUnused1,
YCUnused
```



例 2：

```
创建 YCUnused2 并执行 doSomething：

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[YCUnused2 new] doSomething];
    
    //耗时操作，尽量放在子线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [FindUnusedClasses allUnusedClasses:[self class]];
    });
}
```

```
输出如下：
YCUnused1,
YCUnused
```

最后对比 例1 和 例2 的打印结果：在 `[[YCUnused2 new] doSomething];` 之后执行 `[FindUnusedClasses allUnusedClasses:[self class]];` 就不会认为 `YCUnused2` 是无用类。

建议：在程序运行10-15分钟后再调用 `FindUnusedClasses allUnusedClasses ` 。

这样的好处是，等大部分类都被创建并且调用，剩余没被创建过的类，就认为是无用类：
比如我们等`YCUnused2` 被创建后再执行 `FindUnusedClasses allUnusedClasses` , 检测的无用类结果会更准确。



## Requirements

## Installation

FindUnusedClasses is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FindUnusedClasses' ,:git => 'https://github.com/sea777777/FindUnusedClasses.git'

```

## Author

sea777777, lyc1234560720@126.com

## License

FindUnusedClasses is available under the MIT license. See the LICENSE file for more info.

