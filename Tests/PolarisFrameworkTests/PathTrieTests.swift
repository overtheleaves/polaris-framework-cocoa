//
//  PathTrieTests.swift
//  PolarisFrameworkTests
//
//  Created by overtheleaves on 14/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import XCTest
@testable import PolarisFramework

class PathTrieTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTrieNode() {
        let pathname = "path1"
        let value = "test"
        let node: TrieNode = TrieNode(pathname, value: value)
        
        XCTAssert(node.key == pathname)
        XCTAssert(node.wildcard == false)
        
        guard let strValue = node.value as! String?
            else {
                XCTFail()
                return
        }
        
        XCTAssert(strValue == value)
    }
    
    func testTrieNode_wildcard() {
        let pathname = "param"
        let value = "test"
        let node: TrieNode = TrieNode("{" + pathname + "}", value: value)
        
        XCTAssert(node.key == pathname, node.key)
        XCTAssert(node.wildcard == true)
        
        guard let strValue = node.value as! String?
            else {
                XCTFail()
                return
        }
        
        XCTAssert(strValue == value)
    }
    
    func testTrieNode_add() {
        let root: TrieNode = TrieNode("", value: nil)
        let path: [String] = ["path", "to", "test"]
        let unregisteredPath: [String] = ["path", "to", "test1"]
        let testValue: String = "test"
        var params: Dictionary<String, Any> = Dictionary()
        
        root.add(path, value: testValue)
        
        XCTAssertNotNil(root.children["path"]?.children["to"]?.children["test"])
        XCTAssertNil(root.children["path"]?.value)
        XCTAssertNil(root.children["path"]?.children["to"]?.value)
        
        guard let retValue = root.get(path, params: &params) as! String?
            else {
                XCTFail()
                return
        }
        XCTAssert(testValue == retValue)
        
        XCTAssertNil(root.get(unregisteredPath, params: &params))
    }
    
    func testTrieNode_delete() {
        let root: TrieNode = TrieNode("", value: nil)
        let path: [String] = ["path", "to", "test"]
        let testValue: String = "test"
        var params: Dictionary<String, Any> = Dictionary()
        
        root.add(path, value: testValue)
        XCTAssertNotNil(root.get(path, params: &params))
        
        root.delete(path)
        XCTAssertNil(root.get(path, params: &params))
        
        XCTAssertNil(root.children["path"])
    }
    
    func testTrieNode_addWildCard() {
        let root: TrieNode = TrieNode("", value: nil)
        let path: [String] = ["path", "{param1}", "{param2}", "test"]
        let path2: [String] = ["path", "{param1}", "{param2}", "other"]
        let path3: [String] = ["path", "{param1}", "test1"]
        let testValue: String = "test"
        let testValue2: String = "test2"
        let testValue3: String = "test2"
        let param1 = "test1"
        let param2 = "test2"
        var params: Dictionary<String, Any> = Dictionary()

        root.add(path, value: testValue)
        root.add(path2, value: testValue2)
        root.add(path3, value: testValue3)
        
        // registered path
        let ret = root.get(["path", param1, param2, "test"], params: &params)
        
        XCTAssertNotNil(ret)
        XCTAssertNotNil(params["param1"])
        XCTAssertNotNil(params["param2"])
        XCTAssert(ret as! String? == testValue)
        XCTAssert(params["param1"] as! String? == param1)
        XCTAssert(params["param2"] as! String? == param2)
        
        params = Dictionary()
        let ret2 = root.get(["path", param1, "test1"], params: &params)
        
        XCTAssert(ret2 as! String? == testValue3)
        XCTAssert(params["param1"] as! String? == param1)
        XCTAssertNil(params["param2"])
        
        
        // unregistered path
        params = Dictionary()
        let ret3 = root.get(["path", param1, param2], params: &params)
        XCTAssertNil(ret3)
        XCTAssertNil(params["param1"])
        XCTAssertNil(params["param2"])
    }
}
