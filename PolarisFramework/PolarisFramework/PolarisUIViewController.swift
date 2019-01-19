//
//  UrlFeaturedUIViewController.swift
//  PolarisFramework
//
//  Created by overtheleaves on 14/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//
import Foundation

open class PolarisUIViewController: UIViewController {
    
    var openFrom: PathRouterRequestProtocol?
    var localPathRouter: PathRouter = PathRouter()
    var params: [String:Any] = [:]
    public var identifier: String = ""
    
    public func getParam(_ name: String) -> Any? {
        return self.params[name]
    }
}

extension PolarisUIViewController: PathRouterRequestProtocol {
    public func locationChange(_ path: String) throws {
        // try local path router first
        if let _ = try localPathRouter.locationChange(self, path: path) {
            return
        }
        
        // if cannot find path from local, then try global path router
        let _ = try Global.pathRouter.locationChange(self, path: path)
    }
    
    public func register(_ path: String, target: PathRouterHandleProtocol) {
        localPathRouter.register(path, target: target)
    }
    
    open func onPathRouterRequestResult(identifier: String, result: [String : Any]) {
        
    }
}

extension PolarisUIViewController: PathRouterHandleProtocol {
    public func handle(_ from: PathRouterRequestProtocol, params: [String : Any]) {
        self.params = params
        self.openFrom = from
        
        Global.navigationController?.pushViewController(self, animated: true)
        //vc.present(self, animated: true, completion: nil)
    }
}
