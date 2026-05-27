import SwiftUI
import UIKit
import Combine

// MARK: - Main Calendar View

struct CalendarView: View {
    @ObservedObject var manager: CalendarDataManager
    var customCellContent: ((Date) -> AnyView)? = nil
    var onDateSelected: ((Date) -> Void)? = nil
    var onEventTapped: ((CalendarEvent) -> Void)? = nil
    var onHeightChanged: ((CGFloat) -> Void)? = nil

    @State private var dragOffset: CGFloat = 0
    @State private var monthOffset: Int = 0
    @GestureState private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            let adaptiveCellSize = adaptiveCellSize(for: geometry.size)
            VStack(spacing: 0) {
                if manager.appearance.showHeader {
                    CalendarMonthHeader(manager: manager)
                }

                if manager.appearance.showWeekdayHeader {
                    CalendarWeekdayHeader(appearance: manager.appearance)
                }

                calendarBody(cellSize: adaptiveCellSize)
                    .gesture(swipeGesture)
                    .gesture(verticalGesture)
            }
            .background(manager.appearance.calendarBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: calendarViewHeight)
    }

    private var calendarViewHeight: CGFloat {
        let rows = manager.scope == .month ? manager.weekRows(for: manager.currentMonth).count : 1
        let headerHeight: CGFloat = (manager.appearance.showHeader ? 44 : 0) + (manager.appearance.showWeekdayHeader ? 32 : 0)
        let cellHeight = manager.appearance.cellSize + (manager.appearance.showLunar ? 14 : 0) + (manager.appearance.showEventDots ? 10 : 0)
        return headerHeight + CGFloat(rows) * (cellHeight + manager.appearance.rowSpacing) + 8
    }

    private func adaptiveCellSize(for size: CGSize) -> CGFloat {
        let availableWidth = size.width - 8
        let maxCellWidth = availableWidth / 7 - manager.appearance.columnSpacing
        return min(manager.appearance.cellSize, maxCellWidth)
    }

    @ViewBuilder
    private func calendarBody(cellSize: CGFloat) -> some View {
        switch manager.scope {
        case .month:
            monthView(cellSize: cellSize)
        case .week:
            weekView(cellSize: cellSize)
        }
    }

    private func monthView(cellSize: CGFloat) -> some View {
        let rows = manager.weekRows(for: manager.currentMonth)
        return VStack(spacing: manager.appearance.rowSpacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: manager.appearance.columnSpacing) {
                    ForEach(0..<7, id: \.self) { colIndex in
                        if colIndex < rows[rowIndex].count,
                           let date = rows[rowIndex][colIndex] {
                            CalendarCellView(
                                date: date,
                                manager: manager,
                                cellSize: cellSize,
                                customContent: customCellContent,
                                onTap: onDateSelected,
                                onEventTap: onEventTapped
                            )
                            .frame(maxWidth: .infinity)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: cellSize + 20)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: CalendarHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(CalendarHeightKey.self) { height in
            manager.calendarHeight = height
            onHeightChanged?(height)
        }
    }

    private func weekView(cellSize: CGFloat) -> some View {
        let days = manager.daysInWeek(for: manager.currentWeek)
        return HStack(spacing: manager.appearance.columnSpacing) {
            ForEach(days, id: \.self) { date in
                CalendarCellView(
                    date: date,
                    manager: manager,
                    cellSize: cellSize,
                    customContent: customCellContent,
                    onTap: onDateSelected,
                    onEventTap: onEventTapped
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let threshold: CGFloat = 50
                if value.translation.width < -threshold {
                    if manager.scope == .month {
                        manager.goToNextMonth()
                    } else {
                        manager.goToNextWeek()
                    }
                } else if value.translation.width > threshold {
                    if manager.scope == .month {
                        manager.goToPreviousMonth()
                    } else {
                        manager.goToPreviousWeek()
                    }
                }
            }
    }

    private var verticalGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                guard manager.configuration.allowsSwipeToSwitchMode else { return }
                if value.translation.height < -50 && abs(value.translation.height) > abs(value.translation.width) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        manager.scope = .week
                        manager.currentWeek = Date().startOfWeek
                    }
                } else if value.translation.height > 50 && abs(value.translation.height) > abs(value.translation.width) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        manager.scope = .month
                    }
                }
            }
    }
}

// MARK: - Preference Key

struct CalendarHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - FPS Monitor

class FPSMonitor: ObservableObject {
    @Published var fps: Int = 0
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp
        if elapsed >= 1.0 {
            fps = frameCount
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }

    deinit {
        stop()
    }
}

struct FPSOverlay: View {
    @StateObject private var monitor = FPSMonitor()

    var body: some View {
        Text("\(monitor.fps) FPS")
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(fpsColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.7))
            .cornerRadius(6)
            .onAppear { monitor.start() }
            .onDisappear { monitor.stop() }
    }

    private var fpsColor: Color {
        if monitor.fps >= 55 { return .green }
        if monitor.fps >= 40 { return .yellow }
        return .red
    }
}
