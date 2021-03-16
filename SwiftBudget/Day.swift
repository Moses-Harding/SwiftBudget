//
//  Day.swift
//  SwiftBudget
//
//  Created by Moses Harding on 10/27/20.
//

import Foundation

class Day {
    
    var date: Date!
    var day: Int!
    var month: Int!
    var year: Int!
    var dayOfWeek: Int!
    
    init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
        
        getDateFromInts()
        getDayOfWeek()
    }
    
    init(date: Date = Date()) {
        self.date = date
        
        getIntsFromDate()
        getDayOfWeek()
    }
    
    init(from string: String) {
        let split = string.split(separator: "/")
        
        self.day = Int(split[1])
        self.month = Int(split[0])
        self.year = Int(split[2])
        
        getDateFromInts()
        getDayOfWeek()
    }
    
    func getDateFromInts() {
        let components = DateComponents(calendar: Calendar.current, year: year, month: month, day: day)
        date = components.date
    }
    
    func getIntsFromDate() {
        let calendar = Calendar.current
        day = calendar.component(.day, from: date)
        month = calendar.component(.month, from: date)
        year = calendar.component(.year, from: date)
    }
    
    func getDayOfWeek() {
        dayOfWeek = Calendar.current.component(.weekday, from:  date)
    }
    
    func lastDayOfMonth() -> Int {
        guard let lastDay = self.date.getEnd(of: .month) else { return 31 }
        let number = Calendar.current.component(.day, from: lastDay)
        return number
    }
    
    func lessThan(_ dateString: String) -> Bool {
        let dateParts = dateString.split(separator: "-")
        let (y, m, d) = (Int(dateParts[0])!, Int(dateParts[1])!, Int(dateParts[2])!)
        
        if year < y {
            return true
        } else if year == y && month < m {
            return true
        } else if year == y && month == m && day < d {
            return true
        } else {
            return false
        }
    }
    
    func greaterThan(_ dateString: String) -> Bool {
        let dateParts = dateString.split(separator: "-")
        let (y, m, d) = (Int(dateParts[0])!, Int(dateParts[1])!, Int(dateParts[2])!)
        
        if year > y {
            return true
        } else if year == y && month > m {
            return true
        } else if year == y && month == m && day > d {
            return true
        } else {
            return false
        }
    }
    
    func equalTo(_ dateString: String) -> Bool {
        let dateParts = dateString.split(separator: "-")
        let (y, m, d) = (dateParts[0], dateParts[1], dateParts[2])
        if year == Int(y)! && month == Int(m)! && day == Int(d)! {
            return true
        } else {
            return false
        }
    }
}

extension Day: Equatable {
    
    static func == (l: Day, r: Day) -> Bool {
        return
            l.day == r.day && l.month == r.month && l.year == r.year
    }
}

extension Day: Comparable {
    
    static func < (l: Day, r: Day) -> Bool {
        if l.year != r.year {
            return l.year < r.year
        } else if l.month != r.month {
            return l.month < r.month
        } else {
            return l.day < r.day
        }
    }
    
    static func > (l: Day, r: Day) -> Bool {
        if l.year != r.year {
            return l.year > r.year
        } else if l.month != r.month {
            return l.month > r.month
        } else {
            return l.day > r.day
        }
    }
    
    static func <= (lhs: Day, rhs: Day) -> Bool {
        if lhs < rhs || lhs == rhs {
            return true
        } else {
            return false
        }
    }
    
    static func >= (lhs: Day, rhs: Day) -> Bool {
        if lhs > rhs || lhs == rhs {
            return true
        } else {
            return false
        }
    }
}

extension Day: CustomStringConvertible {
    var description: String {
        return "\(String(self.month!))/\(String(self.day!))/\(String(self.year!))"
    }
    
    var formatted: String {
        return "\(String(self.month!)).\(String(self.day!)).\(String(self.year!))"
    }
}

extension Date {
    
    func getStart(of component: Calendar.Component, calendar: Calendar = Calendar.current) -> Date? {
        return calendar.dateInterval(of: component, for: self)?.start
    }
    
    func getEnd(of component: Calendar.Component, calendar: Calendar = Calendar.current) -> Date? {
        return calendar.dateInterval(of: component, for: self)!.end - 1
    }
}
