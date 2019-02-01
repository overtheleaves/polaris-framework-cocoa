//
//  Reflection.swift
//  PolarisFramework
//
//  Created by overtheleaves on 04/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//
import ObjectiveC.runtime

public class Reflection {
    
    private static let valueTypesMap: Dictionary<String, Any> = [
        "c" : Int8.self,
        "s" : Int16.self,
        "i" : Int32.self,
        "q" : Int.self, //also: Int64, NSInteger, only true on 64 bit platforms
        "S" : UInt16.self,
        "I" : UInt32.self,
        "Q" : UInt.self, //also UInt64, only true on 64 bit platforms
        "B" : Bool.self,
        "d" : Double.self,
        "f" : Float.self,
        "{" : Decimal.self
    ]
    
    public class func getTypesOfProperties(in clazz: NSObject.Type) -> Dictionary<String, Any>? {
        var count = UInt32()
        guard
            let properties = class_copyPropertyList(clazz, &count)
            else { return nil }
        
        var types: Dictionary<String, Any> = [:]
        for i in 0..<Int(count) {
            let property: objc_property_t = properties[i]
            guard
                let name = getNameOf(property: property)
                else { continue }
            let type = getTypeOf(property: property)
            types[name] = type
        }
        free(properties)
        return types
    }
        
    public class func getSuperClass(in clazz: NSObject.Type) -> Any? {
        return class_getSuperclass(clazz)
    }
    
    public class func ClassGetSubclasses(in parentClass: NSObject.Type) -> Array<Any>? {
        var numClasses = UInt32()
        guard let classes = objc_copyClassList(&numClasses)
            else { return nil }
        
        var result: [NSObject.Type] = []
        for i in 0..<numClasses {
            let clazz = classes[Int(i)]
            
            guard class_getSuperclass(clazz) != nil
                else {
                    continue
            }
            
            if let subClass = clazz as? NSObject.Type {
                result.append(subClass)
            }
        }
       
        return result;
    }
    
    public class func getClassName(in clazz: NSObject.Type) -> String {
        return NSString(utf8String: class_getName(clazz))! as String
    }
    
    private class func getNameOf(property: objc_property_t) -> String? {
        guard
            let name: NSString = NSString(utf8String: property_getName(property))
            else { return nil }
        return name as String
    }
    
    private class func getTypeOf(property: objc_property_t) -> Any {
        guard
            let attributesAsNSString: NSString = NSString(utf8String: property_getAttributes(property)!)
            else { return Any.self }
        
        let attributes = attributesAsNSString as String
        let slices = attributes.components(separatedBy: "\"")
        
        guard
            slices.count > 1
            else { return valueType(withAttributes: attributes) }
        
        let objectClassName = slices[1]
        let objectClass = NSClassFromString(objectClassName) as! NSObject.Type
        return objectClass
    }
    
    private class func valueType(withAttributes attributes: String) -> Any {
        guard
            let letter = attributes.substring(start: 1, end: 2),
            let type = Reflection.valueTypesMap[letter]
            else { return Any.self }
        return type
    }
}
