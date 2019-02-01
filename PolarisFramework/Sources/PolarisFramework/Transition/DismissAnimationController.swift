//
//  DismissAnimationController.swift
//  PolarisFramework
//
//  Created by overtheleaves on 26/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
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
            let vc2 = transitionContext.viewController(forKey: .from),
            let toVC = getPolarisViewController(vc),
            let fromVC = getPolarisViewController(vc2),
            let fromView = fromVC.view,
            let toView = toVC.view
            else {
                transitionContext.completeTransition(true)
                return
        }
        
        let fromContext = fromVC.transitionContext
        let containerView = transitionContext.containerView
        
        fromContext.containerView = containerView
        fromContext.makeMatchAnimation(context)
        fromView.isHidden = true
        
        fromContext.animateConcurrent {
            fromView.isHidden = false
            fromView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
       
    }
    
}
