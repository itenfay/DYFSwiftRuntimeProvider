//
//  DYFSwiftRuntimeProvider.swift
//
//  Created by chenxing on 2016/11/28. ( https://github.com/chenxing640/DYFSwiftRuntimeProvider )
//  Copyright © 2016 chenxing. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import ObjectiveC

/// The class for runtime wrapper that provides some common usages.
final public class DYFSwiftRuntimeProvider: NSObject {
    
    /// Instantiates an `DYFSwiftRuntimeProvider` object.
    public override init() {
        super.init()
    }
    
    /// Transform a string to a pointer for accessing and manipulating data of a specific type.
    /// - Parameter string: A string object.
    /// - Returns: A pointer for accessing and manipulating data of a specific type.
    public class func asUnsafeMutablePointer(_ string: String) -> UnsafeMutablePointer<CChar>? {
        guard let cStr = string.cString(using: .utf8) else {
            return nil
        }
        let length = cStr.count
        // When you allocate memory, always remember to deallocate once you’re finished.
        // ump.deallocate()
        let ump = UnsafeMutablePointer<CChar>.allocate(capacity: length)
        for i in 0..<length { ump[i] = cStr[i] }
        return ump
    }
    
    /// Transform a pointer for accessing and manipulating data to a pointer for accessing data of a specific type.
    /// - Parameter ump: A pointer for accessing and manipulating data of a specific type.
    /// - Returns: A pointer for accessing data of a specific type.
    public class func asUnsafePointer(_ ump: UnsafeMutablePointer<CChar>?) -> UnsafePointer<CChar>? {
        guard let _ump = ump else {
            return nil
        }
        return UnsafePointer(_ump)
    }
    
    /// Describes the instance methods implemented by a class.
    /// - Parameter cls: The class you want to inspect.
    /// - Returns: String array of the instance methods.
    @objc public class func supplyMethodList(withClass cls: AnyClass?) -> [String] {
        var selNames: [String] = []
        var count: UInt32 = 0
        let methodList = class_copyMethodList(cls, &count)
        for index in 0..<Int(count) {
            let sel = method_getName(methodList![index])
            let selName = String(cString: sel_getName(sel))
            selNames.append(selName)
        }
        free(methodList)
        return selNames
    }
    
    /// To get the class methods of a class.
    /// - Parameter cls: The class you want to inspect.
    /// - Returns: String array of the class methods.
    @objc public class func supplyClassMethodList(withClass cls: AnyClass?) -> [String] {
        return Self.supplyMethodList(withClass: object_getClass(cls))
    }
    
    /// Describes the instance variables declared by a class.
    /// - Parameter cls: The class you want to inspect.
    /// - Returns: String array of the instance variables.
    @objc public class func supplyIvarList(withClass cls: AnyClass?) -> [String] {
        var ivarNames: [String] = []
        var count: UInt32 = 0
        let ivarList = class_copyIvarList(cls, &count)
        for index in 0..<Int(count) {
            let ivar = ivarList![index]
            if let ivarName = ivar_getName(ivar) {
                let s = String(cString: ivarName)
                ivarNames.append(s)
            }
        }
        free(ivarList)
        return ivarNames
    }
    
    /// Describes the properties declared by a class.
    /// - Parameter cls: The class you want to inspect.
    /// - Returns: String array of the properties.
    @objc public class func supplyPropertyList(withClass cls: AnyClass?) -> [String] {
        var propertyNames: [String] = []
        var count: UInt32 = 0
        let pList = class_copyPropertyList(cls, &count)
        for index in 0..<Int(count) {
            let p: objc_property_t = pList![index]
            let pName = String(cString: property_getName(p))
            propertyNames.append(pName)
        }
        free(pList)
        return propertyNames
    }
    
    /// Reads the value of an instance variable in an object.
    /// - Parameters:
    ///   - name: The name of an instance variable.
    ///   - obj: The object containing the instance variable whose value you want to read.
    /// - Returns: The value of the instance variable specified by ivar, or nil if object is nil.
    @objc public class func getInstanceVar(withName name: String, forObject obj: Any?) -> Any? {
        //let _name = (name as NSString).utf8String
        let ump = self.asUnsafeMutablePointer(name)
        guard let _name = self.asUnsafePointer(ump),
              let ivar = class_getInstanceVariable(object_getClass(obj), _name)
        else {
            ump?.deallocate()
            return nil
        }
        ump?.deallocate()
        return object_getIvar(obj, ivar)
    }
    
    /// Sets the value of an instance variable in an object.
    /// - Parameters:
    ///   - name: The name of an instance variable.
    ///   - value: The new value for the instance variable.
    ///   - obj: The object containing the instance variable whose value you want to set.
    @objc public class func setInstanceVar(withName name: String, value: Any?, forObject obj: Any?) {
        //let _name = (name as NSString).utf8String
        let ump = self.asUnsafeMutablePointer(name)
        guard let _name = self.asUnsafePointer(ump),
              let ivar = class_getInstanceVariable(object_getClass(obj), _name)
        else {
            ump?.deallocate()
            return
        }
        ump?.deallocate()
        object_setIvar(obj, ivar, value)
    }
    
    /// Returns a string describing a method's parameter and return types.
    /// - Parameter method: The method to inspect.
    /// - Returns: A C string. The string may be NULL.
    @objc public class func supplyMethodTypes(_ method: Method) -> UnsafePointer<CChar>? {
        return method_getTypeEncoding(method)
    }
    
    /// Adds a new method to a class with a given selector and implementation.
    /// - Parameters:
    ///   - cls: The class to which to add a method.
    ///   - sel: A selector that specifies the name of the method being added.
    ///   - impSel: A function which is the implementation of the new method.
    /// - Returns: true if the method was added successfully, otherwise false.
    @discardableResult
    @objc public class func addMethod(withClass cls: AnyClass?, selector sel: Selector, impSelector impSel: Selector) -> Bool {
        return self.addMethod(withClass: cls, selector: sel, impClass: cls, impSelector: impSel)
    }
    
    /// Adds a new method to a class with a given selector and implementation.
    /// - Parameters:
    ///   - cls: The class to which to add a method.
    ///   - sel: A selector that specifies the name of the method being added.
    ///   - impCls: A class which is the implementation of the new method.
    ///   - impSel: A function which is the implementation of the new method.
    /// - Returns: true if the method was added successfully, otherwise false.
    @discardableResult
    @objc public class func addMethod(withClass cls: AnyClass?, selector sel: Selector, impClass impCls: AnyClass?, impSelector impSel: Selector) -> Bool {
        guard let _impCls = impCls,
              let imp = class_getMethodImplementation(_impCls, impSel)
        else {
            return false
        }
        guard let method = class_getInstanceMethod(_impCls, impSel) else {
            return false
        }
        let types = self.supplyMethodTypes(method)
        return class_addMethod(cls, sel, imp, types)
    }
    
    /// Adds a new method to a class with a given selector and implementation.
    /// - Parameters:
    ///   - cls: The class to which to add a method.
    ///   - sel: A selector that specifies the name of the method being added.
    ///   - impCls: A class which is the implementation of the new method.
    ///   - impSel: A function which is the implementation of the new method.
    ///   - types: A string describing a method's parameter and return types. see [Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1)
    /// - Returns: true if the method was added successfully, otherwise false.
    @discardableResult
    @objc public class func addMethod(withClass cls: AnyClass?, selector sel: Selector, impClass impCls: AnyClass?, impSelector impSel: Selector, types: UnsafePointer<CChar>?) -> Bool {
        guard let _impCls = impCls,
              let imp = class_getMethodImplementation(_impCls, impSel)
        else {
            return false
        }
        return class_addMethod(cls, sel, imp, types)
    }
    
    /// Exchanges the implementations of two methods.
    /// - Parameters:
    ///   - cls: The class you want to modify.
    ///   - sel: A selector that identifies the method whose implementation you want to exchange.
    ///   - aSel: The selector of the method you want to specify.
    /// - Returns: true if the method was exchanged successfully, otherwise false.
    @discardableResult
    @objc public class func exchangeMethod(withClass cls: AnyClass?, selector sel: Selector, anotherSelector aSel: Selector) -> Bool {
        return self.exchangeMethod(withClass: cls, selector: sel, anotherClass: cls, anotherSelector: aSel)
    }
    
    /// Exchanges the implementations of two methods.
    /// - Parameters:
    ///   - cls: The class you want to modify.
    ///   - sel: A selector that identifies the method whose implementation you want to exchange.
    ///   - aCls: The class you want to specify.
    ///   - aSel: The selector of the method you want to specify.
    /// - Returns: true if the method was exchanged successfully, otherwise false.
    @discardableResult
    @objc public class func exchangeMethod(withClass cls: AnyClass?, selector sel: Selector, anotherClass aCls: AnyClass?, anotherSelector aSel: Selector) -> Bool {
        guard let m1 = class_getInstanceMethod(cls, sel),
              let m2 = class_getInstanceMethod(aCls, aSel)
        else {
            return false
        }
        //let imp1: IMP = method_getImplementation(m1)
        //let imp2: IMP = method_getImplementation(m2)
        //method_setImplementation(m1, imp2)
        //method_setImplementation(m2, imp1)
        method_exchangeImplementations(m1, m2)
        return true
    }
    
    /// Replaces the implementation of a method for a given class.
    /// - Parameters:
    ///   - cls: The class you want to modify.
    ///   - sel: A selector that identifies the method whose implementation you want to replace.
    ///   - targetSel: The selector of the method you want to specify.
    /// - Returns: true if the method was replaced successfully, otherwise false.
    @discardableResult
    @objc public class func replaceMethod(withClass cls: AnyClass?, selector sel: Selector, targetSelector targetSel: Selector) -> Bool {
        return self.replaceMethod(withClass: cls, selector: sel, targetClass: cls, targetSelector: targetSel)
    }
    
    /// Replaces the implementation of a method for two given classes.
    /// - Parameters:
    ///   - cls: The class you want to modify.
    ///   - sel: A selector that identifies the method whose implementation you want to replace.
    ///   - targetCls: The class you want to specify.
    ///   - targetSel: The selector of the method you want to specify.
    /// - Returns: true if the method was replaced successfully, otherwise false.
    @discardableResult
    @objc public class func replaceMethod(withClass cls: AnyClass?, selector sel: Selector, targetClass targetCls: AnyClass?, targetSelector targetSel: Selector) -> Bool {
        guard let _targetCls = targetCls,
              let imp = class_getMethodImplementation(_targetCls, targetSel)
        else {
            return false
        }
        guard let method = class_getInstanceMethod(_targetCls, targetSel) else {
            return false
        }
        let types = self.supplyMethodTypes(method)
        class_replaceMethod(cls, sel, imp, types)
        return true
    }
    
    /// Swizzles the implementation of a method for a given class.
    /// - Parameters:
    ///   - cls: The class you want to specify.
    ///   - selector: The selector of the method you want to specify.
    ///   - swizzledSelector: A selector that identifies the method whose implementation you want to swizzle.
    /// - Returns: true if the method was swizzled successfully, otherwise false.
    @discardableResult
    @objc public class func swizzleMethod(withClass cls: AnyClass?, selector: Selector, swizzledSelector: Selector) -> Bool {
        return self.swizzleMethod(withClass: cls, selector: selector, swizzledClass: cls, swizzledSelector: swizzledSelector)
    }
    
    /// Swizzles the implementation of a method for two given classes.
    /// - Parameters:
    ///   - cls: The class you want to specify.
    ///   - selector: The selector of the method you want to specify.
    ///   - swizzledClass: The class you want to swizzle.
    ///   - swizzledSelector: A selector that identifies the method whose implementation you want to swizzle.
    /// - Returns: true if the method was swizzled successfully, otherwise false.
    @discardableResult
    @objc public class func swizzleMethod(withClass cls: AnyClass?, selector: Selector, swizzledClass: AnyClass?, swizzledSelector: Selector) -> Bool {
        guard let originalMethod = class_getInstanceMethod(cls, selector),
              let swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector)
        else {
            return false
        }
        let isAdded = class_addMethod(swizzledClass, swizzledSelector,
                                      method_getImplementation(swizzledMethod),
                                      method_getTypeEncoding(swizzledMethod))
        if isAdded {
            class_replaceMethod(swizzledClass, swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        return true
    }
    
    /// Gets the swift namespace from the bundle’s Info.plist file.
    ///
    /// - Returns: A string object.
    public class func supplyNamespace() -> String? {
        // The name of the executable in this bundle (if any).
        let executableKey = kCFBundleExecutableKey as String
        //A dictionary, constructed from the bundle’s Info.plist file.
        let infoDict = Bundle.main.infoDictionary ?? [String : Any]()
        
        // Fetches the value for a key.
        guard let namespace = infoDict[executableKey] as? String else {
            return nil
        }
        
        return namespace
    }
    
    //*************************************************************
    //let className = String(cString: class_getName(cls))
    //if className.isEmpty { return nil }
    
    // Gets the swift namespace.
    //guard let namespace = supplyNamespace() else { return nil }
    
    //let clsName = "\(namespace).\(className)"
    //print("clsName: \(clsName)")
    
    //let aCls: AnyClass? = NSClassFromString(clsName)
    //guard let _class = aCls as? NSObject.Type else {
    //    return nil
    //}
    //let obj = _class.init()
    //*************************************************************
    /// Converts a dictionary whose elements are key-value pairs to a corresponding object.
    /// - Parameters:
    ///   - dictionary: A collection whose elements are key-value pairs.
    ///   - cls: A class that inherits the NSObject class.
    /// - Returns: A corresponding object.
    public class func asObject<T>(with dictionary: [String : Any]?, for cls: T.Type?) -> T? where T : NSObject {
        guard let dict = dictionary, let _class = cls else {
            return nil
        }
        let pList = self.supplyPropertyList(withClass: cls)
        let obj = _class.init()
        
        //obj.setValuesForKeys(dict)
        for (k, v) in dict {
            if pList.contains(k) {
                obj.setValue(v, forKey: k)
            }
        }
        
        return obj
    }
    
    /// Converts a dictionary whose elements are key-value pairs to a corresponding object.
    /// - Parameters:
    ///   - dictionary: A collection whose elements are key-value pairs.
    ///   - cls: A class that inherits the NSObject class.
    /// - Returns: A corresponding object.
    @objc public class func asObject(withDictionary dictionary: [String : Any]?, forClass cls: NSObject.Type?) -> AnyObject? {
        guard let dict = dictionary, let _class = cls else {
            return nil
        }
        let obj = _class.init()
        let pList = self.supplyPropertyList(withClass: _class)
        
        for (k, v) in dict {
            if pList.contains(k) {
                obj.setValue(v, forKey: k)
            }
        }
        
        return obj
    }
    
    /// Converts a dictionary whose elements are key-value pairs to a corresponding object.
    /// - Parameters:
    ///   - dictionary: A collection whose elements are key-value pairs.
    ///   - model: An object that inherits the NSObject class.
    /// - Returns: A corresponding object.
    @objc public class func asObject(withDictionary dictionary: [String : Any]?, forObject object: NSObject?) -> AnyObject? {
        guard let dict = dictionary, let obj = object else {
            return object
        }
        let cls: AnyClass? = object_getClass(obj)
        let pList = self.supplyPropertyList(withClass: cls)
        
        for (k, v) in dict {
            if pList.contains(k) {
                obj.setValue(v, forKey: k)
            }
        }
        
        return obj
    }
    
    /// Converts a object to a corresponding dictionary whose elements are key-value pairs.
    /// - Parameter model: A NSObject object.
    /// - Returns: A corresponding dictionary.
    @objc public class func asDictionary(withObject object: NSObject?) -> [String : Any]? {
        guard let obj = object, let cls = object_getClass(obj) else {
            return nil
        }
        let pList = self.supplyPropertyList(withClass: cls)
        if pList.isEmpty { return nil }
        
        var dict: [String : Any] = [:]
        for key in pList {
            if let value = obj.value(forKey: key) {
                dict[key] = value
            } else {
                dict[key] = NSNull()
            }
        }
        
        return dict
    }
    
    /// Encodes an object using a given archiver.
    /// - Parameters:
    ///   - encoder: An archiver object.
    ///   - object: An object you want to encode.
    @objc public class func encode(_ encoder: NSCoder, forObject object: NSObject) {
        let ivarNames = self.supplyPropertyList(withClass: object.classForCoder)
        for key in ivarNames {
            let value = object.value(forKey: key)
            encoder.encode(value, forKey: key)
        }
    }
    
    /// Decodes an object initialized from data in a given unarchiver.
    /// - Parameters:
    ///   - decoder: An unarchiver object.
    ///   - object: An object you want to decode.
    @objc public class func decode(_ decoder: NSCoder, forObject object: NSObject) {
        let ivarNames = self.supplyPropertyList(withClass: object.classForCoder)
        for key in ivarNames {
            let value = decoder.decodeObject(forKey: key)
            object.setValue(value, forKey: key)
        }
    }
    
    /// Returns the value associated with a given object for a given key.
    /// - Parameters:
    ///   - object: The source object for the association.
    ///   - key: The key for the association.
    /// - Returns: The value associated with the key key for object.
    @objc public class func getAssociatedObject(_ object: Any, key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(object, key)
    }
    
    /// Sets an associated value for a given object using a given key and association policy.
    /// - Parameters:
    ///   - object: The source object for the association.
    ///   - key: The key for the association.
    ///   - value: The value to associate with the key key for object. Pass nil to clear an existing association.
    ///   - policy: The policy for the association. For possible values, see [objc_AssociationPolicy]().
    @objc public class func setAssociatedObject(_ object: Any, key: UnsafeRawPointer, value: Any?, policy: objc_AssociationPolicy) {
        objc_setAssociatedObject(object, key, value, policy)
    }
    
}

extension NSObject {
    
    /// Replace an instance method of a class.
    /// - Parameters:
    ///   - selector: The selector of the method you want to retrieve. (@objc dynamic)
    ///   - type: The type to cast c-block to. e.g.: typealias IMPCType = @convention(c) (Any, Selector) -> Void
    ///   - block: The block that implements this method.
    ///   let newFunc: @convention(block) (Any) -> Void = {
    ///        (obj) in
    ///        oldImpBlock(obj, selector)
    ///    }
    ///   - Returns: A new instance of type U.
    public class func dy_replaceInstanceMethod<U>(selector: Selector, type: U.Type, block: Any) -> U? {
        // Get a specified instance method for a given class.
        let method = class_getInstanceMethod(self, selector)
        if let method = method, self.init().responds(to: selector) {
            // Get the implementation of a method.
            let oldImp = method_getImplementation(method)
            // Convert imp to c-compatible function pointer.
            let oldImpBlock = unsafeBitCast(oldImp, to: type)
            // Its parameter needs an oc block (@convention(block)).
            let imp = imp_implementationWithBlock(block)
            // Replace the old method with the new one.
            method_setImplementation(method, imp)
            return oldImpBlock
        }
        return nil
    }
    
    /// Replace a class method of a class.
    /// - Parameters:
    ///   - selector: A pointer of type SEL. Pass the selector of the method you want to retrieve. (@objc dynamic)
    ///   - type: The type to cast c-block to. e.g.: typealias IMPCType = @convention(c) (Any, Selector, Int, String) -> Void
    ///   - block: The block that implements this method. e.g.:
    ///   let newFunc: @convention(block) (Any, Int, String) -> Void = {
    ///        (obj, arg1, arg2) in
    ///        oldImpBlock(obj, selector, arg1, arg2)
    ///    }
    ///   - Returns: A new instance of type U.
    public class func dy_replaceClassMethod<U>(selector: Selector, type: U.Type, block: Any) -> U? {
        // Get a pointer to the data structure describing a given class method for a given class.
        let method = class_getClassMethod(self, selector)
        if let method = method, self.responds(to: selector) {
            // Get the implementation of a method.
            let oldImp = method_getImplementation(method)
            // Convert imp to c-compatible function pointer.
            let oldImpBlock = unsafeBitCast(oldImp, to: type)
            // Its parameter needs an oc block (@convention(block)).
            let imp = imp_implementationWithBlock(block)
            // Replace the old method with the new one.
            method_setImplementation(method, imp)
            return oldImpBlock
        }
        return nil
    }
    
}
