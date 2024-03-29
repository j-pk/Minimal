//
//  DateExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/8/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

struct DateComponentUnitFormatter {
    
    private struct DateComponentUnitFormat {
        let unit: Calendar.Component
        
        let singularUnit: String
        let pluralUnit: String
        
        let futureSingular: String
        let pastSingular: String
        
        let abbreviated: String
    }
    
    private let formats: [DateComponentUnitFormat] = [
        
        DateComponentUnitFormat(unit: .year,
                                singularUnit: "year",
                                pluralUnit: "years",
                                futureSingular: "Next year",
                                pastSingular: "Last year",
                                abbreviated: "y"),
        
        DateComponentUnitFormat(unit: .month,
                                singularUnit: "month",
                                pluralUnit: "months",
                                futureSingular: "Next month",
                                pastSingular: "Last month",
                                abbreviated: "m"),
        
        DateComponentUnitFormat(unit: .weekOfYear,
                                singularUnit: "week",
                                pluralUnit: "weeks",
                                futureSingular: "Next week",
                                pastSingular: "Last week",
                                abbreviated: "w"),
        
        DateComponentUnitFormat(unit: .day,
                                singularUnit: "day",
                                pluralUnit: "days",
                                futureSingular: "Tomorrow",
                                pastSingular: "Yesterday",
                                abbreviated: "d"),
        
        DateComponentUnitFormat(unit: .hour,
                                singularUnit: "hour",
                                pluralUnit: "hours",
                                futureSingular: "In an hour",
                                pastSingular: "An hour ago",
                                abbreviated: "h"),
        
        DateComponentUnitFormat(unit: .minute,
                                singularUnit: "minute",
                                pluralUnit: "minutes",
                                futureSingular: "In a minute",
                                pastSingular: "A minute ago",
                                abbreviated: "m"),
        
        DateComponentUnitFormat(unit: .second,
                                singularUnit: "second",
                                pluralUnit: "seconds",
                                futureSingular: "Just now",
                                pastSingular: "Just now",
                                abbreviated: "s"),
        
        ]
    
    func string(forDateComponents dateComponents: DateComponents, useNumericDates: Bool, abbreviated: Bool) -> String {
        for format in self.formats {
            let unitValue: Int
            
            switch format.unit {
            case .year:
                unitValue = dateComponents.year ?? 0
            case .month:
                unitValue = dateComponents.month ?? 0
            case .weekOfYear:
                unitValue = dateComponents.weekOfYear ?? 0
            case .day:
                unitValue = dateComponents.day ?? 0
            case .hour:
                unitValue = dateComponents.hour ?? 0
            case .minute:
                unitValue = dateComponents.minute ?? 0
            case .second:
                unitValue = dateComponents.second ?? 0
            default:
                assertionFailure("Date does not have requried components")
                return ""
            }
            
            
            
            switch unitValue {
            case 2 ..< Int.max:
                if abbreviated { return "\(unitValue)\(format.abbreviated)" }
                return "\(unitValue) \(format.pluralUnit) ago"
            case 1:
                if abbreviated { return "\(unitValue)\(format.abbreviated)" }
                return useNumericDates ? "\(unitValue) \(format.singularUnit) ago" : format.pastSingular
            case -1:
                if abbreviated { return "\(unitValue)\(format.abbreviated)" }
                return useNumericDates ? "In \(-unitValue) \(format.singularUnit)" : format.futureSingular
            case Int.min ..< -1:
                if abbreviated { return "\(unitValue)\(format.abbreviated)" }
                return "In \(-unitValue) \(format.pluralUnit)"
            default:
                break
            }
        }
        
        return "Just now"
    }
}

extension Date {
    func add(hours: Int) -> Date {
        guard let date = Calendar.current.date(byAdding: .hour, value: hours, to: self) else { return self }
        return date
    }
    
    func subtract(days: Int) -> Date {
        guard let date = Calendar.current.date(byAdding: .day, value: -days, to: self) else { return self }
        return date
    }
    
    func timeAgoSinceNow(useNumericDates: Bool = false, abbreviated: Bool = false) -> String {
        
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let components = calendar.dateComponents(unitFlags, from: self, to: now)
        
        let formatter = DateComponentUnitFormatter()
        return formatter.string(forDateComponents: components, useNumericDates: useNumericDates, abbreviated: abbreviated)
    }

}
