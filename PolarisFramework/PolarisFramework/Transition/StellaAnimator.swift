//
//  StellaAnimator.swift
//  PolarisFramework
//
//  Created by overtheleaves on 26/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

public class StellaAnimator {
    
    public typealias AnimatorAnimationsClosure = () -> ()
    public typealias AnimatorCompletionClosure = () -> ()
    let defaultTimingFunction = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
    
    struct AnimationParameters {
        
        let duration: TimeInterval
        let delay: TimeInterval
        let options: UIView.AnimationOptions
        let damping: CGFloat?
        let initialVelocity: CGFloat?
        
        init(duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, damping: CGFloat? = nil, initialVelocity: CGFloat? = nil) {
            self.duration = duration
            self.delay = delay
            self.options = options
            self.damping = damping
            self.initialVelocity = initialVelocity
        }
    }
    
    
    var animations:[(AnimatorAnimationsClosure, AnimationParameters)] = []
    
    /// add animation funcion (for static)
    /// - Parameters:
    ///     - duration: animation duration time
    ///     - delay: animation delay (start) time
    ///     - options: animation options
    ///     - damping: damping value (optional)
    ///     - initialVelocity: initial velocity (optional)
    ///     - animation: animation closure
    /// - Returns:
    ///     - a new StellaAnimator instance
    static public func addAnimation (duration: TimeInterval, delay: TimeInterval,
                              options: UIView.AnimationOptions,
                              damping: CGFloat? = nil, initialVelocity: CGFloat? = nil,
                            animation: @escaping AnimatorAnimationsClosure) -> StellaAnimator {
        
        let newAnimator = StellaAnimator()
        return newAnimator.addAnimation(duration: duration, delay: delay, options: options,
                                 damping: damping, initialVelocity: damping, animation: animation)
    }
    
    /// add animation funcion
    /// - Parameters:
    ///     - duration: animation duration time
    ///     - delay: animation delay (start) time
    ///     - options: animation options
    ///     - damping: damping value (optional)
    ///     - initialVelocity: initial velocity (optional)
    ///     - animation: animation closure
    /// - Returns:
    ///     - self (for chaining)
    public func addAnimation(duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions,
                      damping: CGFloat? = nil, initialVelocity: CGFloat? = nil,
                      animation: @escaping AnimatorAnimationsClosure) -> StellaAnimator {
        
        animations.append((animation, AnimationParameters(duration: duration, delay: delay, options: options,
                                                          damping: damping, initialVelocity: damping)))
        
        return self
    }
    
    /// run animations serial order
    /// - Parameters:
    ///     - completion: complete function closure (optional)
    public func animateSerial(completion: AnimatorCompletionClosure?) {
        if let (animation, parameter) = animations.first {
            
            if let damping = parameter.damping,
                let initialSpringVelocity = parameter.initialVelocity {
                UIView.animate(withDuration: parameter.duration,
                               delay: parameter.delay,
                               usingSpringWithDamping: damping,
                               initialSpringVelocity: initialSpringVelocity,
                               options: parameter.options,
                               animations: animation,
                               completion: { completed in
                                let _ = self.animations.removeFirst()
                                self.animateSerial(completion: completion)
                            })
                
            } else {
                UIView.animate(withDuration: parameter.duration,
                               delay: parameter.delay,
                               animations: animation,
                               completion: { completed in
                                let _ = self.animations.removeFirst()
                                self.animateSerial(completion: completion)
                            })
            }
            
        } else {
            if let completion = completion {
                completion()
            }
        }
    }
    
    /// run animations concurrently
    /// - Parameters:
    ///     - completion: complete function closure (optional)
    public func animateConcurrent(completion: AnimatorCompletionClosure?) {
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(defaultTimingFunction)
        CATransaction.setCompletionBlock({
            // remove all animations
            self.animations.removeAll()
            if let completion = completion {
                completion()
            }
        })
        
        for (animation, parameter) in animations {
            if let damping = parameter.damping,
                let initialSpringVelocity = parameter.initialVelocity {
                UIView.animate(withDuration: parameter.duration,
                               delay: parameter.delay,
                               usingSpringWithDamping: damping,
                               initialSpringVelocity: initialSpringVelocity,
                               options: [],
                               animations: animation,
                               completion: nil)
                
            } else {
//                UIView.animate(withDuration: parameter.duration,
//                               delay: parameter.delay,
//                               options: [],
//                               animations: animation,
//                               completion: nil)
                
                                UIView.animate(withDuration: parameter.duration,
                                               animations: animation,
                                               completion: nil)

            }
        }
        
        CATransaction.commit()
    }
}
