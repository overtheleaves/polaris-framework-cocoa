//
//  PolarisViewModel.swift
//  PolarisFramework
//
//  Created by overtheleaves on 30/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

@objc public protocol PolarisViewModel {
    @objc optional func viewDidLoad()
    @objc optional func viewWillAppear()
    @objc optional func viewDidAppear()
    @objc optional func viewWillDisappear()
    @objc optional func viewDidDisappear()
}
