//
//  PolarisUIView.swift
//  PolarisFramework
//
//  Created by overtheleaves on 19/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

open class PolarisUIView: UIView, PathRouterHandleProtocol, UIGestureRecognizerDelegate {
    
    var onClickEventActions:[(_ view: PolarisUIView)->Void] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initTouch()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTouch()
    }
    
    func initTouch() {
        let action = #selector(self.onClickEventAction(_:))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)
        tapGestureRecognizer.delegate = self
        
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    open func handle(_ from: PathRouterRequestProtocol, params: [String : Any]) {
        self.isHidden = false
    }
    
    public func addOnClickEventAction(_ block: @escaping (_ view: PolarisUIView) -> Void) {
        onClickEventActions.append(block)
    }
    
    @objc func onClickEventAction(_ sender: UITapGestureRecognizer) {
        for action in onClickEventActions {
            action(self)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
