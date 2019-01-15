//
//  URIResolver.swift
//  PolarisFramework
//
//  Created by overtheleaves on 14/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation
import UIKit

public class URIResolver {
    
    public var defaultBaseUrl: String = ""
    var otherwiseType: URIResolvedUIViewController.Type? = nil
    var pathTrie: PathTrie = PathTrie()
    
    public func register(_ path: String, type: URIResolvedUIViewController.Type) {
        pathTrie.add(path, value: type)
    }
    
    public func otherwise(_ type: URIResolvedUIViewController.Type) {
        self.otherwiseType = type
    }
    
    public func go(_ current: URIResolvedUIViewController, path: String) throws {
        let (vc, params) = route(path)
        guard let viewContoller = vc
            else {
                return
        }
        
        viewContoller.params = params
        current.present(viewContoller, animated: true, completion: nil)
    }
    
    public func route(_ path: String) -> (URIResolvedUIViewController?, [String:Any]) {
        let (value, params) = pathTrie.get(path)
        
        guard let type = value as? URIResolvedUIViewController.Type ?? otherwiseType
            else { return (nil, params) }
        
        return (type.init(), params)
    }
}

class PathTrie {
    
    let root: TrieNode
    let pathSeparator: Character = "/"
    
    init() {
        self.root = TrieNode("", value: nil)
    }
    
    func add(_ path: String, value: Any) {
        self.root.add(path.split(separator: pathSeparator).map(String.init),
                      value: value)
    }
    
    func get(_ path: String) -> (Any?, [String:Any]) {
        var params: [String:Any] = [:]
        
        return (self.root.get(path.split(separator: pathSeparator).map(String.init),
                             params: &params)
                , params)
    }
    
    func delete(_ path: String) {
        self.root.delete(path.split(separator: pathSeparator).map(String.init))
    }
}

class TrieNode {
    var key: String
    var value: Any?
    var children: [String:TrieNode] = [:]
    var wildcardChildren: [String:TrieNode] = [:]
    var wildcard: Bool = false
    let wildcardPattern = "\\{(.*)\\}"
    
    init(_ key: String, value: Any?) {
        
        let regex = try! NSRegularExpression(pattern:wildcardPattern, options:[])
        
        if let n = regex.firstMatch(in:key, options:[],
                                    range: NSRange.init(location: 0, length: key.count)) {
            let matchRange = n.range(at: 1)
            let start = key.index(key.startIndex, offsetBy: matchRange.location)
            let end = key.index(start, offsetBy: matchRange.length)
            self.key = String(key[start..<end])
            self.wildcard = true
        } else {
            self.key = key
        }
        
        self.value = value
    }
    
    func add(_ path: [String], value: Any?) {
        if path.count == 0 {
            self.value = value
            return
        }
        
        let nextKey = path[0]
        let nextNode: TrieNode = children[nextKey] ?? wildcardChildren[nextKey] ?? TrieNode(nextKey, value: nil)
        
        if nextNode.wildcard {
            wildcardChildren[nextKey] = nextNode
        } else {
            children[nextKey] = nextNode
        }
        
        nextNode.add(path.removeFirst(), value: value)
    }
    
    func get(_ path: [String], params: inout [String:Any]) -> Any? {
        if path.count == 0 {
            return self.value
        }
        
        let nextKey = path[0]
        if children[nextKey] != nil {
            return children[nextKey]!.get(path.removeFirst(), params: &params)
        } else {
            // try wildcard
            let param: String = path[0]
            let nextPath: [String] = path.removeFirst()
            for (_, nextNode) in wildcardChildren {
                let ret = nextNode.get(nextPath, params: &params)
                if ret != nil {
                    params[nextNode.key] = param
                    return ret
                }
            }
        }
        
        return nil
    }
    
    func delete(_ path: [String]) {
        if path.count == 0 {
            self.value = nil
            return
        }
        
        let nextKey = path[0]
        guard let nextNode = children[nextKey] // cannot move anymore
            else { return }
        
        nextNode.delete(path.removeFirst())
        
        // if next node has no value and no children, then remove this node.
        if nextNode.value == nil && nextNode.children.count == 0 {
            children[nextKey] = nil
        }
    }
}

extension Array {
    func removeFirst() -> Array {
        // copy first
        var arr: [Element] = []
        for i in 0..<self.count {
            if i == 0 {
                continue // skip first
            }
            arr.append(self[i])
        }
        
        return arr
    }
}


