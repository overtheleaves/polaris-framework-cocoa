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
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
       
        guard let toView = transitionContext.view(forKey: .to)
            else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        let containerView = transitionContext.containerView
        context.containerView = containerView
            
        // save final view first
        toView.frame = containerView.bounds
        containerView.addSubview(toView)
        toView.isHidden = true
        
        context.animateConcurrent {
            toView.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
