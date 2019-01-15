//
//  URIResolverTests.swift
//  PolarisFrameworkTests
//
//  Created by overtheleaves on 15/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import XCTest
@testable import PolarisFramework

class URIResolverTests: XCTestCase {

    func testRoute() {
        let uriResolver: URIResolver = URIResolver()
        uriResolver.register("test/to/path/{param}/{page}", type: AViewController.self)
        uriResolver.register("test/to/{param}", type: BViewController.self)
        uriResolver.otherwise(CViewController.self)
        
        let (target1, params1) = uriResolver.route("test/to/path/1/2")
        let (target2, params2) = uriResolver.route("test/to/testparam")
        let (target3, params3) = uriResolver.route("other/path")
        
        XCTAssert(target1 is AViewController)
        XCTAssert(target2 is BViewController)
        XCTAssert(target3 is CViewController)
        
        XCTAssert(params1["param"] as! String? == "1")
        XCTAssert(params1["page"] as! String? == "2")
        XCTAssert(params2["param"] as! String? == "testparam")
        XCTAssert(params3.count == 0)
    }
}

fileprivate class AViewController: URIResolvedUIViewController {
    
}

fileprivate class BViewController: URIResolvedUIViewController {
    
}

fileprivate class CViewController: URIResolvedUIViewController {
    
}
