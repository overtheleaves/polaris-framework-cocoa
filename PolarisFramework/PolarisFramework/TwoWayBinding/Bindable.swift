//
//  Bindable.swift
//  PolarisFramework
//
//  Created by overtheleaves on 30/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

public protocol Bindable: NSObjectProtocol {
    associatedtype BindingType: Equatable
    func observingValue() -> BindingType?
    func updateValue(_ value: BindingType)
    func bind(_ observer: Observable<BindingType>)
}

fileprivate struct AssociatedKeys {
    static var binder: UInt8 = 0
}

extension Bindable where Self: NSObject {
    
    var binder: Observable<BindingType> {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.binder) as? Observable<BindingType> else {
                
                let newValue = Observable<BindingType>()
                objc_setAssociatedObject(self, &AssociatedKeys.binder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newValue
            }
            return value
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.binder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func register(for observable: Observable<BindingType>) {
        self.binder = observable
    }
    
    public func bind(_ observable: Observable<BindingType>) {
        
        if let _self = self as? UIControl {
            _self.addTarget(Selector, action: Selector{ [weak self] in self?.valueChanged() },
                           for: [.editingChanged, .valueChanged])
        }
        
        self.binder = observable
        
        if let val = observable.value {
            self.updateValue(val)
        }
        
        // listen observable's value changed
        self.observe(for: observable) { (value) in
            self.updateValue(value)
        }
    }
    
    func valueChanged() {
        if binder.value != self.observingValue() {
            binder.value = self.observingValue()
        }
    }
}
