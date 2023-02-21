## DYFSwiftRuntimeProvider

`DYFSwiftRuntimeProvider` wraps the runtime of Objective-C, and provides some common usages.

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods Version](http://img.shields.io/cocoapods/v/DYFSwiftRuntimeProvider.svg?style=flat)](http://cocoapods.org/pods/DYFSwiftRuntimeProvider)&nbsp;
![CocoaPods Platform](http://img.shields.io/cocoapods/p/DYFSwiftRuntimeProvider.svg?style=flat)&nbsp;

[Chinese Instructions (中文说明)](README-zh.md)


## Group (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/chenxing640/DYFSwiftRuntimeProvider/raw/master/images/g614799921.jpg" width="30%" />
</div>


## Installation

Using [CocoaPods](https://cocoapods.org):

```
use_frameworks!
target 'Your target name'

pod 'DYFSwiftRuntimeProvider'
Or
pod 'DYFSwiftRuntimeProvider', '~> 2.0.0'
```


## Usage

Add `import DYFSwiftRuntimeProvider` to your source code.

### Gets all the method names of a class

**1. Gets all method names of an instance of a class**

```
let instMethods = DYFSwiftRuntimeProvider.supplyMethodList(withClass: UITableView.self)
print("========methods: \(instMethods)")
```

**2. Gets all class method names of a class**

```
let clsMethods = DYFSwiftRuntimeProvider.supplyClassMethodList(withClass: UIView.self)
print("========clsMethods: \(clsMethods)")
```

### Gets all variable names of a class

```
let ivars = DYFSwiftRuntimeProvider.supplyIvarList(withClass: UIButton.self)
print("========ivars: \(ivars)")
```

### Gets all the property names of a class

```
let properties = DYFSwiftRuntimeProvider.supplyPropertyList(withClass: UIButton.self)
print("========properties: \(properties)")
```

Take this class as an example. e.g.:

```
class People: NSObject {
    var name: String
    
    override init() {
        self.name = ""
        super.init()
    }
    
    init(name: String) {
        self.name = name
    }
    
    @objc dynamic func logName(age: Int) {
        print("========" + name + " is \(age) years old.")
    }
    
    @objc dynamic class func decInfo(age: Int, name: String) {
        print("========\(type(of: self)) " + "age = \(age)" + ", name: " + name)
    }
    
    @objc func eat(foods: [String : Any]) {
        print("========eat foods: \(foods)")
    }
    
    @objc func run(step: Int) {
        print("========1: \(name) runs \(step) step.")
    }
    
    @objc func run2(step: Int) {
        print("========2: \(name) runs \(step) step.")
    }
}
```

### Adds a method

```
override func viewDidLoad() {
    super.viewDidLoad()
    _ = DYFSwiftRuntimeProvider.addMethod(withClass: ViewController.self, selector: Selector("eat(foods:)"), impClass: People.self, impSelector: #selector(People.eat(foods:)))
    perform(Selector("eat(foods:)"), with: ["name": "meat", "number": 1])
}
```

### Exchanges two methods

```
override func viewDidLoad() {
    super.viewDidLoad()
    DYFSwiftRuntimeProvider.exchangeMethod(withClass: People.self, selector: #selector(People.run(step:)), anotherSelector: #selector(People.run2(step:)))
    let p = People(name: "Albert")
    p.run(step: 20)
    p.run2(step: 50)
}
```

### Replaces a method

```
override func viewDidLoad() {
    super.viewDidLoad()
    DYFSwiftRuntimeProvider.replaceMethod(withClass: People.self, selector: #selector(People.run(step:)), targetSelector: #selector(People.run2(step:)))
    let p = People(name: "Albert")
    p.run2(step: 50)
}
```

### Swizzle two methods

```
override func viewDidLoad() {
    super.viewDidLoad()
    DYFSwiftRuntimeProvider.swizzleMethod(withClass: People.self, selector: #selector(People.run(step:)), swizzledSelector: #selector(People.run2(step:)))
    let p = People(name: "Albert")
    p.run(step: 20)
    p.run2(step: 50)
}
```

### Dynamic replace instance and class method

```
typealias IMPCType = @convention(c) (Any, Selector, Int) -> Void

private let newFunc: @convention(block) (Any, Int) -> Void = { (obj, j) in
    print("====>obj: \(obj), j: \(j)")
    // Invoke the original method.
    let selector = #selector(People.logName(age:))
    ViewController.impBlock?(obj, selector, j)
}

typealias PEDecInfoIMPCType = @convention(c) (Any, Selector, Int, String) -> Void

private let peDecInfoFunc: @convention(block) (Any, Int, String) -> Void = { (obj, age, name) in
    print("====>obj: \(obj), age: \(age), name: \(name)")
}

override func viewDidLoad() {
    super.viewDidLoad()
    Self.impBlock = People.dy_replaceInstanceMethod(selector: #selector(People.logName(age:)), type: IMPCType.self, block: newFunc)
    _ = People.dy_replaceClassMethod(selector: #selector(People.decInfo(age:name:)), type: PEDecInfoIMPCType.self, block: peDecInfoFunc)
}
```

### The transformation of dictionary and model

Take this class as an example. e.g.:

```
class Teacher: NSObject {
    @objc var name: String?
    @objc var age: Int = 0
    @objc var address: String?
}
```

**1. Converts the dictionary to model**

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

**2. Converts the model to dictionary**

```
let teacher = Teacher()
teacher.name = "李想"
teacher.age = 22
teacher.address = "xxx"
let dict = DYFSwiftRuntimeProvider.asDictionary(withObject: teacher)
print("========dict: \(dict)")
```

### Archives and unarchives

**1. Archives**

```
open class Transaction: NSObject, NSCoding {
    public func encode(with aCoder: NSCoder) {
        DYFSwiftRuntimeProvider.encode(aCoder, forObject: self)
    }
}
```

**2. Unarchives**

```
open class Transaction: NSObject, NSCoding {
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        DYFSwiftRuntimeProvider.decode(aDecoder, forObject: self)
    }
}
```

### Add a catogory property

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

### Get and modify instance variable property.

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


<!-- ## Demo

`DYFSwiftRuntimeProvider` is learned how to use under this [Demo](https://github.com/chenxing640/DYFStore).
-->


## Feedback is welcome

If you notice any issue, got stuck to create an issue. I will be happy to help you.
