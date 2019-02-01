//
//  Observable.swift
//  PolarisFramework
//
//  Created by overtheleaves on 30/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

public class Observable<ObservedType> {
    
    public typealias Observer = (_ observable: Observable<ObservedType>, ObservedType) -> Void

    public var value: ObservedType? {
        didSet {
            if let value = value {
                notifyObservers(value)
            }
        }
    }
    
    private var observers: [Observer]
    
    public init(_ value: ObservedType? = nil) {
        self.value = value
        self.observers = []
    }
    
    public func bind(observer: @escaping Observer) {
        self.observers.append(observer)
    }
    
    private func notifyObservers(_ value: ObservedType) {
        for observer in observers {
            observer(self, value)
        }
    }    
}
