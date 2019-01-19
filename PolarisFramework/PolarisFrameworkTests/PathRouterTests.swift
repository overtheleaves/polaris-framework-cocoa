//
//  URIResolverTests.swift
//  PolarisFrameworkTests
//
//  Created by overtheleaves on 15/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import XCTest
@testable import PolarisFramework

class PathRouterTests: XCTestCase {
    var app: XCUIApplication!

    func testRoute() {
        let pathRouter: PathRouter = PathRouter()
        pathRouter.register("test/to/path/{param}/{page}", type: AViewController.self)
        pathRouter.register("test/to/{param}", type: BViewController.self)
        pathRouter.otherwise(CViewController.self)
        
        let (target1, params1) = pathRouter.route("test/to/path/1/2?query1=aa&query2=bb")
        let (target2, params2) = pathRouter.route("test/to/testparam")
        let (target3, params3) = pathRouter.route("other/path")
        
        XCTAssert(target1 is AViewController)
        XCTAssert(target2 is BViewController)
        XCTAssert(target3 is CViewController)
        
        XCTAssert(params1["param"] as! String? == "1")
        XCTAssert(params1["page"] as! String? == "2")
        XCTAssert(params1["query1"] as! String? == "aa")
        XCTAssert(params1["query2"] as! String? == "bb")
        XCTAssert(params2["param"] as! String? == "testparam")
        XCTAssert(params3.count == 0)
        
        let view: UIView = UIView()
        pathRouter.register("test/to/view", target: view)
        let (target4, _) = pathRouter.route("test/to/view")
        
        XCTAssertNotNil(target4 is UIView)
    }
    
    func testGoAndSendBack() {
        let uriResolver: PathRouter = PathRouter()
        uriResolver.register("test/to/path/{param}", type: BViewController.self)
        let aViewController = AViewController()
        
        do {
            // go AViewController -> BViewController
            let vc = try uriResolver.locationChange(aViewController, path: "test/to/path/11")
           
            if let viewController = vc as? PolarisUIViewController {
                XCTAssert(viewController.getParam("param") as! String? == "11")
                
            } else {
                XCTFail()
            }
            
        } catch {
            print(error)
        }
    }
}

fileprivate class AViewController: PolarisUIViewController {
    
}

fileprivate class BViewController: PolarisUIViewController {
    
}

fileprivate class CViewController: PolarisUIViewController {
    
}
