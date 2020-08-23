## DYFSwiftRuntimeProvider

`DYFSwiftRuntimeProvider` wraps the runtime, and can quickly use for the transformation of the dictionary and model, archiving and unarchiving, adding a method, exchanging two methods, replacing a method, and getting all the variable names, property names and method names of a class.

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods Version](http://img.shields.io/cocoapods/v/DYFSwiftRuntimeProvider.svg?style=flat)](http://cocoapods.org/pods/DYFSwiftRuntimeProvider)&nbsp;
![CocoaPods Platform](http://img.shields.io/cocoapods/p/DYFSwiftRuntimeProvider.svg?style=flat)&nbsp;

[Chinese Instructions (中文说明)](README-zh.md)


## Group (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/dgynfi/DYFSwiftRuntimeProvider/raw/master/images/g614799921.jpg" width="30%" />
</div>


## Installation

Using [CocoaPods](https://cocoapods.org):

```
use_frameworks!
target 'Your target name'

pod 'DYFSwiftRuntimeProvider', '~> 1.0.2'
```


## Usage

Add `import DYFSwiftRuntimeProvider` to your source code.

### Gets all the method names of a class

**1. Gets all method names of an instance**

```
let methodNames = DYFSwiftRuntimeProvider.methodList(withClass: UITableView.self)
for name in methodNames {
    print("The method name: \(name)")
}
```

**2. Gets all method names of a class**

```
let clsMethodNames = DYFSwiftRuntimeProvider.classMethodList(self)
for name in clsMethodNames {
    print("The class method name: \(name)")
}
```

### Gets all variable names of a class

```
let ivarNames = DYFSwiftRuntimeProvider.ivarList(withClass: UILabel.self)
for name in ivarNames {
    print("The var name: \(name)")
}
```

### Gets all the property names of a class

```
let propertyNames = DYFSwiftRuntimeProvider.propertyList(withClass: UILabel.self)
for name in propertyNames {
    print("The property name: \(name)")
}
```

### Adds a method

```
override func loadView() {
    super.loadView()
    
    let ret = DYFSwiftRuntimeProvider.addMethod(withClass: XXViewController.self, selector: NSSelectorFromString("verifyCode"), impClass: XXViewController.self, impSelector: #selector(XXViewController.verifyQRCode))
    
    print("The result of adding method is \(ret)")
}

@objc func verifyQRCode() {
    print("Verifies QRCode")
}

override func viewDidLoad() {
    super.viewDidLoad()
    self.perform(NSSelectorFromString("verifyCode"))
}
```

### Exchanges two methods

```
override func viewDidLoad() {
    super.viewDidLoad()
    
    DYFSwiftRuntimeProvider.exchangeMethod(withClass: XXViewController.self, selector: #selector(XXViewController.verifyCode1), targetClass: XXViewController.self, targetSelector: #selector(XXViewController.verifyQRCode))
    
    verifyCode1()
    verifyQRCode()
}

@objc func verifyCode1() {
    print("Verifies Code1")
}

@objc func verifyQRCode() {
    print("Verifies QRCode")
}
```

### Replaces a method

```
override func viewDidLoad() {
    super.viewDidLoad()
    
    DYFSwiftRuntimeProvider.replaceMethod(withClass: XXViewController.self, selector: #selector(XXViewController.verifyCode2), targetClass: XXViewController.self, targetSelector: #selector(XXViewController.verifyQRCode))
    
    verifyCode2()
    verifyQRCode()
}

@objc func verifyCode2() {
    print("Verifies Code2")
}

@objc func verifyQRCode() {
    print("Verifies QRCode")
}
```

### The transformation of dictionary and model

**1. Converts the dictionary to model**

```
// e.g.: DYFStoreTransaction: NSObject
let transaction = DYFSwiftRuntimeProvider.model(withDictionary: itemDict, forClass: DYFStoreTransaction.self)
```

**2. Converts the model to dictionary**

```
let transaction = DYFStoreTransaction()
let dict = DYFSwiftRuntimeProvider.dictionary(withModel: transaction)
```
    
### Archives and unarchives

**1. Archives**

```
// e.g.: DYFStoreTransaction: NSObject, NSCoding
open class DYFStoreTransaction: NSObject, NSCoding {

    public func encode(with aCoder: NSCoder) {
        DYFSwiftRuntimeProvider.encode(aCoder, forObject: self)
    }
    
}
```

**2. Unarchives**

```
// e.g.: DYFStoreTransaction: NSObject, NSCoding 
open class DYFStoreTransaction: NSObject, NSCoding {

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        DYFSwiftRuntimeProvider.decode(aDecoder, forObject: self)
    }
    
}
```


## Demo

`DYFSwiftRuntimeProvider` is learned how to use under this [Demo](https://github.com/dgynfi/DYFStore)


## Feedback is welcome

If you notice any issue, got stuck or just want to chat feel free to create an issue. I will be happy to help you.
