import SwiftUI
import UIKit
import Combine

// MARK: - Log Level

enum LogLevel: String, CaseIterable {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"

    var color: Color {
        switch self {
        case .verbose: return .secondary
        case .debug: return .primary
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }

    var icon: String {
        switch self {
        case .verbose: return "text.alignleft"
        case .debug: return "ladybug"
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.octagon"
        }
    }
}

// MARK: - Log Entry

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let message: String
    let source: String

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Console Manager

@MainActor
class ConsoleManager: ObservableObject {
    static let shared = ConsoleManager()

    @Published var logs: [LogEntry] = []
    @Published var isVisible: Bool = false
    @Published var filterLevel: LogLevel?
    @Published var searchText: String = ""
    @Published var isMinimized: Bool = true
    @Published var windowPosition: CGPoint = CGPoint(x: 60, y: 100)

    private let maxLogs = 500

    func log(_ message: String, level: LogLevel = .info, source: String = "App") {
        let entry = LogEntry(timestamp: Date(), level: level, message: message, source: source)
        logs.append(entry)
        if logs.count > maxLogs {
            logs.removeFirst(logs.count - maxLogs)
        }
    }

    func clearLogs() {
        logs.removeAll()
    }

    var filteredLogs: [LogEntry] {
        var result = logs
        if let level = filterLevel {
            result = result.filter { $0.level == level }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.message.localizedCaseInsensitiveContains(searchText) ||
                $0.source.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    func exportLogs() -> String {
        filteredLogs.map { entry in
            "[\(entry.formattedTime)] [\(entry.level.rawValue)] [\(entry.source)] \(entry.message)"
        }.joined(separator: "\n")
    }

    func generateSampleLogs() {
        let sources = ["Network", "Database", "UI", "Auth", "Cache"]
        let messages: [(LogLevel, String)] = [
            (.verbose, "正在初始化模块..."),
            (.debug, "请求参数: {page: 1, size: 20}"),
            (.info, "用户登录成功"),
            (.info, "数据加载完成，共 42 条记录"),
            (.warning, "缓存即将过期，剩余 5 分钟"),
            (.warning, "网络延迟较高: 850ms"),
            (.error, "请求失败: 连接超时"),
            (.error, "JSON 解析错误: 未预期的字段"),
            (.debug, "视图已刷新"),
            (.info, "推送通知已注册"),
        ]

        for (i, (level, message)) in messages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                self.log(message, level: level, source: sources[i % sources.count])
            }
        }
    }
}

// MARK: - Floating Console Button

struct ConsoleFloatingButton: View {
    @ObservedObject var manager: ConsoleManager
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        Circle()
            .fill(Color.black.opacity(0.8))
            .frame(width: 50, height: 50)
            .overlay(
                VStack(spacing: 2) {
                    Image(systemName: "terminal")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                    if !manager.logs.isEmpty {
                        Text("\(manager.logs.count)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            )
            .shadow(radius: 4)
            .position(manager.windowPosition)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        manager.windowPosition.x += value.translation.width
                        manager.windowPosition.y += value.translation.height
                        dragOffset = .zero
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.3)) {
                    manager.isMinimized.toggle()
                }
            }
    }
}

// MARK: - Console Panel View

struct ConsolePanelView: View {
    @ObservedObject var manager: ConsoleManager
    @State private var showExportSheet = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Console")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
                Text("\(manager.filteredLogs.count) 条")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button { manager.clearLogs() } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                Button { showExportSheet = true } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                }
                Button {
                    withAnimation { manager.isMinimized = true }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.9))

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                TextField("搜索日志...", text: $manager.searchText)
                    .font(.caption)
                    .textFieldStyle(.plain)

                Menu {
                    Button("全部") { manager.filterLevel = nil }
                    ForEach(LogLevel.allCases, id: \.self) { level in
                        Button {
                            manager.filterLevel = level
                        } label: {
                            Label(level.rawValue, systemImage: level.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.caption)
                        Text(manager.filterLevel?.rawValue ?? "ALL")
                            .font(.system(size: 9))
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.darkGray).opacity(0.5))

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(manager.filteredLogs) { entry in
                            LogEntryRow(entry: entry)
                                .id(entry.id)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .onChange(of: manager.logs.count) { _, _ in
                    if let last = manager.filteredLogs.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .frame(height: 300)
        .background(Color.black.opacity(0.92))
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding()
        .sheet(isPresented: $showExportSheet) {
            ExportLogView(content: manager.exportLogs())
        }
    }
}

// MARK: - Log Entry Row

struct LogEntryRow: View {
    let entry: LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(entry.formattedTime)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.secondary)
            Image(systemName: entry.level.icon)
                .font(.system(size: 9))
                .foregroundColor(entry.level.color)
                .frame(width: 12)
            Text("[\(entry.source)]")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.cyan)
            Text(entry.message)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(entry.level.color)
                .lineLimit(3)
        }
        .padding(.vertical, 1)
    }
}

// MARK: - Export View

struct ExportLogView: View {
    let content: String
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text(content)
                        .font(.system(size: 11, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding()

                HStack(spacing: 16) {
                    Button {
                        UIPasteboard.general.string = content
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                    } label: {
                        Label(copied ? "已复制" : "复制全部", systemImage: copied ? "checkmark" : "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    ShareLink(item: content) {
                        Label("分享", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("导出日志")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
