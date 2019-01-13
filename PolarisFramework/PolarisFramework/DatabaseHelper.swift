//
//  DatabaseWrapper.swift
//  PolarisFramework
//
//  Created by overtheleaves on 04/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//
import CouchbaseLiteSwift
import Foundation
import ObjectiveC.runtime

class DatabaseHelper {
    
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
    class func prepare() throws {
        
        schemas = [:]
        
        guard let classes = Reflection.ClassGetSubclasses(in: DatabaseObject.self)
            else {
                throw DatabaseError.prepareError
        }
        
        for clazz in classes {
            if let type = clazz as? DatabaseObject.Type {
                let fullName = Reflection.getClassName(in: type)
                let splits = fullName.split(separator: ".")
                
                guard let simpleName = splits.last
                    else {
                    continue
                }
               
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
    func add(_ object: DatabaseObject) throws {
        try database.add(object)
    }
    
    
    /// Save the objects into database with batch operation
    ///
    /// - Parameters:
    ///     - objects: array of the objects
    /// - Returns:
    ///     - a new string array of saved document ids
    func addBatch(_ objects: [DatabaseObject]) throws {
        try database.addBatch(objects)
    }
    
    
    /// Delete the object.
    /// The object should be returned object by objects() functions of DatabaseHelper.
    ///
    /// - Parameters:
    ///     - object: the object
    func delete(_ object: DatabaseObject) throws {
        try database.delete(object)
    }
    
    
    /// Delete the objects.
    /// The objects should be returned object by objects() functions of DatabaseHelper.
    ///
    /// - Parameters:
    ///     - object: the objects
    func deleteBatch(_ objects: [DatabaseObject]) throws {
        try database.delete(objects)
    }
    
    
    /// Delete all the objects into database
    ///
    func deleteAll() throws {
        try database.deleteAll()
    }
    
    
    /// Delete the object by unique id.
    ///
    /// - Parameters:
    ///     - id: the id of the object
    func deleteById(_ id: String) throws {
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
    func objects<Element: DatabaseObject>(_ type: Element.Type) throws -> [Element] {
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
    func objects<Element: DatabaseObject>(_ type: Element.Type, limit: Int) throws -> [Element] {
        return try database.objects(type, limit: limit)
    }
    
    
    /// Read object by id
    ///
    /// - Parameters:
    ///     - type: the type of the object
    ///     - id: the id
    /// - Returns:
    ///     - result of object having the id
    func objectById<Element: DatabaseObject>(_ type: Element.Type, id: String) throws -> Element? {
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

/// Couchbase database
class CBLDatabase: Database {
    
    var database: CouchbaseLiteSwift.Database
    
    
    /// Initialize Couchbase database
    ///
    /// - Parameters:
    ///     - name: the name of database
    init(_ name: String) throws {
        do {
            self.database = try CouchbaseLiteSwift.Database(name: name)
        } catch {
            throw DatabaseError.failOpenDatabase
        }
    }
    
    
    /// Save the object into database.
    /// Change the object into the MutableDocument and save document.
    ///
    /// - Parameters:
    ///     - object: the object
    /// - Throws:
    ///     - `DatabaseError.failAddData`: An error when fail to add document into database
    /// - Returns:
    ///     - mutable DatabaseObject
    func add(_ object: DatabaseObject) throws {
        
        let doc = try objectToDocument(object)
       
        do {
            try database.saveDocument(doc)
            object.id = doc.id
        } catch {
            throw DatabaseError.failAddData(reasons: error)
        }
    }
    
    
    /// Save the objects into database with batch operation
    /// Change all the objects into MutableDocuments and batch save operations.
    /// After running batch operation, collect saved document ids.
    ///
    /// - Parameters:
    ///     - objects: array of the objects
    /// - Returns:
    ///     - mutable DatabaseObjects
    func addBatch(_ objects: [DatabaseObject]) throws {
        var docs: [MutableDocument] = []

        // change object into MutableDocument
        for obj in objects {
            let doc = try objectToDocument(obj)
            docs.append(doc)
        }
        
        // run batch operation
        try database.inBatch {
            for i in 0..<docs.count {
                let doc = docs[i]
                let obj = objects[i]
                try database.saveDocument(doc)
                obj.id = doc.id
            }
        }
    }
    
    func deleteById(_ id: String) throws {
        guard let doc = database.document(withID: id)
            else { throw DatabaseError.failGetData(reasons: "Document not existed") }
        
        try database.deleteDocument(doc)
    }
    
    func delete(_ object: DatabaseObject) throws {
        guard let docId = object.id
            else { throw DatabaseError.idNotFound }
        
        try deleteById(docId)
    }
    
    func delete(_ objects: [DatabaseObject]) throws {
        
        var ids: [String] = []
        
        // collect objects' ids
        for object in objects {
            guard let id = object.id
                else { throw DatabaseError.idNotFound }
            
            ids.append(id)
        }
        
        // fetch documents
        let docs = database.documents(withIDs: ids)
        
        // delete document (batch operation)
        try database.inBatch {
            for doc in docs {
                try database.deleteDocument(doc)
            }
        }
    }

    
    /// Delete all the objects into database
    ///
    func deleteAll() throws {
        try database.delete()
    }
    
    
    /// Read all the match typed objects from the database.
    /// Returned objects are mutable. When the returned objects are modified,
    /// it can be automatically commited into database.
    /// Build query which find matched type (where __type = type).
    /// When execute the query and get the results,
    /// iterate results and find foreign objects.
    /// Before return the results of query, resolve foreign objects
    /// and push them into the each result.
    ///
    /// - Parameters:
    ///     - type: the type of the object
    /// - Returns:
    ///     - result of all match typed objects
    func objects<Element: DatabaseObject>(_ type: Element.Type) throws -> [Element] {
       
        // build query
        // select *
        // from database
        // where __type = type
        let query = QueryBuilder
            .select(SelectResult.expression(Meta.id),
                    SelectResult.all())
            .from(DataSource.database(database))
            .where(Expression.property(DatabaseHelper.FIELD_META_TYPE)
                .equalTo(Expression.string("\(type)")))
        
        var results: [Element] = []
        
        do {
            // execute query
            let queryResults = try query.execute()
           
            for result in queryResults {
                
                guard let dictObj = result.dictionary(forKey: database.name)
                    else { continue }
                
                guard let id = result.string(forKey: DatabaseHelper.META_ID)
                    else { continue }
                
                var dict = dictObj.toDictionary()
                resolveObjects(type, dict: &dict)
                
                results.append(Element.object(type, id: id, dict: dict))
            }
            
        } catch {
            throw DatabaseError.failGetData(reasons: error)
        }
        
        return results
    }
    
    
    /// Read limit count of the match typed object from the database.
    /// Returned objects are mutable. When the returned objects are modified, it can be automatically
    /// commited into database.
    /// Exactly the same operation with objects(_:)
    ///
    /// - Parameters:
    ///     - type: the type of the object
    ///     - limit : count of returned objects
    /// - Returns:
    ///     - result of match typed objects with limited number
    func objects<Element: DatabaseObject>(_ type: Element.Type, limit: Int) throws -> [Element] {
        
        // build query
        // select *
        // from database
        // where __type = type
        // count(limit)
        let query = QueryBuilder
            .select(SelectResult.expression(Meta.id),
                    SelectResult.all())
            .from(DataSource.database(database))
            .where(Expression.property(DatabaseHelper.FIELD_META_TYPE)
                .equalTo(Expression.string("\(type)")))
            .limit(Expression.int(limit))
        
        var results: [Element] = []
        
        do {
            for result in try query.execute() {
                
                guard let dictObj = result.dictionary(forKey: database.name)
                    else { continue }
                
                guard let id = result.string(forKey: DatabaseHelper.META_ID)
                    else { continue }
                
                var dict = dictObj.toDictionary()
                resolveObjects(type, dict: &dict)
                
                results.append(Element.object(type, id: id, dict: dict))
            }
        } catch {
            throw DatabaseError.failGetData(reasons: error)
        }
        
        return results
    }
    
    
    /// Read object by id
    ///
    /// - Parameters:
    ///     - type: the type of the object
    ///     - id: the id
    /// - Returns:
    ///     - result of object having the id
    func objectById<Element: DatabaseObject>(_ type: Element.Type, id: String) throws -> Element? {
        guard let doc = database.document(withID: id)
            else {
                return nil
            }
        
        var dict = doc.toDictionary()
        resolveObjects(type, dict: &dict)
        return Element.object(type, id: id, dict: dict)
    }
    
    
    /// Resolve objects
    /// Iterate the dictionary and find the key name has DatabaseHelper.FIELD_FOREIGN_KEYS_PREFIX
    /// or FIELD_DATE_PREFIX.
    /// The value of those keys are the array of documents ids of foreign objects.
    /// Fetch foreign documents and convert them into objects.
    /// After all, resolve the objects into the original field of the dictionary.
    ///
    /// - Parameters:
    ///     - type: the type of object
    ///     - dict: the dictionary which is converted from the document
    func resolveObjects<Element: DatabaseObject>(_ type: Element.Type, dict: inout Dictionary<String, Any>) {
        
        let types = Reflection.getTypesOfProperties(in: type) ?? [:]
        
        // save foreign documents into ditionary
        for fieldName in dict.keys {
            if fieldName.hasPrefix(DatabaseHelper.FIELD_FOREIGN_KEYS_PREFIX) {
                let originalFieldName = fieldName.replacingOccurrences(of: DatabaseHelper.FIELD_FOREIGN_KEYS_PREFIX,
                                                          with: "")
                var foreignInstances: [Any] = []
                
                guard let keys = dict[fieldName],
                    let docIds = keys as? [String]
                    else { continue }
                
                // get documents
                let documents = database.documents(withIDs: docIds)
                
                // document to object
                for doc in documents {
                    if let strType = doc.string(forKey: DatabaseHelper.FIELD_META_TYPE)
                        , let t = DatabaseHelper.schemas[strType] {
                        foreignInstances.append(documentToObject(t, document: doc))
                    }
                }
                
                // check if DatabaseObject property is array
                if "\(types[originalFieldName] ?? "")" == "NSArray" {
                    dict[originalFieldName] = foreignInstances
                } else {
                    // if not array, just save one of documents
                    if foreignInstances.count > 0 {
                        dict[originalFieldName] = foreignInstances[0]
                    }
                }
                
            } else if fieldName.hasPrefix(DatabaseHelper.FIELD_DATE_PREFIX) {
                let originalFieldName = fieldName.replacingOccurrences(of: DatabaseHelper.FIELD_DATE_PREFIX,
                                                          with: "")
                guard let isoDate = dict[fieldName]
                    else { continue }
                
                guard let date = Date.convertIsoToDate(iso: isoDate as! String)
                    else { continue }
                
                dict[originalFieldName] = date
            }
        }
    }
        
    
    /// Return foreign keys field name
    ///
    /// - Parameters:
    ///     - name: the name of original field name
    /// - Returns:
    ///     - the name of the foreign keys field of the original field
    private func foreignKeysFieldName(_ name: String) -> String {
        return DatabaseHelper.FIELD_FOREIGN_KEYS_PREFIX + name
    }
    
    
    /// Return date field name
    ///
    /// - Parameters:
    ///     - name: the name of original field name
    /// - Returns:
    ///     - the name of the date field of the original field
    private func dateFieldName(_ name: String) -> String {
        return DatabaseHelper.FIELD_DATE_PREFIX + name
    }
    
    
    /// Convert document to Object
    ///
    /// - Parameters:
    ///     - type: the type that try to convert
    ///     - document: the document
    /// - Returns:
    ///     - converted object
    private func documentToObject<Element: DatabaseObject>(_ type: Element.Type, document: Document) -> Element {
        return Element.object(type, id: document.id, dict: document.toDictionary())
    }
    
    
    /// Convert object to Document
    ///
    /// - Parameters:
    ///     - object: the object that try to convert
    /// - Returns:
    ///     - converted mutable document
    private func objectToDocument(_ object: DatabaseObject) throws -> MutableDocument {
        let mirror = Mirror(reflecting: object)
        let doc = MutableDocument()
        
        // meta
        doc.setString("\(type(of: object))", forKey: DatabaseHelper.FIELD_META_TYPE)
        
        for (name, value) in mirror.children {
            guard let name = name else { continue }
            
            switch value {
            case let strval as String:
                doc.setString(strval, forKey: name)
            case let intval as Int:
                doc.setInt(intval, forKey: name)
            case let int64val as Int64:
                doc.setInt64(int64val, forKey: name)
            case let dateval as Date:
                let fieldName = dateFieldName(name)
                doc.setDate(dateval, forKey: fieldName)
            case let floatval as Float:
                doc.setFloat(floatval, forKey: name)
            case let doubleval as Double:
                doc.setDouble(doubleval, forKey: name)
            case let boolval as Bool:
                doc.setBoolean(boolval, forKey: name)
            case let numval as NSNumber:
                doc.setNumber(numval, forKey: name)
            case let objval as DatabaseObject:  // x:1 relationship
                try add(objval)
                let fieldName = foreignKeysFieldName(name)
                let foreignKeysArr = doc.createArrayIfNotExisted(forKey: fieldName)
                
                foreignKeysArr.addString(objval.id)
                doc.setArray(foreignKeysArr, forKey: fieldName)
            case let arrval as [DatabaseObject]:  // x:x relationship
                try addBatch(arrval)
                let fieldName = foreignKeysFieldName(name)
                let foreignKeysArr = doc.createArrayIfNotExisted(forKey: fieldName)
                
                for obj in arrval {
                    foreignKeysArr.addString(obj.id)
                }
                
                doc.setArray(foreignKeysArr, forKey: fieldName)
            default:
                continue
            }
        }
        
        return doc
    }
    
    
    /// Convert CouchbaseLiteSwift.Result to object
    ///
    /// - Parameters:
    ///     - type: the type that try to convert
    ///     - result: the result
    /// - Returns:
    ///     - converted object
    private func resultToObject<Element: DatabaseObject>(_ type: Element.Type, result: Result) -> Element? {
       
        guard let id = result.string(forKey: DatabaseHelper.META_ID)
            else {
                return nil
        }
        
        guard let dictObj = result.dictionary(forKey: database.name)
            else {
                return Element.object(type, id: id, dict: [String: Any]())
        }
        
        let dict = dictObj.toDictionary()
        return Element.object(type, id: id, dict: dict)
    }
}

/// CouchbaseLiteSwift.MutableDocument extension
extension CouchbaseLiteSwift.MutableDocument {
    
    /// Create array if the array having the given key is not existed.
    /// If the array is already existed, then return it.
    ///
    /// - Parameters:
    ///     - forKey: the given key
    /// - Returns:
    ///     - the mutable array object
    func createArrayIfNotExisted(forKey: String) -> MutableArrayObject {
        guard let arr = self.array(forKey: forKey)
            else {
            let arr = MutableArrayObject()
            self.setArray(arr, forKey: forKey)
            return arr
        }
        
        return arr
    }
}

/// CouchbaseLiteSwift.Database extension
extension CouchbaseLiteSwift.Database {
    
    /// Fetch documents of the given ids. (run concurrently)
    ///
    /// - Parameters:
    ///     - withIDs: the array of ids
    /// - Returns:
    ///     - documents result
    func documents(withIDs: [String]) -> [Document] {
        
        let dispatchGroup = DispatchGroup()
        var documents: [Document] = []
        
        for id in withIDs {
            dispatchGroup.enter()
            DispatchQueue.global(qos: .background).async {
                if let doc = self.document(withID: id) {
                    documents.append(doc)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait(timeout: .distantFuture)
        return documents
    }
}
