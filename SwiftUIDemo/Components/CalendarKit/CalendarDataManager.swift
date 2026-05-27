import SwiftUI
import Combine

// MARK: - Calendar Data Manager

class CalendarDataManager: ObservableObject {
    @Published var currentMonth: Date
    @Published var currentWeek: Date
    @Published var selectedDates: Set<Date> = []
    @Published var rangeStart: Date? = nil
    @Published var rangeEnd: Date? = nil
    @Published var events: [Date: [CalendarEvent]] = [:]
    @Published var scope: CalendarScope = .month
    @Published var calendarHeight: CGFloat = 300

    let appearance: CalendarAppearance
    var configuration: CalendarConfiguration

    private let calendar = Calendar.current

    init(appearance: CalendarAppearance = CalendarAppearance(),
         configuration: CalendarConfiguration = CalendarConfiguration()) {
        self.appearance = appearance
        self.configuration = configuration
        let now = Date()
        self.currentMonth = now.startOfMonth
        self.currentWeek = now.startOfWeek
    }

    // MARK: - Date Calculations

    func daysInMonth(for date: Date) -> [Date?] {
        let startOfMonth = date.startOfMonth
        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? (1..<31)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offset = (firstWeekday - appearance.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        let remainder = days.count % 7
        if remainder > 0 {
            days.append(contentsOf: Array(repeating: nil as Date?, count: 7 - remainder))
        }

        return days
    }

    func daysInWeek(for date: Date) -> [Date] {
        let startOfWeek = date.startOfWeek
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }

    func weekRows(for date: Date) -> [[Date?]] {
        let days = daysInMonth(for: date)
        return stride(from: 0, to: days.count, by: 7).map { i in
            Array(days[i..<min(i+7, days.count)])
        }
    }

    func currentWeekRow() -> Int {
        let rows = weekRows(for: currentMonth)
        let today = Date()
        for (index, row) in rows.enumerated() {
            if row.contains(where: { $0?.isSameDay(as: today) == true }) {
                return index
            }
        }
        if let selected = selectedDates.first {
            for (index, row) in rows.enumerated() {
                if row.contains(where: { $0?.isSameDay(as: selected) == true }) {
                    return index
                }
            }
        }
        return 0
    }

    // MARK: - Navigation

    func goToNextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentMonth = next.startOfMonth
            }
        }
    }

    func goToPreviousMonth() {
        if let prev = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentMonth = prev.startOfMonth
            }
        }
    }

    func goToNextWeek() {
        if let next = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentWeek = next
            }
        }
    }

    func goToPreviousWeek() {
        if let prev = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentWeek = prev
            }
        }
    }

    func goToDate(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = date.startOfMonth
            currentWeek = date.startOfWeek
        }
    }

    func goToToday() {
        goToDate(Date())
    }

    // MARK: - Selection

    func selectDate(_ date: Date) {
        guard configuration.isDateEnabled(date) else { return }

        let normalizedDate = date.startOfDay

        switch configuration.selectionMode {
        case .single:
            selectedDates = [normalizedDate]
            rangeStart = nil
            rangeEnd = nil

        case .multiple:
            if selectedDates.contains(normalizedDate) {
                selectedDates.remove(normalizedDate)
            } else {
                selectedDates.insert(normalizedDate)
            }
            rangeStart = nil
            rangeEnd = nil

        case .range:
            if rangeStart == nil || rangeEnd != nil {
                rangeStart = normalizedDate
                rangeEnd = nil
                selectedDates = [normalizedDate]
            } else {
                if normalizedDate < rangeStart! {
                    rangeEnd = rangeStart
                    rangeStart = normalizedDate
                } else {
                    rangeEnd = normalizedDate
                }
                updateRangeSelection()
            }
        }
    }

    private func updateRangeSelection() {
        guard let start = rangeStart, let end = rangeEnd else { return }
        selectedDates.removeAll()
        var current = start
        while current <= end {
            selectedDates.insert(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
            if current > end { break }
        }
    }

    // MARK: - Events

    func addEvent(_ event: CalendarEvent) {
        let key = event.date.startOfDay
        if events[key] == nil {
            events[key] = []
        }
        events[key]?.append(event)
    }

    func removeEvent(_ event: CalendarEvent) {
        let key = event.date.startOfDay
        events[key]?.removeAll(where: { $0.id == event.id })
    }

    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        events[date.startOfDay] ?? []
    }

    // MARK: - Scope Toggle

    func toggleScope() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if scope == .month {
                scope = .week
                currentWeek = Date().startOfWeek
            } else {
                scope = .month
            }
        }
    }

    // MARK: - Formatting

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: currentMonth)
    }

    var weekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月 第W周"
        return formatter.string(from: currentWeek)
    }

    func dayNumber(for date: Date) -> String {
        "\(calendar.component(.day, from: date))"
    }

    // MARK: - State Checking

    func isSelected(_ date: Date) -> Bool {
        selectedDates.contains(date.startOfDay)
    }

    func isInRange(_ date: Date) -> Bool {
        guard configuration.selectionMode == .range,
              let start = rangeStart, let end = rangeEnd else { return false }
        let normalized = date.startOfDay
        return normalized >= start && normalized <= end
    }

    func isRangeStart(_ date: Date) -> Bool {
        guard let start = rangeStart else { return false }
        return date.startOfDay.isSameDay(as: start)
    }

    func isRangeEnd(_ date: Date) -> Bool {
        guard let end = rangeEnd else { return false }
        return date.startOfDay.isSameDay(as: end)
    }
}
