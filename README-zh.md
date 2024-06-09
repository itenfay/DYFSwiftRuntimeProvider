[English Vision](README.md) | 中文版

## DYFSwiftRuntimeProvider

`DYFRuntimeProvider`包装了运行时，并提供了一些常见的用法([Objective-C Version](https://github.com/itenfay/DYFRuntimeProvider))。

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods Version](http://img.shields.io/cocoapods/v/DYFSwiftRuntimeProvider.svg?style=flat)](http://cocoapods.org/pods/DYFSwiftRuntimeProvider)&nbsp;
![CocoaPods Platform](http://img.shields.io/cocoapods/p/DYFSwiftRuntimeProvider.svg?style=flat)&nbsp;


## QQ群 (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/itenfay/DYFSwiftRuntimeProvider/raw/master/images/g614799921.jpg" width="30%" />
</div>


## 安装

使用 [CocoaPods](https://cocoapods.org):

``` 
pod 'DYFSwiftRuntimeProvider'
```

Or

```
pod 'DYFSwiftRuntimeProvider', '~> 2.1.0'

```


## 使用

将 `import DYFSwiftRuntimeProvider` 添加到源代码中。

### 获取一个类的所有方法名

**1. 获取一个类的实例的所有方法名**

```
let instMethods = DYFSwiftRuntimeProvider.getMethodList(withClass: UITableView.self)
print("========methods: \(instMethods)")
```

**2. 获取一个类的所有类方法名**

```
let clsMethods = DYFSwiftRuntimeProvider.getClassMethodList(withClass: UIView.self)
print("========clsMethods: \(clsMethods)")
```

### 获取一个类的所有变量名

```
let ivars = DYFSwiftRuntimeProvider.getIvarList(withClass: UIButton.self)
print("========ivars: \(ivars)")
```

### 获取一个类的所有属性名

```
let properties = DYFSwiftRuntimeProvider.getPropertyList(withClass: UIButton.self)
print("========properties: \(properties)")
```

以这个类为例，如下：
```
class People: NSObject {
    var name: String
    
    public override init() {
        self.name = ""
        super.init()
    }
    
    public init(name: String) {
        self.name = name
    }
    
    @objc dynamic func logName(age: Int) {
        print("========" + name + " is \(age) years old.")
    }
    
    @objc dynamic class func decInfo(age: Int, name: String) {
        print("========decInfo: " + "name: " + name + ", age = \(age)")
    }
    
    @objc dynamic class func decInfo2(age: Int, name: String) {
        print("========decInfo2: " + "name: " + name + ", age = \(age)")
    }
    
    @objc dynamic class func decInfo3(age: Int, name: String) {
        print("========decInfo3: " + "name: " + name + ", age = \(age)")
    }
    
    @objc func eat(foods: [String : Any]) {
        print("========eat foods: \(foods)")
    }
    
    @objc dynamic func run(step: Int) {
        print("========1: \(name) runs \(step) step.")
    }
    
    @objc dynamic func run2(step: Int) {
        print("========2: \(name) runs \(step) step.")
    }
}
```

### 添加一个方法

```
override func viewDidLoad() {
    super.viewDidLoad()
    _ = DYFSwiftRuntimeProvider.addMethod(withClass: ViewController.self, selector: Selector("eat(foods:)"), impClass: People.self, impSelector: #selector(People.eat(foods:)))
    perform(NSSelectorFromString("eat(foods:)"), with: ["name": "meat", "number": 1])
}
```

### 交换两个方法

```
override func viewDidLoad() {
    super.viewDidLoad()
    DYFSwiftRuntimeProvider.exchangeMethod(withClass: People.self, selector: #selector(People.run(step:)), anotherSelector: #selector(People.run2(step:)))
    let p = People(name: "Albert")
    p.run(step: 20)
    p.run2(step: 50)
    
    DYFSwiftRuntimeProvider.exchangeClassMethod(withClass: People.self, selector: #selector(People.decInfo2(age:name:)), anotherSelector: #selector(People.decInfo3(age:name:)))
    People.decInfo2(age: 50, name: "David")
    People.decInfo3(age: 26, name: "Liming")
}
```

### 替换一个方法

```
override func viewDidLoad() {
    super.viewDidLoad()
    DYFSwiftRuntimeProvider.replaceMethod(withClass: People.self, selector: #selector(People.run(step:)), targetSelector: #selector(People.run2(step:)))
    let p = People(name: "Albert")
    p.run2(step: 50)
}
```

### 交换两个方法（黑魔法）

```
override func viewDidLoad() {
    super.viewDidLoad()
    DYFSwiftRuntimeProvider.swizzleMethod(withClass: People.self, selector: #selector(People.run(step:)), swizzledSelector: #selector(People.run2(step:)))
    let p = People(name: "Albert")
    p.run(step: 20)
    p.run2(step: 50)
    
    DYFSwiftRuntimeProvider.swizzleClassMethod(withClass: People.self, selector: #selector(People.decInfo2(age:name:)), swizzledSelector: #selector(People.decInfo3(age:name:)))
    People.decInfo2(age: 50, name: "David")
    People.decInfo3(age: 26, name: "Liming")
}
```

### 动态替换实例和类方法

```
typealias IMPCType = @convention(c) (Any, Selector, Int) -> Void

private let newFunc: @convention(block) (Any, Int) -> Void = { (obj, age) in
    print("========obj: \(obj), age: \(age)")
    // Invoke the original method.
    let selector = #selector(People.logName(age:))
    ViewController.impBlock?(obj, selector, age)
}

typealias PEDecInfoIMPCType = @convention(c) (Any, Selector, Int, String) -> Void

private let peDecInfoFunc: @convention(block) (Any, Int, String) -> Void = { (obj, age, name) in
    print("====>obj: \(obj), age: \(age), name: \(name)")
}

override func viewDidLoad() {
    super.viewDidLoad()
    Self.impBlock = People.tf_replaceInstanceMethod(selector: #selector(People.logName(age:)), type: IMPCType.self, block: newFunc)
    _ = People.tf_replaceClassMethod(selector: #selector(People.decInfo(age:name:)), type: PEDecInfoIMPCType.self, block: peDecInfoFunc)
}
```

### 字典和模型的转换

以这个类为例，如下：

```
class Teacher: NSObject {
    @objc var name: String?
    @objc var age: Int = 0
    @objc var address: String?
}
```

**1. 字典转模型**

```
let teacher = DYFSwiftRuntimeProvider.asObject(with: ["name": "高粟", "age": 26, "address": "xx市xx"], for: Teacher.self)
if let teacher = teacher {
    print("========teacher: \(teacher), \(teacher.name), \(teacher.age), \(teacher.address)")
}
```

```
_ = DYFSwiftRuntimeProvider.asObject(withDictionary: ["name": "高粟", "age": 26, "address": "xx市xx"], forClass: Teacher.self)
_ = DYFSwiftRuntimeProvider.asObject(withDictionary: ["name": "高粟", "age": 26, "address": "xx市xx"], forObject: Teacher())
```

**2. 模型转字典**

```
let teacher = Teacher()
teacher.name = "李想"
teacher.age = 22
teacher.address = "xxx"
let dict = DYFSwiftRuntimeProvider.asDictionary(withObject: teacher)
print("========dict: \(dict)")
```

### 归档解档

**1. 归档**

```
open class Transaction: NSObject, NSCoding {
    public func encode(with aCoder: NSCoder) {
        DYFSwiftRuntimeProvider.encode(aCoder, forObject: self)
    }
}
```

**2. 解档**

```
open class Transaction: NSObject, NSCoding {
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        DYFSwiftRuntimeProvider.decode(aDecoder, forObject: self)
    }
}
```

### 添加一个分类属性

```
extension UIApplication {
    
    struct AssociatedObjcKeys {
        static var teacherKey = "TeacherKey"
    }
    
    var teacher: Teacher? {
        get {
            DYFSwiftRuntimeProvider.getAssociatedObject(self, key: &AssociatedObjcKeys.teacherKey) as? Teacher
        }
        set (objc) {
            DYFSwiftRuntimeProvider.setAssociatedObject(self, key: &AssociatedObjcKeys.teacherKey, value: objc, policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
```

### 获取和修改实例变量属性

```
// for ViewController.
if let view = DYFSwiftRuntimeProvider.getInstanceVar(withName: "_view", forObject: self) as? UIView {
    view.backgroundColor = UIColor.brown
}

// Declares the var in ViewController.
var fillColor: UIColor = .white

if let fillColor = DYFSwiftRuntimeProvider.getInstanceVar(withName: "fillColor", forObject: self) as? UIColor {
    print("fillColor: \(fillColor)")
    if fillColor == .white {
        print("fillColor is white color.")
    }
}

DYFSwiftRuntimeProvider.setInstanceVar(withName: "fillColor", value: UIColor.brown, forObject: self)
print("self.fillColor: \(fillColor)")
```


## 演示

`DYFSwiftRuntimeProvider` 在此 [演示](https://github.com/itenfay/DYFSwiftRuntimeProvider/raw/master/Example) 下学习如何使用。


## 欢迎反馈

如果你注意到任何问题被卡住，请创建一个问题。我乐意帮助你。
