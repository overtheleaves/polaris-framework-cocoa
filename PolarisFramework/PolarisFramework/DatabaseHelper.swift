//
//  DatabaseWrapper.swift
//  PolarisFramework
//
//  Created by overtheleaves on 04/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//
import ObjectiveC.runtime

public class DatabaseHelper {
    
    /// database type: Couchbase
    static public let CBL: String = "cbl"
    
    /// database type: realm
    static public let REALM: String = "realm"
    
    /// prefix of the foreign keys field (meta)
    static public let FIELD_FOREIGN_KEYS_PREFIX: String = "__foreign_keys_of_"
    
    /// prefix of date field
    /// Reflection cannot capture Date type.
    /// so need to indicate the date field
    static public let FIELD_DATE_PREFIX: String = "__date_"
    
    /// name of the type field (meta)
    static public let FIELD_META_TYPE = "__type"
    
    /// name of the id field
    static public let META_ID: String = "id"
    
    /// schemas of DatabaseObject
    static internal var schemas: [String:DatabaseObject.Type] = [:]
    
    var database: Database
    
    
    /// Prepare database (build schema of DatabaseObject models)
    ///
    /// - Throws:
    ///     - `DatabaseError.prepareError`: An error when cannot get subclass list of DatabaseObject
    ///     - `DatabaseError.duplicateModelObjectName`: An error when the project has already the same name of model
    public class func prepare() throws {
        
        schemas = [:]
        
        guard let classes = Reflection.ClassGetSubclasses(in: DatabaseObject.self)
            else {
                throw DatabaseError.prepareError
        }
        
        for clazz in classes {
            if let type = clazz as? DatabaseObject.Type {
                let simpleName = String(describing: type)
                if schemas[String(simpleName)] != nil {
                    throw DatabaseError.duplicateModelObjectName(reasons: simpleName)
                }
                
                schemas[String(simpleName)] = type
            }
        }
    }
    

    /// Initialization database helper with options
    ///
    /// - Parameters:
    ///     - type: the type of the database (CBL: Couchbase)
    ///     - name: the name of the database. if it doesn't exist, then create.
    /// - Throws:
    ///     - `DatabaseError.notSupportedDatabase`: The given type cannot be supported
    init(_ type: String, name: String) throws {
        if type == DatabaseHelper.CBL {
            self.database = try CBLDatabase(name)
        } else {
            throw DatabaseError.notSupportedDatabase
        }
    }
    
    
    /// Save the object into database.
    ///
    /// - Parameters:
    ///     - object: the object
    /// - Throws:
    ///     - `DatabaseError.failAddData`: An error when fail to add document into database
    /// - Returns:
    ///     - a new string of saved document id
    public func add(_ object: DatabaseObject) throws {
        try database.add(object)
    }
    
    
    /// Save the objects into database with batch operation
    ///
    /// - Parameters:
    ///     - objects: array of the objects
    /// - Returns:
    ///     - a new string array of saved document ids
    public func addBatch(_ objects: [DatabaseObject]) throws {
        try database.addBatch(objects)
    }
    
    
    /// Delete the object.
    /// The object should be returned object by objects() functions of DatabaseHelper.
    ///
    /// - Parameters:
    ///     - object: the object
    public func delete(_ object: DatabaseObject) throws {
        try database.delete(object)
    }
    
    
    /// Delete the objects.
    /// The objects should be returned object by objects() functions of DatabaseHelper.
    ///
    /// - Parameters:
    ///     - object: the objects
    public func deleteBatch(_ objects: [DatabaseObject]) throws {
        try database.delete(objects)
    }
    
    
    /// Delete all the objects into database
    ///
    public func deleteAll() throws {
        try database.deleteAll()
    }
    
    
    /// Delete the object by unique id.
    ///
    /// - Parameters:
    ///     - id: the id of the object
    public func deleteById(_ id: String) throws {
        try database.deleteById(id)
    }
    

    /// Read all the match typed objects from the database.
    /// Returned objects are mutable. When the returned objects are modified, it can be automatically
    /// commited into database.
    ///
    /// - Parameters:
    ///     - type: the type of the object
    /// - Returns:
    ///     - result of all match typed objects
    public func objects<Element: DatabaseObject>(_ type: Element.Type) throws -> [Element] {
        return try database.objects(type)
    }
    
    
    /// Read limit count of the match typed object from the database.
    /// Returned objects are mutable. When the returned objects are modified, it can be automatically
    /// commited into database.
    ///
    /// - Parameters:
    ///     - type: the type of the object
    ///     - limit : count of returned objects
    /// - Returns:
    ///     - result of match typed objects with limited number
    public func objects<Element: DatabaseObject>(_ type: Element.Type, limit: Int) throws -> [Element] {
        return try database.objects(type, limit: limit)
    }
    
    
    /// Read object by id
    ///
    /// - Parameters:
    ///     - type: the type of the object
    ///     - id: the id
    /// - Returns:
    ///     - result of object having the id
    public func objectById<Element: DatabaseObject>(_ type: Element.Type, id: String) throws -> Element? {
        return try database.objectById(type, id: id)
    }
}


/// Database protocol
protocol Database {
    func add(_ object: DatabaseObject) throws
    func addBatch(_ objects: [DatabaseObject]) throws
    func delete(_ object: DatabaseObject) throws
    func delete(_ objects: [DatabaseObject]) throws
    func deleteAll() throws
    func deleteById(_ id: String) throws
    func objects<Element: DatabaseObject>(_ type: Element.Type) throws -> [Element]
    func objects<Element: DatabaseObject>(_ type: Element.Type, limit: Int) throws -> [Element]
    func objectById<Element: DatabaseObject>(_ type: Element.Type, id: String) throws -> Element?
}
