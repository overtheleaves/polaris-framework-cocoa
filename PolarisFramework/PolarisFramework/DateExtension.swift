//
//  DateExtension.swift
//  PolarisFramework
//
//  Created by overtheleaves on 13/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

extension Date {
    
    /// Convert iso string to Date. (ISO-8601, UTC)
    ///
    /// - Parameters:
    ///     - iso: string of date(format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
    /// - Returns:
    ///     - date of the iso string
    static func convertIsoToDate (iso: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: iso)
        return date
    }
}
