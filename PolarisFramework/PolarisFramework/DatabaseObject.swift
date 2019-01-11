//
//  DatabaseObject.swift
//  PolarisFramework
//
//  Created by overtheleaves on 08/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

class DatabaseObject: NSObject {
    
    private var _id: String = ""
    required override init() { }
    
    public func id() -> String {
        return self._id
    }
    
    class func object<Element: DatabaseObject>(_ type: Element.Type, id: String, dict: Dictionary<String, Any>) -> Element {
        let element = type.init()
        element._id = id
        
        guard let properties = Reflection.getTypesOfProperties(in: type)
            else {
                return element
        }
        
        for (name, value) in dict {
            if properties[name] != nil {
                if name.hasPrefix(DatabaseHelper.FIELD_FOREIGN_KEYS_PREFIX)
                    || name == DatabaseHelper.FIELD_META_TYPE {
                    // foreign keys meta field
                    continue
                } else {
                    if "\(properties[name] ?? "")" == "Date" {
                        // string to date
                        
                    } else {
                        element.setValue(value, forKey: name)
                    }
                }
            }
        }
        
        return element
    }
}
