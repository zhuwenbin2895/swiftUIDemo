import SwiftUI

// MARK: - Calendar Cell View

struct CalendarCellView: View {
    let date: Date
    @ObservedObject var manager: CalendarDataManager
    let cellSize: CGFloat?
    let customContent: ((Date) -> AnyView)?
    let onTap: ((Date) -> Void)?
    let onEventTap: ((CalendarEvent) -> Void)?

    init(date: Date,
         manager: CalendarDataManager,
         cellSize: CGFloat? = nil,
         customContent: ((Date) -> AnyView)? = nil,
         onTap: ((Date) -> Void)? = nil,
         onEventTap: ((CalendarEvent) -> Void)? = nil) {
        self.date = date
        self.manager = manager
        self.cellSize = cellSize
        self.customContent = customContent
        self.onTap = onTap
        self.onEventTap = onEventTap
    }

    private var appearance: CalendarAppearance { manager.appearance }
    private var effectiveCellSize: CGFloat { cellSize ?? appearance.cellSize }
    private var isEnabled: Bool { manager.configuration.isDateEnabled(date) }
    private var isSelected: Bool { manager.isSelected(date) }
    private var isToday: Bool { date.isToday }
    private var isWeekend: Bool { date.isWeekend }
    private var isInRange: Bool { manager.isInRange(date) }
    private var events: [CalendarEvent] { manager.eventsForDate(date) }
    private var isCurrentMonth: Bool { date.isSameMonth(as: manager.currentMonth) }

    var body: some View {
        if let custom = customContent {
            custom(date)
                .onTapGesture { handleTap() }
        } else {
            defaultCell
        }
    }

    private var defaultCell: some View {
        VStack(spacing: 2) {
            ZStack {
                backgroundShape
                Text(manager.dayNumber(for: date))
                    .font(appearance.titleFont)
                    .foregroundColor(textColor)
            }
            .frame(width: effectiveCellSize, height: effectiveCellSize)

            if appearance.showLunar {
                Text(LunarCalendarHelper.lunarDisplayString(for: date))
                    .font(appearance.lunarFont)
                    .foregroundColor(appearance.lunarTextColor)
                    .lineLimit(1)
            }

            if appearance.showEventDots && !events.isEmpty {
                eventIndicator
            }
        }
        .opacity(isEnabled ? (isCurrentMonth ? 1.0 : 0.5) : 0.3)
        .onTapGesture { handleTap() }
    }

    @ViewBuilder
    private var backgroundShape: some View {
        if isSelected {
            switch appearance.selectionStyle {
            case .circle:
                Circle()
                    .fill(appearance.selectionColor)
                    .frame(width: effectiveCellSize - 4, height: effectiveCellSize - 4)
            case .roundedRect:
                RoundedRectangle(cornerRadius: appearance.cellCornerRadius)
                    .fill(appearance.selectionColor)
                    .frame(width: effectiveCellSize - 4, height: effectiveCellSize - 4)
            case .underline:
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(appearance.selectionColor)
                        .frame(height: 2)
                }
                .frame(width: effectiveCellSize - 8, height: effectiveCellSize - 4)
            }
        } else if isInRange {
            Rectangle()
                .fill(appearance.rangeColor)
                .frame(width: effectiveCellSize, height: effectiveCellSize - 4)
        } else if isToday {
            Circle()
                .stroke(appearance.todayColor, lineWidth: 1.5)
                .frame(width: effectiveCellSize - 4, height: effectiveCellSize - 4)
        }
    }

    private var eventIndicator: some View {
        HStack(spacing: 2) {
            ForEach(events.prefix(3)) { event in
                if let icon = event.icon {
                    Image(systemName: icon)
                        .font(.system(size: 6))
                        .foregroundColor(event.color)
                } else {
                    Circle()
                        .fill(event.color)
                        .frame(width: 5, height: 5)
                }
            }
        }
        .onTapGesture {
            if let event = events.first {
                onEventTap?(event)
            }
        }
    }

    private var textColor: Color {
        if !isEnabled { return appearance.disabledColor }
        if isSelected { return .white }
        if isToday { return appearance.todayColor }
        if isWeekend { return appearance.weekendColor }
        return appearance.titleColor
    }

    private func handleTap() {
        guard isEnabled else { return }
        manager.selectDate(date)
        onTap?(date)
    }
}

// MARK: - Weekday Header

struct CalendarWeekdayHeader: View {
    @ObservedObject var appearance: CalendarAppearance

    var body: some View {
        let symbols = orderedSymbols
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                Text(symbols[index])
                    .font(appearance.weekdayFont)
                    .foregroundColor(index == 0 || index == 6 ? appearance.weekendColor : appearance.weekdayColor)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }

    private var orderedSymbols: [String] {
        let offset = appearance.firstWeekday - 1
        let symbols = appearance.weekdaySymbols
        return Array(symbols[offset...]) + Array(symbols[..<offset])
    }
}

// MARK: - Month Header

struct CalendarMonthHeader: View {
    @ObservedObject var manager: CalendarDataManager

    var body: some View {
        HStack {
            Button(action: {
                if manager.scope == .month {
                    manager.goToPreviousMonth()
                } else {
                    manager.goToPreviousWeek()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(manager.appearance.selectionColor)
            }

            Spacer()

            Text(manager.scope == .month ? manager.monthYearString : manager.weekString)
                .font(manager.appearance.headerFont)
                .foregroundColor(manager.appearance.titleColor)

            Spacer()

            Button(action: {
                if manager.scope == .month {
                    manager.goToNextMonth()
                } else {
                    manager.goToNextWeek()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(manager.appearance.selectionColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(manager.appearance.headerBackgroundColor)
    }
}
