//
//  UrlFeaturedUIViewController.swift
//  PolarisFramework
//
//  Created by overtheleaves on 14/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

open class URIResolvedUIViewController: UIViewController {
    
    internal var params: [String:Any] = [:]
    
    public func getParam(_ name: String) -> Any? {
        return self.params[name]
    }    
}
