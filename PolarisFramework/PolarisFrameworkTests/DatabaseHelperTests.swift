//
//  DatabaseHelperTests.swift
//  PolarisFramework
//
//  Created by overtheleaves on 06/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import XCTest
@testable import PolarisFramework

class DatabaseHelperTests: XCTestCase {

    var cblhelper: DatabaseHelper? = nil
    
    override func setUp() {
        super.setUp()
        do {
            try DatabaseHelper.prepare()
            cblhelper = try DatabaseHelper(DatabaseHelper.CBL, name: "test")
        } catch {
            print(error)
        }
    }

    override func tearDown() {
        do {
            try cblhelper?.delete()
        } catch  {
            print(error)
        }
        
        super.tearDown()
    }
    
    /// Test add(_:), objects(_:), objectById(_:, id)
    func testAdd_Simple() {
        let myDog = Dog()
        myDog.name = "Rex"
        myDog.age = 1
        
        do {
            let id = try cblhelper?.add(myDog)
            let dog = try cblhelper?.objectById(Dog.self, id: id!)
            
            XCTAssert(myDog == dog)

        } catch {
            print(error)
        }
    }
    
    func testAdd_AllType() {
        // make test data first
        let all = AllTypeTestObject()
        all.strField = "test"
        all.intField = 0x7FFFFFFFFFFFFFFF
        all.int64Field = 0x7FFFFFFFFFFFFFFF
        //all.dateField = Date()
        all.floatField = 0.1
        all.doubleField = 0.2
        all.boolField = true
        all.nsNumberField = NSNumber(value: 1)
        all.obj = SubObject(name: "sub")
        all.objs.append(SubObject(name: "subobjs1"))
        all.objs.append(SubObject(name: "subobjs2"))

        do {
            // add item and get by id
            let id = try cblhelper?.add(all)
            let ret = try cblhelper?.objectById(AllTypeTestObject.self, id: id!)
            
            // assert
            XCTAssert(all == ret)
            
        } catch {
            print(error)
        }
    }
    
    /// Test addBatch(objects), objects(type)
    func testAddBatch() {
        let dog1 = Dog()
        dog1.name = "Rex"
        dog1.age = 1
        let dog2 = Dog()
        dog2.name = "Lucy"
        dog2.age = 2
        let dog3 = Dog()
        dog3.name = "Alex"
        dog3.age = 3
        
        do {
            let batchItems = [dog1, dog2, dog3]
            let ids = try cblhelper?.addBatch(batchItems)
            
            print(ids)
            
            // assert: check number of objects count
            XCTAssert(ids!.count == 3, NSString(format: "found ids count = %d", ids!.count) as String)
            
            for i in 0..<ids!.count {
                guard let id = ids![i]
                    else { continue }
                
                let retDog = try cblhelper?.objectById(Dog.self, id: id)
                
                // assert
                XCTAssert(retDog == batchItems[i])
            }
            
        } catch {
            print(error)
        }
    }
}

class AllTypeTestObject: DatabaseObject {
    @objc dynamic var strField: String
    @objc dynamic var intField: Int
    @objc dynamic var int64Field: Int64
    //@objc dynamic var dateField: Date?
    @objc dynamic var floatField: Float
    @objc dynamic var doubleField: Double
    @objc dynamic var boolField: Bool
    @objc dynamic var nsNumberField: NSNumber
    @objc dynamic var obj: DatabaseObject
    @objc dynamic var objs: [DatabaseObject]
    
    required init() {
        self.strField = ""
        self.intField = 0
        self.int64Field = 0
       // self.dateField = nil
        self.floatField = 0.0
        self.doubleField = 0.0
        self.boolField = false
        self.nsNumberField = NSNumber(value: 0)
        self.obj = SubObject()
        self.objs = []
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object
            else { return false }
        
        if let o = obj as? AllTypeTestObject {
            return o.strField == self.strField
                && o.intField == self.intField
                && o.int64Field == self.int64Field
            //    && o.dateField == self.dateField
                && o.floatField == self.floatField
                && o.boolField == self.boolField
                && o.nsNumberField == self.nsNumberField
                && o.obj == self.obj
                && {() -> Bool in
                    if o.objs.count != self.objs.count {
                        return false
                    }
                    
                    for i in 0..<o.objs.count {
                        if o.objs[i] != self.objs[i] {
                            return false
                        }
                    }
                    return true
                }()
        }
        return false
    }
}

class SubObject: DatabaseObject {
    @objc dynamic var name: String
    
    required init() {
        self.name = ""
    }
    
    init(name: String) {
        self.name = name
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object
            else { return false }
        
        if let o = obj as? SubObject {
            return o.name == self.name
        }
        
        return false
    }
}

class Dog: DatabaseObject {
    @objc dynamic var name: String
    @objc dynamic var age: Int
    
    required init() {
        self.name = ""
        self.age = 0
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object
            else { return false }
        
        if let o = obj as? Dog {
            return o.name == self.name
                && o.age == self.age
        }
        
        return false
    }
}
