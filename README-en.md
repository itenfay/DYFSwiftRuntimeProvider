English Vision | [中文版](README.md)

## DYFSwiftRuntimeProvider

`DYFSwiftRuntimeProvider` wraps the runtime, and provides some common usages([Objective-C Version](https://github.com/itenfay/DYFRuntimeProvider)).

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods Version](http://img.shields.io/cocoapods/v/DYFSwiftRuntimeProvider.svg?style=flat)](http://cocoapods.org/pods/DYFSwiftRuntimeProvider)&nbsp;
![CocoaPods Platform](http://img.shields.io/cocoapods/p/DYFSwiftRuntimeProvider.svg?style=flat)&nbsp;


## Group (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/itenfay/DYFSwiftRuntimeProvider/raw/master/images/g614799921.jpg" width="30%" />
</div>


## Installation

Using [CocoaPods](https://cocoapods.org):

``` 
pod 'DYFSwiftRuntimeProvider'
```

Or

```
pod 'DYFSwiftRuntimeProvider', '~> 2.1.1'

```


## Usage

Add `import DYFSwiftRuntimeProvider` to your source code.

### Gets all the method names of a class

**1. Gets all method names of an instance of a class**

```
let instMethods = DYFSwiftRuntimeProvider.getMethodList(withClass: UITableView.self)
print("========methods: \(instMethods)")
```

**2. Gets all class method names of a class**

```
let clsMethods = DYFSwiftRuntimeProvider.getClassMethodList(withClass: UIView.self)
print("========clsMethods: \(clsMethods)")
```

### Gets all variable names of a class

```
let ivars = DYFSwiftRuntimeProvider.getIvarList(withClass: UIButton.self)
print("========ivars: \(ivars)")
```

### Gets all the property names of a class

```
let properties = DYFSwiftRuntimeProvider.getPropertyList(withClass: UIButton.self)
print("========properties: \(properties)")
```

Take this class as an example. e.g.:

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

### Adds a method

```
override func viewDidLoad() {
    super.viewDidLoad()
    _ = DYFSwiftRuntimeProvider.addMethod(withClass: ViewController.self, selector: Selector("eat(foods:)"), impClass: People.self, impSelector: #selector(People.eat(foods:)))
    perform(NSSelectorFromString("eat(foods:)"), with: ["name": "meat", "number": 1])
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
    
    DYFSwiftRuntimeProvider.exchangeClassMethod(withClass: People.self, selector: #selector(People.decInfo2(age:name:)), anotherSelector: #selector(People.decInfo3(age:name:)))
    People.decInfo2(age: 50, name: "David")
    People.decInfo3(age: 26, name: "Liming")
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
    
    DYFSwiftRuntimeProvider.swizzleClassMethod(withClass: People.self, selector: #selector(People.decInfo2(age:name:)), swizzledSelector: #selector(People.decInfo3(age:name:)))
    People.decInfo2(age: 50, name: "David")
    People.decInfo3(age: 26, name: "Liming")
}
```

### Dynamic replace instance and class method

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


## Demo

`DYFSwiftRuntimeProvider` is learned how to use under this [Demo](https://github.com/itenfay/DYFSwiftRuntimeProvider/raw/master/Example).


## Feedback is welcome

If you notice any issue to create an issue. I will be happy to help you.
