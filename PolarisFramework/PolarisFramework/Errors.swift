//
//  Errors.swift
//  PolarisFramework
//
//  Created by overtheleaves on 04/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

enum DatabaseError: Error, CustomStringConvertible {
    
    case prepareError 
    case notSupportedDatabase
    case duplicateModelObjectName(reasons: Any...)
    case failOpenDatabase
    case failAddData(reasons: Any...)
    case failGetData(reasons: Any...)
    
    var description: String {
        switch self {
        case .prepareError:
            return "Error occurs when prepare Database"
        case .notSupportedDatabase:
            return "Not supported database"
        case let .duplicateModelObjectName(reasons):
            return "Project already has the same name of model object: " + stringReasons(reasons)
        case .failOpenDatabase:
            return "Error occurs when open database"
        case let .failAddData(reasons):
            return "Error occurs when add data: " + stringReasons(reasons)
        case let .failGetData(reasons):
            return "Error occurs when get data: " + stringReasons(reasons)
        }
    }
    
    func stringReasons(_ reasons: Any...) -> String {
        var strReason = ""
        
        for reason in reasons {
            switch reason {
            case let str as String:
                strReason += "\n" + str
            case let convertible as CustomStringConvertible:
                strReason += "\n" + convertible.description
            default:
                continue
            }
        }
        
        return strReason
    }

}


