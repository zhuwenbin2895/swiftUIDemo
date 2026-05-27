import SwiftUI

struct ConsoleDemoView: View {
    var body: some View {
        List {
            Section("功能演示") {
                NavigationLink("悬浮窗日志") { FloatingConsoleDemoView() }
                NavigationLink("日志过滤") { LogFilterDemoView() }
                NavigationLink("日志导出") { LogExportDemoView() }
            }
            Section("综合演示") {
                NavigationLink("完整控制台") { FullConsoleDemoView() }
            }
        }
        .navigationTitle("Console")
    }
}

// MARK: - Floating Console Demo

struct FloatingConsoleDemoView: View {
    @StateObject private var manager = ConsoleManager()

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("悬浮窗日志输出")
                    .font(.headline)
                Text("点击右下角悬浮按钮展开控制台\n可拖拽移动位置")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    Button("输出 Info 日志") {
                        manager.log("用户点击了按钮", level: .info, source: "UI")
                    }
                    .buttonStyle(.bordered)

                    Button("输出 Warning 日志") {
                        manager.log("内存使用率超过 80%", level: .warning, source: "System")
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    Button("输出 Error 日志") {
                        manager.log("网络请求失败: 超时", level: .error, source: "Network")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Button("批量生成日志") {
                        manager.generateSampleLogs()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()

            VStack {
                Spacer()
                if !manager.isMinimized {
                    ConsolePanelView(manager: manager)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            ConsoleFloatingButton(manager: manager)
        }
        .navigationTitle("悬浮窗日志")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.windowPosition = CGPoint(x: UIScreen.main.bounds.width - 40, y: 200)
        }
    }
}

// MARK: - Log Filter Demo

struct LogFilterDemoView: View {
    @StateObject private var manager = ConsoleManager()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                FilterChip(title: "全部", isSelected: manager.filterLevel == nil) {
                    manager.filterLevel = nil
                }
                ForEach(LogLevel.allCases, id: \.self) { level in
                    FilterChip(title: level.rawValue, isSelected: manager.filterLevel == level, color: level.color) {
                        manager.filterLevel = level
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索日志内容...", text: $manager.searchText)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            List {
                ForEach(manager.filteredLogs) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: entry.level.icon)
                                .font(.caption)
                                .foregroundColor(entry.level.color)
                            Text(entry.level.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(entry.level.color)
                            Text("[\(entry.source)]")
                                .font(.system(size: 10))
                                .foregroundColor(.cyan)
                            Spacer()
                            Text(entry.formattedTime)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Text(entry.message)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("日志过滤")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.generateSampleLogs()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                manager.log("额外的调试信息", level: .debug, source: "Debug")
                manager.log("网络连接恢复", level: .info, source: "Network")
                manager.log("磁盘空间不足", level: .error, source: "Storage")
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(isSelected ? color.opacity(0.2) : Color.clear)
                .foregroundColor(isSelected ? color : .secondary)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? color : Color.secondary.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
}

// MARK: - Log Export Demo

struct LogExportDemoView: View {
    @StateObject private var manager = ConsoleManager()
    @State private var showExport = false

    var body: some View {
        VStack(spacing: 20) {
            GroupBox("日志统计") {
                HStack {
                    VStack {
                        Text("\(manager.logs.count)")
                            .font(.title2.bold())
                        Text("总数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    ForEach(LogLevel.allCases, id: \.self) { level in
                        VStack {
                            Text("\(manager.logs.filter { $0.level == level }.count)")
                                .font(.subheadline.bold())
                                .foregroundColor(level.color)
                            Text(level.rawValue)
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button("生成日志") {
                    manager.generateSampleLogs()
                }
                .buttonStyle(.bordered)

                Button("导出日志") {
                    showExport = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(manager.logs.isEmpty)
            }

            if !manager.logs.isEmpty {
                List {
                    ForEach(manager.logs.suffix(20)) { entry in
                        HStack(spacing: 6) {
                            Image(systemName: entry.level.icon)
                                .font(.caption2)
                                .foregroundColor(entry.level.color)
                            Text(entry.message)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                            Text(entry.formattedTime)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle("日志导出")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExport) {
            ExportLogView(content: manager.exportLogs())
        }
    }
}

// MARK: - Full Console Demo

struct FullConsoleDemoView: View {
    @StateObject private var manager = ConsoleManager()
    @State private var autoGenerate = false
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                GroupBox("控制面板") {
                    VStack(spacing: 12) {
                        Toggle("自动生成日志", isOn: $autoGenerate)
                            .onChange(of: autoGenerate) { _, newValue in
                                if newValue {
                                    startAutoLog()
                                } else {
                                    timer?.invalidate()
                                    timer = nil
                                }
                            }

                        HStack(spacing: 8) {
                            Button("V") { manager.log("Verbose msg", level: .verbose, source: "App") }
                                .buttonStyle(.bordered).tint(.gray)
                            Button("D") { manager.log("Debug msg", level: .debug, source: "App") }
                                .buttonStyle(.bordered)
                            Button("I") { manager.log("Info msg", level: .info, source: "App") }
                                .buttonStyle(.bordered).tint(.blue)
                            Button("W") { manager.log("Warning msg", level: .warning, source: "App") }
                                .buttonStyle(.bordered).tint(.orange)
                            Button("E") { manager.log("Error msg", level: .error, source: "App") }
                                .buttonStyle(.bordered).tint(.red)
                        }

                        HStack {
                            Button("清空") { manager.clearLogs() }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            Button("批量生成") { manager.generateSampleLogs() }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)

            VStack {
                Spacer()
                if !manager.isMinimized {
                    ConsolePanelView(manager: manager)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            ConsoleFloatingButton(manager: manager)
        }
        .navigationTitle("完整控制台")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.windowPosition = CGPoint(x: UIScreen.main.bounds.width - 40, y: 180)
            manager.generateSampleLogs()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startAutoLog() {
        let sources = ["Network", "DB", "UI", "Auth", "Cache"]
        let levels: [LogLevel] = [.verbose, .debug, .info, .warning, .error]
        let messages = ["请求开始", "数据写入", "视图更新", "令牌刷新", "缓存命中", "连接断开", "解析完成"]

        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            Task { @MainActor in
                let level = levels.randomElement()!
                let source = sources.randomElement()!
                let message = messages.randomElement()!
                manager.log(message, level: level, source: source)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConsoleDemoView()
    }
}
