//
//  StringExtension.swift
//  PolarisFramework
//
//  Created by overtheleaves on 04/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

extension String {
    public func substring(start: Int, end: Int) -> String? {
        if self.count < 1 {
            return nil
        }
        
        return String(self[self.index(self.startIndex, offsetBy: 1)..<self.index(self.startIndex, offsetBy: 2)])
    }    
}
