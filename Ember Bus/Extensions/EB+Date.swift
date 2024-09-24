//
//  EB+Date.swift
//  Ember Bus
//
//  Created by Stephen Clark on 19/09/2024.
//

import Foundation

extension Date {
    // Formats the date to "HH:mm" format
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    // Start of the current day
    static var startOfToday: Date {
        return Calendar.current.startOfDay(for: Date())
    }

    // End of the current day
    static var endOfToday: Date {
        let now = Date()
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
    }

}
