//
//  StellaTransition.swift
//  PolarisFramework
//
//  Created by overtheleaves on 26/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

public class StellaTransition {
    
    typealias MatchViewTuple = (UIView, Option)
    
    public var useTransition = false
    public var duration: TimeInterval = 0.7
    
    // animation 3-steps
    var warmUpAnimator: StellaAnimator = StellaAnimator()
    var durationAnimator: StellaAnimator = StellaAnimator()
    var stopAnimator: StellaAnimator = StellaAnimator()
    
    var snapshots: [UIView] = []
    var fromViews: [UIView] = []
    let defaultAnimationOptions = UIView.AnimationOptions.curveEaseInOut
    var containerView: UIView?
    var matchViewIds: [String] = []
    var matchViews: [String:MatchViewTuple] = [:]
    
    // one-way transition
    public func transition(_ target: UIView, animations: [StellaAnimationType]) {
        
        if let snapshot = target.snapshotView(afterScreenUpdates: true) {
            snapshots.append(snapshot)
            for type in animations {
                switch type {
                case .fadeIn:
                    snapshot.alpha = 0.0
                    let _ = durationAnimator.addAnimation(duration: duration,
                                          delay: 0,
                                          options: defaultAnimationOptions) {
                                            snapshot.alpha = 1.0
                                        }
                case .fadeOut:
                    snapshot.alpha = 1.0
                    let _ = durationAnimator.addAnimation(duration: duration,
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
                    let _ = durationAnimator.addAnimation(duration: duration,
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
                    let _ = durationAnimator.addAnimation(duration: duration,
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
    
    // two-way transition
    public func matchTransition(_ id: String, target: UIView, option: Option = Option.useFromView) {
        self.matchViewIds.append(id)
        self.matchViews[id] = (target, option)
    }
    
    func makeMatchAnimation(_ other: StellaTransition) {
        
        for id in self.matchViewIds {
            
            guard let (from, option) = self.matchViews[id]
                else {
                    print("cannot find matchView(id=\(id) in this context")
                    continue
            }
            
            guard let (to, _) = other.matchViews[id]
                else {
                    print("cannot find toView(id=\(id) in other transition")
                    continue
            }
            
            var snapshot: UIView?
            
            switch option {
            case .useFromView:
                snapshot = from.snapshotView(afterScreenUpdates: true)
            case .useToView:
                snapshot = to.snapshotView(afterScreenUpdates: true)
            }
            
            if let snapshot = snapshot {
                let finalFrame = frameOfViewInWindowsCoordinateSystem(to)
                let finalLayer = to.layer
                let originalFrame = frameOfViewInWindowsCoordinateSystem(from)

                snapshots.append(snapshot)
                fromViews.append(from)
                snapshot.frame = from.frame
                snapshot.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                snapshot.layer.position = CGPoint(x: originalFrame.midX, y: originalFrame.midY)
                snapshot.layer.cornerRadius = from.layer.cornerRadius
                let _ = durationAnimator.addAnimation(duration: duration,
                                      delay: 0,
                                      options: defaultAnimationOptions) {
                                        snapshot.frame = finalFrame
                                        snapshot.layer.cornerRadius = finalLayer.cornerRadius
                                        snapshot.layer.position = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                                    }
            }
        }
    }
    
    func initializeState(_ containerView: UIView) {
        // init state: add all snapshots into containerView
        self.snapshots.forEach({ (snapshot) in
            containerView.addSubview(snapshot)
        })
        
        // init state: hide all fromViews
        self.fromViews.forEach { (v) in
            v.isHidden = true
        }
    }
    
    func finalizeState() {
        // final state: remove all snapshots from containerView
        self.snapshots.forEach({ (snapshot) in
            snapshot.removeFromSuperview()
        })
        
        self.snapshots.removeAll()
        
        // final state: show all fromViews
        self.fromViews.forEach({ (v) in
            v.isHidden = false
        })

    }
    
    public func animateConcurrent(completion: (() -> ())?) {
        
        if let containerView = self.containerView {
            
            initializeState(containerView)
            
            self.durationAnimator.animateConcurrent {
                
                self.finalizeState()
                
                if let _ = completion {
                    completion?()
                }
            }
        }
    }
    
    public func animateSerial(completion: (() -> ())?) {
        
        if let containerView = self.containerView {
            
            initializeState(containerView)
            
            self.durationAnimator.animateSerial {
                
                self.finalizeState()
                
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
    case zoomIn
    case zoomOut
}

public enum Direction {
    case up
    case down
    case left
    case right
}

public enum Option {
    case useFromView
    case useToView
}
