//
//  ViewController.swift
//
//  Created by chenxing on 09/21/2022.
//  Copyright (c) 2022 chenxing. All rights reserved.
//

import UIKit
import ObjectiveC.runtime
import DYFSwiftRuntimeProvider

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
        print("======== [Swift] " + name + " is \(age) years old.")
    }
    
    @objc dynamic class func decInfo(age: Int, name: String) {
        print("======== [Swift] decInfo: " + "name: " + name + ", age = \(age)")
    }
    
    @objc dynamic class func decInfo2(age: Int, name: String) {
        print("======== [Swift] decInfo2: " + "name: " + name + ", age = \(age)")
    }
    
    @objc dynamic class func decInfo3(age: Int, name: String) {
        print("======== [Swift] decInfo3: " + "name: " + name + ", age = \(age)")
    }
    
    @objc func eat(foods: [String : Any]) {
        print("======== [Swift] eat foods: \(foods)")
    }
    
    @objc dynamic func run(step: Int) {
        print("======== [Swift] 1: \(name) runs \(step) step.")
    }
    
    @objc dynamic func run2(step: Int) {
        print("======== [Swift] 2: \(name) runs \(step) step.")
    }
}

class Teacher: NSObject {
    @objc var name: String?
    @objc var age: Int = 0
    @objc var address: String?
}

typealias IMPCType = @convention(c) (Any, Selector, Int) -> Void

private let newFunc: @convention(block) (Any, Int) -> Void = { (obj, age) in
    print("======== [Swift] obj: \(obj), age: \(age)")
    let selector = #selector(People.logName(age:))
    ViewController.impBlock?(obj, selector, age)
}

typealias PEDecInfoIMPCType = @convention(c) (Any, Selector, Int, String) -> Void

private let peDecInfoFunc: @convention(block) (Any, Int, String) -> Void = { (obj, age, name) in
    print("======== [Swift] obj: \(obj), age: \(age), name: \(name)")
}

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

extension ViewController {
    
    class func loadX() {
        DYFSwiftRuntimeProvider.replaceMethod(withClass: People.self, selector: #selector(People.run(step:)), targetSelector: #selector(People.run2(step:)))
        //DYFSwiftRuntimeProvider.exchangeMethod(withClass: People.self, selector: #selector(People.run(step:)), anotherSelector: #selector(People.run2(step:)))
        //DYFSwiftRuntimeProvider.swizzleMethod(withClass: People.self, selector: #selector(People.run(step:)), swizzledSelector: #selector(People.run2(step:)))
        //DYFSwiftRuntimeProvider.exchangeClassMethod(withClass: People.self, selector: #selector(People.decInfo2(age:name:)), anotherSelector: #selector(People.decInfo3(age:name:)))
        DYFSwiftRuntimeProvider.swizzleClassMethod(withClass: People.self, selector: #selector(People.decInfo2(age:name:)), swizzledSelector: #selector(People.decInfo3(age:name:)))
    }
    
}

class ViewController: UIViewController {
    
    static var impBlock: IMPCType?
    var fillColor: UIColor = .white
    
    var imageView: UIView = {
        return UIView()
    }()
    
    override func loadView() {
        super.loadView()
        Self.loadX()
    }
    
    @objc func sz_viewDidLoad() {
        print("======== [Swift] sz_viewDidLoad")
        //self.sz_viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Self.impBlock = People.dy_replaceInstanceMethod(selector: #selector(People.logName(age:)), type: IMPCType.self, block: newFunc)
        _ = People.dy_replaceClassMethod(selector: #selector(People.decInfo(age:name:)), type: PEDecInfoIMPCType.self, block: peDecInfoFunc)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let sample = RuntimeObjcSample()
        sample.test()
        
        swiftRt()
    }
    
    private func swiftRt() {
        let clsMethods = DYFSwiftRuntimeProvider.supplyClassMethodList(withClass: UIView.self)
        print("======== [Swift] clsMethods: \(clsMethods)")
        
        let instMethods = DYFSwiftRuntimeProvider.supplyMethodList(withClass: UITableView.self)
        print("======== [Swift] methods: \(instMethods)")
        
        let properties = DYFSwiftRuntimeProvider.supplyPropertyList(withClass: UIButton.self)
        print("======== [Swift] properties: \(properties)")
        
        let ivars = DYFSwiftRuntimeProvider.supplyIvarList(withClass: UIButton.self)
        print("======== [Swift] ivars: \(ivars)")
        
        let teacher = DYFSwiftRuntimeProvider.asObject(with: ["name": "高粟", "age": 26, "address": "长沙市xxxxxxxx"], for: Teacher.self)
        if let teacher = teacher {
            print("======== [Swift] teacher: \(teacher), \(teacher.name ?? ""), \(teacher.age), \(teacher.address ?? "")")
        }
        
        let dict = DYFSwiftRuntimeProvider.asDictionary(withObject: teacher)
        print("======== [Swift] dict: \(dict ?? [:])")
        
        let p = People(name: "Albert")
        p.logName(age: 50)
        
        People.decInfo(age: 10, name: "rob")
        People.decInfo2(age: 50, name: "David")
        People.decInfo3(age: 26, name: "Liming")
        
        _ = DYFSwiftRuntimeProvider.addMethod(withClass: ViewController.self, selector: Selector("eat(foods:)"), impClass: People.self, impSelector: #selector(People.eat(foods:)))
        perform(NSSelectorFromString("eat(foods:)"), with: ["name": "meat", "number": 1])
        
        if let fillColor = DYFSwiftRuntimeProvider.getInstanceVar(withName: "fillColor", forObject: self) as? UIColor {
            print("======== [Swift] fillColor: \(fillColor)")
            if fillColor == .white {
                print("======== [Swift] fillColor is white color.")
            }
        }
        DYFSwiftRuntimeProvider.setInstanceVar(withName: "fillColor", value: UIColor.brown, forObject: self)
        print("======== [Swift] self.fillColor: \(fillColor)")
        
        if let view = DYFSwiftRuntimeProvider.getInstanceVar(withName: "_view", forObject: self) as? UIView {
            view.backgroundColor = UIColor.brown
        }
        
        let p2 = People(name: "Albert")
        p2.run(step: 20)
        p2.run2(step: 50)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
