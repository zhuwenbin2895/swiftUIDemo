import SwiftUI

// MARK: - Enums

enum CalendarViewMode: String, CaseIterable {
    case month = "月视图"
    case week = "周视图"
}

enum CalendarSelectionMode: String, CaseIterable {
    case single = "单选"
    case multiple = "多选"
    case range = "范围选择"
}

enum CalendarScope {
    case month
    case week
}

// MARK: - Event Model

struct CalendarEvent: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let title: String
    let color: Color
    let icon: String?

    init(id: UUID = UUID(), date: Date, title: String, color: Color = .red, icon: String? = nil) {
        self.id = id
        self.date = date
        self.title = title
        self.color = color
        self.icon = icon
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Lunar Calendar

struct LunarDate {
    let year: Int
    let month: Int
    let day: Int
    let isLeapMonth: Bool
    let lunarDayString: String
    let lunarMonthString: String
    let ganZhiYear: String
    let zodiac: String
    let solarTerm: String?
}

struct LunarCalendarHelper {
    private static let chineseCalendar = Calendar(identifier: .chinese)

    private static let lunarDays = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]

    private static let lunarMonths = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "腊月"
    ]

    private static let heavenlyStems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    private static let earthlyBranches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    private static let zodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]

    static func lunarDate(from date: Date) -> LunarDate {
        let components = chineseCalendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 1
        let month = components.month ?? 1
        let day = components.day ?? 1
        let isLeapMonth = components.isLeapMonth ?? false

        let dayString = day <= lunarDays.count ? lunarDays[day - 1] : "\(day)"
        let monthString = month <= lunarMonths.count ? lunarMonths[month - 1] : "\(month)月"

        let stemIndex = (year - 1) % 10
        let branchIndex = (year - 1) % 12
        let stem = heavenlyStems[stemIndex >= 0 ? stemIndex : stemIndex + 10]
        let branch = earthlyBranches[branchIndex >= 0 ? branchIndex : branchIndex + 12]
        let zodiac = zodiacs[branchIndex >= 0 ? branchIndex : branchIndex + 12]

        let solarTerm = getSolarTerm(for: date)

        return LunarDate(
            year: year,
            month: month,
            day: day,
            isLeapMonth: isLeapMonth,
            lunarDayString: dayString,
            lunarMonthString: monthString,
            ganZhiYear: "\(stem)\(branch)",
            zodiac: zodiac,
            solarTerm: solarTerm
        )
    }

    static func lunarDisplayString(for date: Date) -> String {
        let lunar = lunarDate(from: date)
        if let term = lunar.solarTerm {
            return term
        }
        if lunar.day == 1 {
            return lunar.lunarMonthString
        }
        return lunar.lunarDayString
    }

    private static func getSolarTerm(for date: Date) -> String? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        let solarTerms: [(Int, Int, String)] = [
            (2, 4, "立春"), (2, 19, "雨水"), (3, 6, "惊蛰"), (3, 21, "春分"),
            (4, 5, "清明"), (4, 20, "谷雨"), (5, 6, "立夏"), (5, 21, "小满"),
            (6, 6, "芒种"), (6, 21, "夏至"), (7, 7, "小暑"), (7, 23, "大暑"),
            (8, 7, "立秋"), (8, 23, "处暑"), (9, 8, "白露"), (9, 23, "秋分"),
            (10, 8, "寒露"), (10, 23, "霜降"), (11, 7, "立冬"), (11, 22, "小雪"),
            (12, 7, "大雪"), (12, 22, "冬至"), (1, 6, "小寒"), (1, 20, "大寒")
        ]

        for term in solarTerms {
            if term.0 == month && term.1 == day {
                return term.2
            }
        }
        return nil
    }
}

// MARK: - Date Extension

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: other) &&
               calendar.component(.month, from: self) == calendar.component(.month, from: other)
    }

    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 1 || weekday == 7
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
