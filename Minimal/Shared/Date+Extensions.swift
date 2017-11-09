//
//  Date+Extensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/8/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

extension Date {
    func add(hours: Int) -> Date {
        guard let date = Calendar.current.date(byAdding: .hour, value: hours, to: self) else { return self }
        return date
    }
}
