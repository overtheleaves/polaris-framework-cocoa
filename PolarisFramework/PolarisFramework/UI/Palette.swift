//
//  Palette.swift
//  PolarisFramework
//
//  Created by overtheleaves on 01/02/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

public class Palette {
    // color chip
    public static var backgroundColor: UIColor?
    public static var themeColor: UIColor?
    public static var shadowColor: UIColor?
    
    public static var systemAttribute: StyleAttribute = StyleAttribute(color: nil, font: UIFont.systemFont(ofSize: UIFont.systemFontSize))
    
    public static var h1Attribute: StyleAttribute = StyleAttribute(color: nil, font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 2)) // 2em
    public static var h2Attribute: StyleAttribute = StyleAttribute(color: nil, font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5))    // 1.5em
    public static var h3Attribute: StyleAttribute = StyleAttribute(color: nil, font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.17))   // 1.17em
    public static var h4Attribute: StyleAttribute = StyleAttribute(color: nil, font: UIFont.systemFont(ofSize: UIFont.systemFontSize))   // 1em
    public static var h5Attribute: StyleAttribute = StyleAttribute(color: nil, font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.83))   // 0.83em
    public static var h6Attribute: StyleAttribute = StyleAttribute(color: nil, font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.67))   // 0.67em
    public static var pAttribute: StyleAttribute = StyleAttribute(color: nil, font: UIFont.systemFont(ofSize: UIFont.systemFontSize))   // 1em
    
    public static var customAttribute: [String:StyleAttribute] = [:]
    
    public static func getAttribute(type: DefaultStyleAttributeType) -> StyleAttribute {
        switch type {
        case .h1:
            return h1Attribute
        case .h2:
            return h2Attribute
        case .h3:
            return h3Attribute
        case .h4:
            return h4Attribute
        case .h5:
            return h5Attribute
        case .h6:
            return h6Attribute
        case .p:
            return pAttribute
        }
    }
    
    public static func getAttribute(id: String) -> StyleAttribute? {
        switch id {
        case DefaultStyleAttributeType.h1.rawValue:
            return h1Attribute
        case DefaultStyleAttributeType.h2.rawValue:
            return h2Attribute
        case DefaultStyleAttributeType.h3.rawValue:
            return h3Attribute
        case DefaultStyleAttributeType.h4.rawValue:
            return h4Attribute
        case DefaultStyleAttributeType.h5.rawValue:
            return h5Attribute
        case DefaultStyleAttributeType.h6.rawValue:
            return h6Attribute
        case DefaultStyleAttributeType.p.rawValue:
            return pAttribute
        default :
            return customAttribute[id]
        }
    }
}

public enum DefaultStyleAttributeType: String {
    case h1 = "h1"
    case h2 = "h2"
    case h3 = "h3"
    case h4 = "h4"
    case h5 = "h5"
    case h6 = "h6"
    case p = "p"
}

public class StyleAttribute {
    public var color: UIColor
    public var font: UIFont
    
    public init(color: UIColor?, font: UIFont?) {
        self.color = color ?? UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.font = font ?? UIFont.systemFont(ofSize: 12.0)
    }
}
