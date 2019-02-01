//
//  NSObject+Observable.swift
//  PolarisFramework
//
//  Created by overtheleaves on 31/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

extension NSObject {
    public func observe<T>(for observable: Observable<T>, with: @escaping (T) -> ()) {
        observable.bind { observable, value  in
            DispatchQueue.main.async {
                with(value)
            }
        }
    }
}
