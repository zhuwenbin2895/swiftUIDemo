import SwiftUI
import UIKit
import Combine

// MARK: - Appearance Configuration

class CalendarAppearance: ObservableObject {
    @Published var titleColor: Color = .primary
    @Published var weekdayColor: Color = .secondary
    @Published var weekendColor: Color = .red
    @Published var todayColor: Color = .blue
    @Published var selectionColor: Color = .blue
    @Published var rangeColor: Color = .blue.opacity(0.2)
    @Published var eventDotColor: Color = .red
    @Published var headerBackgroundColor: Color = .clear
    @Published var calendarBackgroundColor: Color = Color(UIColor.systemBackground)
    @Published var cellBackgroundColor: Color = .clear
    @Published var disabledColor: Color = .gray.opacity(0.3)
    @Published var lunarTextColor: Color = .secondary

    @Published var titleFont: Font = .system(size: 16)
    @Published var weekdayFont: Font = .system(size: 12, weight: .medium)
    @Published var headerFont: Font = .system(size: 18, weight: .bold)
    @Published var lunarFont: Font = .system(size: 9)

    @Published var cellCornerRadius: CGFloat = 8
    @Published var cellSize: CGFloat = 40
    @Published var rowSpacing: CGFloat = 4
    @Published var columnSpacing: CGFloat = 0

    @Published var showLunar: Bool = true
    @Published var showEventDots: Bool = true
    @Published var showHeader: Bool = true
    @Published var showWeekdayHeader: Bool = true

    @Published var weekdaySymbols: [String] = ["日", "一", "二", "三", "四", "五", "六"]

    @Published var firstWeekday: Int = 1 // 1 = Sunday, 2 = Monday

    @Published var selectionStyle: SelectionStyle = .circle

    enum SelectionStyle: String, CaseIterable {
        case circle = "圆形"
        case roundedRect = "圆角矩形"
        case underline = "下划线"
    }

    func reset() {
        titleColor = .primary
        weekdayColor = .secondary
        weekendColor = .red
        todayColor = .blue
        selectionColor = .blue
        rangeColor = .blue.opacity(0.2)
        eventDotColor = .red
        headerBackgroundColor = .clear
        calendarBackgroundColor = Color(UIColor.systemBackground)
        cellBackgroundColor = .clear
        disabledColor = .gray.opacity(0.3)
        lunarTextColor = .secondary
        titleFont = .system(size: 16)
        weekdayFont = .system(size: 12, weight: .medium)
        headerFont = .system(size: 18, weight: .bold)
        lunarFont = .system(size: 9)
        cellCornerRadius = 8
        cellSize = 40
        rowSpacing = 4
        columnSpacing = 0
        showLunar = true
        showEventDots = true
        showHeader = true
        showWeekdayHeader = true
        weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]
        firstWeekday = 1
        selectionStyle = .circle
    }
}

// MARK: - Calendar Configuration

class CalendarConfiguration: ObservableObject {
    @Published var selectionMode: CalendarSelectionMode = .single
    @Published var viewMode: CalendarViewMode = .month
    @Published var minimumDate: Date? = nil
    @Published var maximumDate: Date? = nil
    @Published var allowsSwipeToSwitchMode: Bool = true
    @Published var scrollDirection: ScrollDirection = .horizontal
    @Published var pagingEnabled: Bool = true

    enum ScrollDirection: String, CaseIterable {
        case horizontal = "水平"
        case vertical = "垂直"
    }

    func isDateEnabled(_ date: Date) -> Bool {
        if let minDate = minimumDate, date < minDate.startOfDay {
            return false
        }
        if let maxDate = maximumDate, date > maxDate.startOfDay {
            return false
        }
        return true
    }
}
