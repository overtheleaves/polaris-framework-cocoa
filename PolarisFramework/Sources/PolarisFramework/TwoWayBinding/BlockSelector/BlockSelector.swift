//
//  BlockSelector.swift
//  PolarisFramework
//
//  Created by overtheleaves on 31/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation
import UIKit

func Selector(_ block: @escaping () -> Void) -> Selector {
    let selector = NSSelectorFromString("\(CACurrentMediaTime())")
    class_addMethodWithBlock(_Selector.self, selector) { (_) in block() }
    return selector
}

let Selector = _Selector.shared
@objc class _Selector: NSObject {
    static let shared = _Selector()
}
