//
//  H1Label.swift
//  PolarisFramework
//
//  Created by overtheleaves on 01/02/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import UIKit

public protocol StyleAttributedCompatible {
    associatedtype CompatibleType
    
    var styleAttr: StyleAttributedExtension<CompatibleType> { get set }
}

public extension StyleAttributedCompatible {
    public var styleAttr: StyleAttributedExtension<Self> {
        get { return StyleAttributedExtension(self) }
        set { }
    }
}

public class StyleAttributedExtension<Base> {
    public let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

fileprivate struct AssociatedKeys {
    static var style: UInt8 = 0
}

extension UIView: StyleAttributedCompatible { }


public extension StyleAttributedExtension where Base: UILabel {
    public var style: String {
        get {
            guard let value = objc_getAssociatedObject(base, &AssociatedKeys.style) as? String else {
                
                let newValue = DefaultStyleAttributeType.h1.rawValue
                objc_setAssociatedObject(self, &AssociatedKeys.style, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newValue
            }
            return value
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.style, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public extension UILabel {
    
    @IBInspectable public var attr: String? {
        get {
            return self.styleAttr.style
        }
        set {
            if let val = newValue, let attribute = Palette.getAttribute(id: val) {
                self.font = attribute.font
                self.textColor = attribute.color
                self.sizeToFit()
            }
        }
    }
}
