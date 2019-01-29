//
//  PolarisAnimationController.swift
//  PolarisFramework
//
//  Created by overtheleaves on 22/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import UIKit

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let context: StellaTransition
    
    init(_ context: StellaTransition) {
        self.context = context
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return context.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if !context.useTransition {
            transitionContext.completeTransition(true)
            return
        }
       
        guard let vc = transitionContext.viewController(forKey: .to),
            let toVC = getPolarisViewController(vc),
            let toView = transitionContext.view(forKey: .to)
            else {
                transitionContext.completeTransition(true)
                return
        }
       
        let otherTransition = toVC.transitionContext
        let containerView = transitionContext.containerView
        context.containerView = containerView
        context.makeMatchAnimation(otherTransition)
            
        // save final view first
        toView.frame = containerView.bounds
        containerView.addSubview(toView)
        containerView.sendSubviewToBack(toView)
        toView.isHidden = true
        
        context.animateConcurrent {
            toView.isHidden = false
            toView.layoutIfNeeded()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
   
}

func getPolarisViewController(_ viewController: UIViewController) -> PolarisUIViewController? {
    
    switch viewController {
    case let nvc as UINavigationController:
        
        if let polarisVC = nvc.topViewController as? PolarisUIViewController {
            return polarisVC
        }
        return nil
        
    case let vc as PolarisUIViewController:
        return vc
        
    default:
        return nil
    }
}
