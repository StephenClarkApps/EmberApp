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

    // Two hours after the current time or end of day, whichever comes first
    func twoHoursAfterNowOrEndOfDay() -> Date {
        let calendar = Calendar.current
        let now = self
        var twoHoursLater = calendar.date(byAdding: .hour, value: 2, to: now) ?? now

        if !calendar.isDate(twoHoursLater, inSameDayAs: now) {
            var endOfDayComponents = calendar.dateComponents([.year, .month, .day], from: now)
            endOfDayComponents.hour = 23
            endOfDayComponents.minute = 59
            twoHoursLater = calendar.date(from: endOfDayComponents) ?? now
        }
        return twoHoursLater
    }
}
