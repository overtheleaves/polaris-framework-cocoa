// swift-tools-version:4.0
//
//  Package.swift
//  PolarisFramework
//
//  Created by overtheleaves on 01/02/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "PolarisFramework",
    products: [
        .library(name: "PolarisFramework", targets: ["PolarisFramework"]),
        ],
    targets: [
        .target(
            name: "PolarisFramework",
            dependencies: []),
        .testTarget(
            name: "PolarisFrameworkTests",
            dependencies: ["PolarisFramework"]),
        ]
)
