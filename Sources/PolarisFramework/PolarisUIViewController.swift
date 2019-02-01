//
//  UrlFeaturedUIViewController.swift
//  PolarisFramework
//
//  Created by overtheleaves on 14/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//
import Foundation


open class PolarisUIViewController: UIViewController {
    
    var localPathRouter: PathRouter = PathRouter()
    var params: [String:Any] = [:]
    
    public var showNavigationBar: Bool = false
    public var identifier: String = ""
    public var openFrom: PathRouterRequestProtocol?
    public var transitionContext: StellaTransition = StellaTransition()
    
    public func getParam(_ name: String) -> Any? {
        return self.params[name]
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        if !showNavigationBar {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
}

extension PolarisUIViewController: UIViewControllerTransitioningDelegate {
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if transitionContext.useTransition {
            return PresentAnimationController(transitionContext)
        }
        return nil
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if transitionContext.useTransition {
            return DismissAnimationController(transitionContext)
        }
        return nil
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
    public func handle(_ from: PathRouterRequestProtocol, params: [String : Any], options: PresentationOptions?) {
        self.params = params
        self.openFrom = from
        
        var handleModal: Bool = false
        
        if let options = options {
            handleModal = options.modal
        }
        
        if handleModal {
            let vc = from as! UIViewController
            
            if let transitioningDelegate = vc as? UIViewControllerTransitioningDelegate {
                self.transitioningDelegate = transitioningDelegate
            }
            
            self.modalPresentationStyle = .overFullScreen
            self.view.backgroundColor = options?.modalBackgroundColor
            vc.present(self, animated:true, completion: nil)
        } else {
            // default
            Global.navigationController?.pushViewController(self, animated: true)
        }
    }
}
