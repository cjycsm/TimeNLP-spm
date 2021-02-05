//
//  Date+NGFSExtension.swift
//  
//
//  Created by 陈嘉谊 on 2021/2/5.
//

import Foundation

extension Date {
    
    func ng_fs_year() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        return calendar.component(.year, from: self)
    }
    
    func ng_fs_month() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        return calendar.component(.month, from: self)
    }
    
    func ng_fs_day() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        return calendar.component(.day, from: self)
    }

    func ng_fs_weekday() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        return calendar.component(.weekday, from: self)
    }

    func ng_fs_weekOfYear() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        return calendar.component(.weekOfYear, from: self)
    }

    func ng_fs_hour() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        return calendar.component(.hour, from: self)
    }
    
    func ng_fs_minute() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        return calendar.component(.month, from: self)
    }
    
    func ng_fs_second() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        return calendar.component(.second, from: self)
    }
    
    func ng_fs_valueBy(_ index: Int) -> Int {
        switch (index) {
        case 0:
            return ng_fs_year()
        case 1:
            return ng_fs_month()
        case 2:
            return ng_fs_day()
        case 3:
            return ng_fs_hour()
        case 4:
            return ng_fs_minute()
        case 5:
            return ng_fs_second()
        default:
            return 0
        }
    }
    
    func ng_fs_dateByIgnoringTimeComponents() -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func ng_fs_firstDayOfMonth() -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = 1
        return calendar.date(from: components) ?? self
    }
    
    func ng_fs_lastDayOfMonth() -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.month = (components.month ?? 1) + 1
        components.day = 0
        return calendar.date(from: components) ?? self
    }
    
    func ng_fs_firstDayOfWeek() -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        let weekday = calendar.component(.weekday, from: self)
        var componentsToSubtract = DateComponents.ng_fs_sharedDateComponents
        componentsToSubtract.day = -(weekday - calendar.firstWeekday)
        var beginningOfWeek = calendar.date(byAdding: componentsToSubtract, to: self) ?? self
        let components = calendar.dateComponents([.year, .month, .day], from: beginningOfWeek)
        beginningOfWeek = calendar.date(from: components) ?? self
        componentsToSubtract.day = .max
        return beginningOfWeek
    }
    
    func ng_fs_middleOfWeek() -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        let weekday = calendar.component(.weekday, from: self)
        var componentsToSubtract = DateComponents.ng_fs_sharedDateComponents
        componentsToSubtract.day = -(weekday - calendar.firstWeekday) + 3
        var beginningOfWeek = calendar.date(byAdding: componentsToSubtract, to: self) ?? self
        let components = calendar.dateComponents([.year, .month, .day], from: beginningOfWeek)
        beginningOfWeek = calendar.date(from: components) ?? self
        componentsToSubtract.day = .max
        return beginningOfWeek
    }
    
    func ng_fs_tomorrow() -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = (components.month ?? 1) + 1
        return calendar.date(from: components) ?? self
    }
    
    func ng_fs_yesterday() -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = (components.month ?? 1) - 1
        return calendar.date(from: components) ?? self
    }
    
    func ng_fs_numberOfDaysInMonth() -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        let range = calendar.range(of: .day, in: .month, for: self)!
        return range.count
    }
    
    static func ng_fs_date(from string: String, format: String) -> Date {
        let formatter = DateFormatter.ng_fs_sharedDateFormatter
        formatter.dateFormat = format
        return formatter.date(from: format) ?? Date()
    }
    
    static func ng_fs_date(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.year = year
        components.month = month
        components.day = day
        let date = calendar .date(from: components) ?? Date()
        components.year = .max
        components.month = .max
        components.day = .max
        return date
    }
    
    func ng_fs_dateByAddingYears(_ years: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.year = years
        let date = calendar.date(byAdding: components, to: self) ?? self
        components.year = .max
        return date
    }
    
    func ng_fs_dateBySubtractingYears(_ years: Int) -> Date {
        ng_fs_dateByAddingYears(-years)
    }
    
    func ng_fs_dateByAddingMonths(_ months: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.month = months
        let date = calendar.date(byAdding: components, to: self) ?? self
        components.month = .max
        return date
    }
    
    func ng_fs_dateBySubtractingMonths(_ months: Int) -> Date {
        ng_fs_dateByAddingMonths(-months)
    }

    func ng_fs_dateByAddingWeeks(_ weeks: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.weekOfYear = weeks
        let date = calendar.date(byAdding: components, to: self) ?? self
        components.weekOfYear = .max
        return date
    }
    
    func ng_fs_dateBySubtractingWeeks(_ weeks: Int) -> Date {
        ng_fs_dateByAddingWeeks(-weeks)
    }
    
    func ng_fs_dateByAddingDays(_ days: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.day = days
        let date = calendar.date(byAdding: components, to: self) ?? self
        components.day = .max
        return date
    }
    
    func ng_fs_dateBySubtractingDays(_ days: Int) -> Date {
        ng_fs_dateByAddingDays(-days)
    }
    
    func ng_fs_dateByAddingHours(_ hours: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.hour = hours
        let date = calendar.date(byAdding: components, to: self) ?? self
        components.hour = .max
        return date
    }
    
    func ng_fs_dateBySubtractingHours(_ hours: Int) -> Date {
        ng_fs_dateByAddingHours(-hours)
    }
    
    func ng_fs_dateByAddingMinutes(_ minutes: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.minute = minutes
        let date = calendar.date(byAdding: components, to: self) ?? self
        components.minute = .max
        return date
    }
    
    func ng_fs_dateBySubtractingMinutes(_ minutes: Int) -> Date {
        ng_fs_dateByAddingMinutes(-minutes)
    }
    
    func ng_fs_dateByAddingSeconds(_ seconds: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.second = seconds
        let date = calendar.date(byAdding: components, to: self) ?? self
        components.second = .max
        return date
    }
    
    func ng_fs_dateBySubtractingSeconds(_ seconds: Int) -> Date {
        ng_fs_dateByAddingSeconds(-seconds)
    }
    
    func ng_fs_dateByAddingValue(_ value: Int, by index: Int) -> Date {
        switch index {
        case 0:
            return ng_fs_dateByAddingYears(value)
        case 1:
            return ng_fs_dateByAddingMonths(value)
        case 2:
            return ng_fs_dateByAddingDays(value)
        case 3:
            return ng_fs_dateByAddingHours(value)
        case 4:
            return ng_fs_dateByAddingMinutes(value)
        case 5:
            return ng_fs_dateByAddingSeconds(value)
        default:
            return self
        }
    }
    
    func ng_fs_dateBySubtractingValue(_ value: Int, by index: Int) -> Date {
        switch index {
        case 0:
            return ng_fs_dateBySubtractingYears(value)
        case 1:
            return ng_fs_dateBySubtractingMonths(value)
        case 2:
            return ng_fs_dateBySubtractingDays(value)
        case 3:
            return ng_fs_dateBySubtractingHours(value)
        case 4:
            return ng_fs_dateBySubtractingMinutes(value)
        case 5:
            return ng_fs_dateBySubtractingSeconds(value)
        default:
            return self
        }
    }
    
    func ng_fs_yearsFrom(date: Date) -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        let components = calendar.dateComponents([.year], from: date, to: self)
        return components.year ?? ng_fs_year()
    }
    
    func ng_fs_monthsFrom(date: Date) -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        let components = calendar.dateComponents([.month], from: date, to: self)
        return components.month ?? ng_fs_month()
    }

    
    func ng_fs_weeksFrom(date: Date) -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        let components = calendar.dateComponents([.weekOfYear], from: date, to: self)
        return components.weekOfYear ?? ng_fs_weekOfYear()
    }
    
    func ng_fs_daysFrom(date: Date) -> Int {
        let calendar = Calendar.ng_fs_sharedCalendar
        let components = calendar.dateComponents([.day], from: date, to: self)
        return components.day ?? ng_fs_day()
    }
    
    func ng_fs_stringWithFormat(_ format: String) -> String {
        let formatter = DateFormatter.ng_fs_sharedDateFormatter
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func ng_fs_string() -> String {
        ng_fs_stringWithFormat("yyyyMMdd")
    }
    
    func ng_fs_setYear(_ year: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.year = year
        components.month = ng_fs_month()
        components.day = ng_fs_day()
        components.hour = ng_fs_hour()
        components.minute = ng_fs_minute()
        components.second = ng_fs_second()
        let date = calendar.date(from: components) ?? self
        components.year = .max
        components.month = .max
        components.day = .max
        components.hour = .max
        components.minute = .max
        components.second = .max
        return date
    }
    
    func ng_fs_setMonth(_ month: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.year = ng_fs_year()
        components.month = month
        components.day = ng_fs_day()
        components.hour = ng_fs_hour()
        components.minute = ng_fs_minute()
        components.second = ng_fs_second()
        let date = calendar.date(from: components) ?? self
        components.year = .max
        components.month = .max
        components.day = .max
        components.hour = .max
        components.minute = .max
        components.second = .max
        return date
    }
    
    func ng_fs_setDay(_ day: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.year = ng_fs_year()
        components.month = ng_fs_month()
        components.day = day
        components.hour = ng_fs_hour()
        components.minute = ng_fs_minute()
        components.second = ng_fs_second()
        let date = calendar.date(from: components) ?? self
        components.year = .max
        components.month = .max
        components.day = .max
        components.hour = .max
        components.minute = .max
        components.second = .max
        return date
    }
    
    func ng_fs_setHour(_ hour: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.year = ng_fs_year()
        components.month = ng_fs_month()
        components.day = ng_fs_day()
        components.hour = hour
        components.minute = ng_fs_minute()
        components.second = ng_fs_second()
        let date = calendar.date(from: components) ?? self
        components.year = .max
        components.month = .max
        components.day = .max
        components.hour = .max
        components.minute = .max
        components.second = .max
        return date
    }
    
    func ng_fs_setMinute(_ minute: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.year = ng_fs_year()
        components.month = ng_fs_month()
        components.day = ng_fs_day()
        components.hour = ng_fs_hour()
        components.minute = minute
        components.second = ng_fs_second()
        let date = calendar.date(from: components) ?? self
        components.year = .max
        components.month = .max
        components.day = .max
        components.hour = .max
        components.minute = .max
        components.second = .max
        return date
    }
    
    func ng_fs_setSecond(_ second: Int) -> Date {
        let calendar = Calendar.ng_fs_sharedCalendar
        var components = DateComponents.ng_fs_sharedDateComponents
        components.year = ng_fs_year()
        components.month = ng_fs_month()
        components.day = ng_fs_day()
        components.hour = ng_fs_hour()
        components.minute = ng_fs_minute()
        components.second = second
        let date = calendar.date(from: components) ?? self
        components.year = .max
        components.month = .max
        components.day = .max
        components.hour = .max
        components.minute = .max
        components.second = .max
        return date
    }
    
    func ng_fs_isEqualToDateForMonth(_ date: Date) -> Bool {
        return ng_fs_year() == date.ng_fs_year() && ng_fs_month() == date.ng_fs_month()
    }
    
    func ng_fs_isEqualToDateForWeek(_ date: Date) -> Bool {
        return ng_fs_year() == date.ng_fs_year() && ng_fs_weekOfYear() == date.ng_fs_weekOfYear()
    }
    
    func ng_fs_isEqualToDateForDay(_ date: Date) -> Bool {
        return ng_fs_year() == date.ng_fs_year() && ng_fs_month() == date.ng_fs_month() && ng_fs_day() == date.ng_fs_day()
    }
    
    // 星座
    func ng_constellation() -> String {
        let constellationArray = ["水瓶座", "双鱼座", "牡羊座", "金牛座", "双子座", "巨蟹座", "狮子座", "处女座", "天秤座", "天蝎座", "射手座", "魔羯座"]
        let constellationEdgeDayArray = [20, 19, 21, 21, 21, 22, 23, 23, 23, 23, 22, 22]
        var month = ng_fs_month()
        let day = ng_fs_day()
        if day < constellationEdgeDayArray[month] {
            month -= 1
        }
        if month < 0 {
            month = 11
        }
        return constellationArray[month]
    }
    
    // 生肖
    func ng_zodiac() -> String {
        let zodiacArray = ["猴", "鸡", "狗", "猪", "鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊"]
        return zodiacArray[ng_fs_year() % 12]
    }
    
}

extension Calendar {
    
    static let ng_fs_sharedCalendar = Calendar.current
    
}

extension DateFormatter {
    
    static let ng_fs_sharedDateFormatter = DateFormatter()
    
}

extension DateComponents {
    
    static let ng_fs_sharedDateComponents = DateComponents()
    
}
