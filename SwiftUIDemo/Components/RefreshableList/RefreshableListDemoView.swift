import SwiftUI

struct RefreshableListDemoView: View {
    @State private var selectedDemo: DemoType? = nil

    enum DemoType: String, CaseIterable, Identifiable {
        case basic = "基础下拉刷新"
        case loadMore = "上拉加载更多"
        case customAnimation = "自定义刷新动画"
        case manualTrigger = "手动触发刷新"
        case disableRefresh = "禁用刷新/加载"
        case noMoreData = "无更多数据"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .basic: return "arrow.down.circle"
            case .loadMore: return "arrow.up.circle"
            case .customAnimation: return "sparkles"
            case .manualTrigger: return "hand.tap"
            case .disableRefresh: return "xmark.circle"
            case .noMoreData: return "tray"
            }
        }
    }

    var body: some View {
        List {
            Section("下拉刷新 & 上拉加载") {
                ForEach(DemoType.allCases) { demo in
                    NavigationLink {
                        destinationView(for: demo)
                    } label: {
                        Label(demo.rawValue, systemImage: demo.icon)
                    }
                }
            }
        }
        .navigationTitle("RefreshableList")
    }

    @ViewBuilder
    private func destinationView(for demo: DemoType) -> some View {
        switch demo {
        case .basic:
            BasicRefreshDemoView()
        case .loadMore:
            LoadMoreDemoView()
        case .customAnimation:
            CustomAnimationDemoView()
        case .manualTrigger:
            ManualTriggerDemoView()
        case .disableRefresh:
            DisabledRefreshDemoView()
        case .noMoreData:
            NoMoreDataDemoView()
        }
    }
}

// MARK: - Basic Refresh Demo

struct BasicRefreshDemoView: View {
    @StateObject private var manager = RefreshableListManager()
    @State private var items: [String] = (1...15).map { "项目 \($0)" }
    @State private var refreshCount = 0

    var body: some View {
        RefreshableListContainer(manager: manager) {
            LazyVStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    Divider()
                }
            }
        }
        .navigationTitle("基础下拉刷新")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.config.loadMoreEnabled = false
            manager.onRefresh = {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                refreshCount += 1
                items = (1...15).map { "刷新\(refreshCount) - 项目 \($0)" }
            }
        }
    }
}

// MARK: - Load More Demo

struct LoadMoreDemoView: View {
    @StateObject private var manager = RefreshableListManager()
    @State private var items: [String] = (1...20).map { "项目 \($0)" }
    @State private var page = 1
    private let maxPage = 5

    var body: some View {
        RefreshableListContainer(manager: manager) {
            LazyVStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    Divider()
                }
            }
        }
        .navigationTitle("上拉加载更多")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.onRefresh = {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                page = 1
                items = (1...20).map { "项目 \($0)" }
                manager.resetLoadMoreState()
            }
            manager.onLoadMore = {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                page += 1
                let start = items.count + 1
                let newItems = (start...(start + 19)).map { "项目 \($0)" }
                items.append(contentsOf: newItems)
                manager.finishLoadMore(hasMoreData: page < maxPage)
            }
        }
    }
}

// MARK: - Custom Animation Demo

struct CustomAnimationDemoView: View {
    @StateObject private var manager = RefreshableListManager()
    @State private var items: [String] = (1...15).map { "项目 \($0)" }
    @State private var selectedStyle = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("动画样式", selection: $selectedStyle) {
                Text("旋转箭头").tag(0)
                Text("系统菊花").tag(1)
                Text("自定义图标").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            RefreshableListContainer(manager: manager) {
                LazyVStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Text(item)
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        Divider()
                    }
                }
            }
        }
        .navigationTitle("自定义动画")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedStyle) { _, newValue in
            switch newValue {
            case 0:
                manager.config.animationStyle = .rotatingArrow
            case 1:
                manager.config.animationStyle = .system
            case 2:
                let customView = AnyView(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                        .symbolEffect(.bounce)
                )
                manager.config.animationStyle = .custom(customView)
            default:
                break
            }
        }
        .onAppear {
            manager.config.loadMoreEnabled = false
            manager.onRefresh = {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                items = items.shuffled()
            }
        }
    }
}

// MARK: - Manual Trigger Demo

struct ManualTriggerDemoView: View {
    @StateObject private var manager = RefreshableListManager()
    @State private var items: [String] = (1...15).map { "项目 \($0)" }
    @State private var refreshCount = 0

    var body: some View {
        RefreshableListContainer(manager: manager) {
            LazyVStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    Divider()
                }
            }
        }
        .navigationTitle("手动触发")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    manager.triggerRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            manager.config.loadMoreEnabled = false
            manager.onRefresh = {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                refreshCount += 1
                items = (1...15).map { "手动刷新\(refreshCount) - 项目 \($0)" }
            }
        }
    }
}

// MARK: - Disabled Refresh Demo

struct DisabledRefreshDemoView: View {
    @StateObject private var manager = RefreshableListManager()
    @State private var items: [String] = (1...20).map { "项目 \($0)" }
    @State private var refreshDisabled = false
    @State private var loadMoreDisabled = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Toggle("禁用下拉刷新", isOn: $refreshDisabled)
                Toggle("禁用上拉加载", isOn: $loadMoreDisabled)
            }
            .padding()
            .background(Color(.secondarySystemBackground))

            RefreshableListContainer(manager: manager) {
                LazyVStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Text(item)
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        Divider()
                    }
                }
            }
        }
        .navigationTitle("禁用刷新/加载")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: refreshDisabled) { _, newValue in
            manager.config.refreshEnabled = !newValue
        }
        .onChange(of: loadMoreDisabled) { _, newValue in
            manager.config.loadMoreEnabled = !newValue
            if newValue {
                manager.disableLoadMore()
            } else {
                manager.resetLoadMoreState()
            }
        }
        .onAppear {
            manager.onRefresh = {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                items = items.shuffled()
            }
            manager.onLoadMore = {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                let start = items.count + 1
                items.append(contentsOf: (start...(start + 9)).map { "项目 \($0)" })
                manager.finishLoadMore(hasMoreData: true)
            }
        }
    }
}

// MARK: - No More Data Demo

struct NoMoreDataDemoView: View {
    @StateObject private var manager = RefreshableListManager()
    @State private var items: [String] = (1...10).map { "项目 \($0)" }

    var body: some View {
        RefreshableListContainer(manager: manager) {
            LazyVStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    Divider()
                }
            }
        }
        .navigationTitle("无更多数据")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.onRefresh = {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                items = (1...10).map { "项目 \($0)" }
                manager.resetLoadMoreState()
            }
            manager.onLoadMore = {
                try? await Task.sleep(nanoseconds: 800_000_000)
                let start = items.count + 1
                items.append(contentsOf: (start...(start + 4)).map { "项目 \($0)" })
                manager.finishLoadMore(hasMoreData: items.count < 20)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RefreshableListDemoView()
    }
}
