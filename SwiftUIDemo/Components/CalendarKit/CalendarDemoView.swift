import SwiftUI
import UIKit

// MARK: - Calendar Demo Entry View

struct CalendarDemoView: View {
    var body: some View {
        List {
            Section("视图模式") {
                NavigationLink("月视图 / 周视图切换") {
                    CalendarViewModeDemo()
                }
                NavigationLink("手势切换视图模式") {
                    CalendarGestureSwitchDemo()
                }
                NavigationLink("滚动切换月份") {
                    CalendarScrollDemo()
                }
            }

            Section("日期选择") {
                NavigationLink("单选模式") {
                    CalendarSelectionDemo(mode: .single)
                }
                NavigationLink("多选模式") {
                    CalendarSelectionDemo(mode: .multiple)
                }
                NavigationLink("范围选择模式") {
                    CalendarSelectionDemo(mode: .range)
                }
            }

            Section("自定义单元格") {
                NavigationLink("自定义 Cell 内容") {
                    CalendarCustomCellDemo()
                }
            }

            Section("事件标记") {
                NavigationLink("事件指示器") {
                    CalendarEventDemo()
                }
            }

            Section("外观定制") {
                NavigationLink("实时外观自定义") {
                    CalendarAppearanceDemo()
                }
            }

            Section("布局适配") {
                NavigationLink("动态高度 & 横竖屏") {
                    CalendarLayoutDemo()
                }
            }

            Section("日历计算") {
                NavigationLink("农历 & 节气") {
                    CalendarLunarDemo()
                }
                NavigationLink("日期限制 & 跳转") {
                    CalendarNavigationDemo()
                }
            }

            Section("性能优化") {
                NavigationLink("FPS 监控 & 流畅度") {
                    CalendarPerformanceDemo()
                }
            }
        }
        .navigationTitle("CalendarKit")
    }
}

// MARK: - View Mode Demo

struct CalendarViewModeDemo: View {
    @StateObject private var manager = CalendarDataManager()
    @State private var selectedMode: CalendarScope = .month

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("视图模式", selection: $selectedMode) {
                    Text("月视图").tag(CalendarScope.month)
                    Text("周视图").tag(CalendarScope.week)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedMode) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        manager.scope = newValue
                    }
                }

                CalendarView(manager: manager)
                    .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("视图模式")
    }
}

// MARK: - Gesture Switch Demo

struct CalendarGestureSwitchDemo: View {
    @StateObject private var manager = CalendarDataManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("上滑切换周视图，下滑切换月视图")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)

                Text("当前: \(manager.scope == .month ? "月视图" : "周视图")")
                    .font(.headline)

                CalendarView(manager: manager)
                    .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("手势切换")
    }
}

// MARK: - Scroll Demo

struct CalendarScrollDemo: View {
    @StateObject private var manager = CalendarDataManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("左右滑动切换月份")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)

                CalendarView(manager: manager)
                    .padding(.horizontal)

                HStack(spacing: 20) {
                    Button("上月") { manager.goToPreviousMonth() }
                        .buttonStyle(.bordered)
                    Button("今天") { manager.goToToday() }
                        .buttonStyle(.borderedProminent)
                    Button("下月") { manager.goToNextMonth() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("滚动切换")
    }
}

// MARK: - Selection Demo

struct CalendarSelectionDemo: View {
    let mode: CalendarSelectionMode
    @StateObject private var manager = CalendarDataManager()
    @State private var selectionInfo: String = "点击日期进行选择"

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CalendarView(
                    manager: manager,
                    onDateSelected: { date in
                        updateSelectionInfo()
                    }
                )
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("选择信息")
                        .font(.headline)
                    Text(selectionInfo)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle(mode.rawValue)
        .onAppear {
            manager.configuration.selectionMode = mode
        }
    }

    private func updateSelectionInfo() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        switch mode {
        case .single:
            if let date = manager.selectedDates.first {
                selectionInfo = "已选择: \(formatter.string(from: date))"
            }
        case .multiple:
            let dates = manager.selectedDates.sorted().map { formatter.string(from: $0) }
            selectionInfo = "已选择 \(dates.count) 个日期:\n\(dates.joined(separator: "\n"))"
        case .range:
            if let start = manager.rangeStart {
                if let end = manager.rangeEnd {
                    selectionInfo = "范围: \(formatter.string(from: start)) ~ \(formatter.string(from: end))\n共 \(manager.selectedDates.count) 天"
                } else {
                    selectionInfo = "起始: \(formatter.string(from: start))\n请选择结束日期"
                }
            }
        }
    }
}

// MARK: - Custom Cell Demo

struct CalendarCustomCellDemo: View {
    @StateObject private var manager = CalendarDataManager()
    @State private var cellStyle: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("Cell 样式", selection: $cellStyle) {
                    Text("默认").tag(0)
                    Text("带图标").tag(1)
                    Text("进度条").tag(2)
                    Text("头像").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                CalendarView(
                    manager: manager,
                    customCellContent: cellStyle == 0 ? nil : { date in
                        AnyView(customCell(for: date))
                    }
                )
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("自定义 Cell")
    }

    @ViewBuilder
    private func customCell(for date: Date) -> some View {
        let dayNumber = Calendar.current.component(.day, from: date)
        switch cellStyle {
        case 1:
            VStack(spacing: 2) {
                ZStack {
                    if manager.isSelected(date) {
                        Circle().fill(Color.blue)
                            .frame(width: 36, height: 36)
                    }
                    VStack(spacing: 0) {
                        Text("\(dayNumber)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(manager.isSelected(date) ? .white : .primary)
                        if dayNumber % 5 == 0 {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .frame(width: 40, height: 40)
            }
            .onTapGesture { manager.selectDate(date) }
        case 2:
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.system(size: 14))
                    .foregroundColor(manager.isSelected(date) ? .blue : .primary)
                let progress = Double(dayNumber) / 31.0
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green.opacity(0.3))
                        .frame(width: geo.size.width * progress, height: 4)
                }
                .frame(height: 4)
            }
            .frame(width: 40, height: 44)
            .onTapGesture { manager.selectDate(date) }
        case 3:
            VStack(spacing: 2) {
                ZStack {
                    if dayNumber % 7 == 0 {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.purple)
                    } else {
                        if manager.isSelected(date) {
                            Circle().fill(Color.blue)
                                .frame(width: 36, height: 36)
                        }
                        Text("\(dayNumber)")
                            .font(.system(size: 14))
                            .foregroundColor(manager.isSelected(date) ? .white : .primary)
                    }
                }
                .frame(width: 40, height: 40)
            }
            .onTapGesture { manager.selectDate(date) }
        default:
            EmptyView()
        }
    }
}

// MARK: - Event Demo

struct CalendarEventDemo: View {
    @StateObject private var manager = CalendarDataManager()
    @State private var tappedEvent: CalendarEvent? = nil
    @State private var showEventAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CalendarView(
                    manager: manager,
                    onEventTapped: { event in
                        tappedEvent = event
                        showEventAlert = true
                    }
                )
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("事件列表")
                        .font(.headline)
                    Text("红点: 会议 | 蓝点: 任务 | 图标: 特殊事件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("点击日期下方的事件指示器查看详情")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("事件标记")
        .onAppear { setupEvents() }
        .alert("事件详情", isPresented: $showEventAlert) {
            Button("确定") {}
        } message: {
            if let event = tappedEvent {
                Text("\(event.title)\n日期: \(formatDate(event.date))")
            }
        }
    }

    private func setupEvents() {
        let calendar = Calendar.current
        let today = Date()

        for offset in [0, 2, 5, 7, 10, 14, 18, 21, 25] {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                let event = CalendarEvent(
                    date: date,
                    title: offset % 3 == 0 ? "团队会议" : "项目任务",
                    color: offset % 3 == 0 ? .red : .blue,
                    icon: offset % 7 == 0 ? "star.fill" : nil
                )
                manager.addEvent(event)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Appearance Demo

struct CalendarAppearanceDemo: View {
    @StateObject private var appearance = CalendarAppearance()
    @StateObject private var configuration = CalendarConfiguration()
    @State private var manager: CalendarDataManager?

    var body: some View {
        VStack(spacing: 0) {
            if let mgr = manager {
                CalendarView(manager: mgr)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }

            Divider().padding(.vertical, 8)

            ScrollView {
                VStack(spacing: 16) {
                    appearanceSection("颜色设置") {
                        colorRow("文字颜色", binding: $appearance.titleColor)
                        colorRow("今日颜色", binding: $appearance.todayColor)
                        colorRow("选中颜色", binding: $appearance.selectionColor)
                        colorRow("周末颜色", binding: $appearance.weekendColor)
                        colorRow("事件颜色", binding: $appearance.eventDotColor)
                        colorRow("农历颜色", binding: $appearance.lunarTextColor)
                    }

                    appearanceSection("选中样式") {
                        Picker("样式", selection: $appearance.selectionStyle) {
                            ForEach(CalendarAppearance.SelectionStyle.allCases, id: \.self) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    appearanceSection("布局参数") {
                        HStack {
                            Text("Cell 大小")
                            Slider(value: $appearance.cellSize, in: 30...60, step: 2)
                            Text("\(Int(appearance.cellSize))")
                                .frame(width: 30)
                        }
                        HStack {
                            Text("圆角")
                            Slider(value: $appearance.cellCornerRadius, in: 0...20, step: 1)
                            Text("\(Int(appearance.cellCornerRadius))")
                                .frame(width: 30)
                        }
                        HStack {
                            Text("行间距")
                            Slider(value: $appearance.rowSpacing, in: 0...16, step: 1)
                            Text("\(Int(appearance.rowSpacing))")
                                .frame(width: 30)
                        }
                    }

                    appearanceSection("显示设置") {
                        Toggle("显示农历", isOn: $appearance.showLunar)
                        Toggle("显示事件圆点", isOn: $appearance.showEventDots)
                        Toggle("显示头部", isOn: $appearance.showHeader)
                        Toggle("显示星期", isOn: $appearance.showWeekdayHeader)
                    }

                    Button("重置外观") {
                        appearance.reset()
                    }
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("外观定制")
        .onAppear {
            if manager == nil {
                let mgr = CalendarDataManager(appearance: appearance, configuration: configuration)
                setupSampleEvents(for: mgr)
                manager = mgr
            }
        }
    }

    private func appearanceSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    private func colorRow(_ label: String, binding: Binding<Color>) -> some View {
        HStack {
            Text(label)
            Spacer()
            ColorPicker("", selection: binding)
                .labelsHidden()
        }
    }

    private func setupSampleEvents(for mgr: CalendarDataManager) {
        let calendar = Calendar.current
        let today = Date()
        for i in stride(from: 0, to: 30, by: 3) {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                mgr.addEvent(CalendarEvent(date: date, title: "事件\(i)", color: .red))
            }
        }
    }
}

// MARK: - Layout Demo

struct CalendarLayoutDemo: View {
    @StateObject private var manager = CalendarDataManager()
    @State private var calendarHeight: CGFloat = 300
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ScrollView {
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Text("宽: \(Int(geometry.size.width))pt")
                        Text("高: \(Int(geometry.size.height))pt")
                        Text("日历高度: \(Int(calendarHeight))pt")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    if isLandscape {
                        HStack(alignment: .top, spacing: 16) {
                            CalendarView(
                                manager: manager,
                                onHeightChanged: { height in
                                    calendarHeight = height
                                }
                            )
                            .frame(maxWidth: geometry.size.width * 0.6)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("横屏布局")
                                    .font(.headline)
                                Text("日历自适应宽度，右侧可放置详情内容")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("当前模式: 横屏")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Cell 自动缩放适配可用空间")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else {
                        CalendarView(
                            manager: manager,
                            onHeightChanged: { height in
                                calendarHeight = height
                            }
                        )
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("竖屏布局")
                                .font(.headline)
                            Text("旋转设备查看横屏自适应效果")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("布局适配")
    }
}

// MARK: - Lunar Demo

struct CalendarLunarDemo: View {
    @StateObject private var manager = CalendarDataManager()
    @State private var selectedLunarInfo: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CalendarView(
                    manager: manager,
                    onDateSelected: { date in
                        let lunar = LunarCalendarHelper.lunarDate(from: date)
                        selectedLunarInfo = """
                        农历: \(lunar.lunarMonthString)\(lunar.lunarDayString)
                        干支: \(lunar.ganZhiYear)年
                        生肖: \(lunar.zodiac)
                        节气: \(lunar.solarTerm ?? "无")
                        """
                    }
                )
                .padding(.horizontal)

                if !selectedLunarInfo.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("农历信息")
                            .font(.headline)
                        Text(selectedLunarInfo)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("农历 & 节气")
        .onAppear {
            manager.appearance.showLunar = true
        }
    }
}

// MARK: - Navigation Demo

struct CalendarNavigationDemo: View {
    @StateObject private var manager = CalendarDataManager()
    @State private var targetYear: Int = 2026
    @State private var targetMonth: Int = 1
    @State private var targetDay: Int = 1
    @State private var useMinDate: Bool = false
    @State private var useMaxDate: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CalendarView(manager: manager)
                    .padding(.horizontal)

                GroupBox("日期跳转") {
                    VStack(spacing: 8) {
                        HStack {
                            Stepper("年: \(targetYear)", value: $targetYear, in: 2000...2100)
                        }
                        HStack {
                            Stepper("月: \(targetMonth)", value: $targetMonth, in: 1...12)
                        }
                        HStack {
                            Stepper("日: \(targetDay)", value: $targetDay, in: 1...31)
                        }
                        Button("跳转") {
                            var components = DateComponents()
                            components.year = targetYear
                            components.month = targetMonth
                            components.day = targetDay
                            if let date = Calendar.current.date(from: components) {
                                manager.goToDate(date)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)

                GroupBox("日期范围限制") {
                    VStack(spacing: 8) {
                        Toggle("启用最小日期 (今天)", isOn: $useMinDate)
                            .onChange(of: useMinDate) { _, newValue in
                                manager.configuration.minimumDate = newValue ? Date() : nil
                            }
                        Toggle("启用最大日期 (30天后)", isOn: $useMaxDate)
                            .onChange(of: useMaxDate) { _, newValue in
                                manager.configuration.maximumDate = newValue ?
                                    Calendar.current.date(byAdding: .day, value: 30, to: Date()) : nil
                            }
                        Text("限制范围外的日期将不可选择")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .navigationTitle("日期限制 & 跳转")
    }
}

// MARK: - Performance Demo

struct CalendarPerformanceDemo: View {
    @StateObject private var manager = CalendarDataManager()
    @State private var showFPS = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    Toggle("显示 FPS", isOn: $showFPS)
                        .padding(.horizontal)

                    Text("快速滑动日历测试流畅度")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    CalendarView(manager: manager)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("性能说明")
                            .font(.headline)
                        Text("• 使用 LazyVStack/LazyHStack 优化渲染")
                            .font(.caption)
                        Text("• 单元格复用机制减少内存分配")
                            .font(.caption)
                        Text("• 日期计算缓存避免重复计算")
                            .font(.caption)
                        Text("• ForEach + id 优化 diff 算法")
                            .font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
            }

            if showFPS {
                FPSOverlay()
                    .padding(.trailing, 16)
                    .padding(.top, 8)
            }
        }
        .navigationTitle("性能监控")
        .onAppear { setupManyEvents() }
    }

    private func setupManyEvents() {
        let calendar = Calendar.current
        let today = Date()
        for i in 0..<60 {
            if let date = calendar.date(byAdding: .day, value: i - 30, to: today) {
                let event = CalendarEvent(
                    date: date,
                    title: "事件\(i)",
                    color: [Color.red, .blue, .green, .orange, .purple][i % 5]
                )
                manager.addEvent(event)
            }
        }
    }
}
