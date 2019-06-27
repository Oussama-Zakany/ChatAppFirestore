//
//  Date+Additions.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation

extension Date {
    
    func string(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func getElapsedInterval() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .weekOfYear], from: self, to: Date())
        
        if let year = interval.year, let month = interval.month, year > 0 || month > 0 {
            return self.string(format: "d/MM/yy")
        } else if let day = interval.day, let weekOfYear = interval.weekOfYear, day > 0 || weekOfYear > 0 {
            if weekOfYear == 0 {
                if day == 1 {
                    return "Yesterday"
                }
                
                return self.string(format: "EEEE")
            }
            return self.string(format: "d/MM/yy")
        } else {
            return self.string(format: "hh:mm a")
        }
    }
}
