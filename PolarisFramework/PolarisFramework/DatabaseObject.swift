//
//  DatabaseObject.swift
//  PolarisFramework
//
//  Created by overtheleaves on 08/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

class DatabaseObject: NSObject {
    
    public internal(set) var id: String?
    required override init() { }
    
    class func object<Element: DatabaseObject>(_ type: Element.Type, id: String, dict: Dictionary<String, Any>) -> Element {
        let element = type.init()
        element.id = id
        
        guard let properties = Reflection.getTypesOfProperties(in: type)
            else {
                return element
        }
        
        for (name, value) in dict {
            if properties[name] != nil {
                 element.setValue(value, forKey: name)
            }
        }
        
        return element
    }
}
