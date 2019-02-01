//
//  ReflectionTests.swift
//  PolarisFramework
//
//  Created by overtheleaves on 04/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import XCTest
@testable import PolarisFramework

class ReflectionTests: XCTestCase {

    fileprivate var testModel: ReflectionTestModel? = nil
    
    override func setUp() {
        super.setUp()
        let info = ReflectionTestSubModel(money: 1000)
        testModel = ReflectionTestModel(name: "tester",
                                        age: 20,
                                        isFemale: true,
                                        birthday: Date(),
                                        friends: ["Huey", "Dewey", "Louie"],
                                        info: info)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetTypesOfProperties() {
        let properties = Reflection.getTypesOfProperties(in: ReflectionTestModel.self)
        
        guard let props = properties else {
            XCTFail()
            return
        }
        
        for (name, type) in props {
            let strtype = "\(type)"
            if name == "name" {
                XCTAssert(strtype == "NSString")
            } else if name == "age" {
                XCTAssert(strtype == "UInt")
            } else if name == "isFemale" {
                XCTAssert(strtype == "Bool")
            } else if name == "birthday" {
                XCTAssert(strtype == "NSDate")
            } else if name == "friends" {
                XCTAssert(strtype == "NSArray")
            } else if name == "info" {
                XCTAssert(strtype == "ReflectionTestSubModel")
            }
        }
    }
}

fileprivate class ReflectionTestModel: DatabaseObject {
    @objc dynamic var name: String
    @objc dynamic var age: UInt
    @objc dynamic var isFemale: Bool
    @objc dynamic var birthday: Date?
    @objc dynamic var friends: [String]?
    @objc dynamic var info: ReflectionTestSubModel?
    
    init(name: String, age: UInt, isFemale: Bool, birthday: Date, friends: [String], info: ReflectionTestSubModel) {
        self.name = name
        self.age = age
        self.isFemale = isFemale
        self.birthday = birthday
        self.friends = friends
        self.info = info
    }
    
    required init() {
        self.name = ""
        self.age = 0
        self.isFemale = false
        self.birthday = nil
        self.friends = nil
        self.info = nil
    }
}

fileprivate class ReflectionTestSubModel: DatabaseObject {
    @objc dynamic var money: Decimal
    
    init(money: Decimal) {
        self.money = money
    }
    
    required init() {
        self.money = 0
    }
}
