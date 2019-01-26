//
//  StellaTransition.swift
//  PolarisFramework
//
//  Created by overtheleaves on 26/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

public class StellaTransition {
    public var useTransition = false
    public var duration: TimeInterval = 1
    
    var animator: StellaAnimator = StellaAnimator()
    var snapshots: [UIView] = []
    let defaultAnimationOptions = UIView.AnimationOptions.curveEaseInOut
    var containerView: UIView?
    
    public func transition(_ target: UIView, animations: [StellaAnimationType]) {
        
        if let snapshot = target.snapshotView(afterScreenUpdates: true) {
            snapshots.append(snapshot)
            for type in animations {
                switch type {
                case .fadeIn:
                    snapshot.alpha = 0.0
                    let _ = animator.addAnimation(duration: duration,
                                          delay: 0,
                                          options: defaultAnimationOptions) {
                                            snapshot.alpha = 1.0
                                        }
                case .fadeOut:
                    snapshot.alpha = 1.0
                    let _ = animator.addAnimation(duration: duration,
                                          delay: 0,
                                          options: defaultAnimationOptions) {
                                            snapshot.alpha = 0.0
                                        }
                case .scale(direction: .up):
                    let originalFrame = frameOfViewInWindowsCoordinateSystem(target)
                    snapshot.frame = CGRect(x: originalFrame.origin.x, y: originalFrame.origin.y,
                                            width: 0, height: 0)
                    snapshot.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    snapshot.layer.position = CGPoint(x: originalFrame.midX, y: originalFrame.midY)
                    let _ = animator.addAnimation(duration: duration,
                                                  delay: 0,
                                                  options: defaultAnimationOptions) {
                                                    snapshot.frame = originalFrame
                                                }
                    
                case .scale(direction: .down):
                    let originalFrame = frameOfViewInWindowsCoordinateSystem(target)
                    snapshot.frame = CGRect(x: originalFrame.origin.x, y: originalFrame.origin.y,
                                            width: originalFrame.width * 1.3,
                                            height: originalFrame.height * 1.3)
                    snapshot.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                    snapshot.layer.position = CGPoint(x: originalFrame.midX, y: originalFrame.midY)
                    let _ = animator.addAnimation(duration: duration,
                                                  delay: 0,
                                                  options: defaultAnimationOptions) {
                                                    snapshot.frame = originalFrame
                    }
                
                default:
                    continue
                }
            }
        }
    }
    
    public func animateConcurrent(completion: (() -> ())?) {
        
        if let containerView = self.containerView {
            self.snapshots.forEach({ (snapshot) in
                containerView.addSubview(snapshot)
            })
            
            self.animator.animateConcurrent {
                
                self.snapshots.forEach({ (snapshot) in
                    snapshot.removeFromSuperview()
                })
                
                self.snapshots.removeAll()
                
                if let _ = completion {
                    completion?()
                }
            }
        }
    }
    
    public func animateSerial(completion: (() -> ())?) {
        
        if let containerView = self.containerView {
            self.snapshots.forEach({ (snapshot) in
                containerView.addSubview(snapshot)
            })
            
            self.animator.animateSerial {
                self.snapshots.forEach({ (snapshot) in
                    snapshot.removeFromSuperview()
                })
                
                self.snapshots.removeAll()
                
                if let _ = completion {
                    completion?()
                }
            }
        }
    }
    
    func frameOfViewInWindowsCoordinateSystem(_ view: UIView) -> CGRect {
        if let superview = view.superview {
            return superview.convert(view.frame, to: nil)
        }
        print("[ANIMATION WARNING] Seems like this view is not in views hierarchy\n\(view)\nOriginal frame returned")
        return view.frame
    }
}

public enum StellaAnimationType {
    case fadeIn
    case fadeOut
    case scale(direction: Direction)
}

public enum Direction {
    case up
    case down
    case left
    case right
}
