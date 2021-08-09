//
//  DateUtils.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/08/09.
//

import UIKit

class DateUtils {
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    class func calcHowManyhours(date: Date) -> Int! {
        let cal = Calendar(identifier: .gregorian)
        // 現在日時を dt に代入
        let dt1 = Date()
        
        let diff = cal.dateComponents([.hour], from: date, to: dt1)
        return diff.hour
    }

    class func calcHowManyDate(date: Date) -> Int! {
        let cal = Calendar(identifier: .gregorian)
        // 現在日時を dt に代入
        let dt1 = Date()
        
        let diff = cal.dateComponents([.day], from: date, to: dt1)
        return diff.day
    }
}
