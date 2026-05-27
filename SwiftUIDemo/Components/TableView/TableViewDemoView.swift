import SwiftUI

struct TableViewDemoView: View {
    var body: some View {
        List {
            Section("基础功能") {
                NavigationLink("空白页自动显隐") { EmptyStateDemoView() }
                NavigationLink("下拉刷新") { TableRefreshDemoView() }
                NavigationLink("上拉加载更多") { TableLoadMoreDemoView() }
            }
            Section("交互功能") {
                NavigationLink("滑动菜单") { SwipeMenuDemoView() }
                NavigationLink("综合演示") { FullTableDemoView() }
            }
        }
        .navigationTitle("TableView")
    }
}

// MARK: - Empty State Demo

struct EmptyStateDemoView: View {
    @StateObject private var manager = TableViewManager()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("清空数据") { manager.clearAll() }
                    .buttonStyle(.bordered)
                Button("加载数据") {
                    Task { await manager.refresh() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            List {
                if manager.items.isEmpty && !manager.isRefreshing {
                    TableEmptyView(config: manager.config) {
                        Task { await manager.refresh() }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                } else {
                    ForEach(manager.items) { item in
                        HStack {
                            Image(systemName: item.icon)
                                .foregroundColor(.blue)
                            Text(item.title)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await manager.refresh()
            }
        }
        .navigationTitle("空白页自动显隐")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if manager.isRefreshing && manager.items.isEmpty {
                ProgressView()
            }
        }
    }
}

// MARK: - Refresh Demo

struct TableRefreshDemoView: View {
    @StateObject private var manager = TableViewManager()

    var body: some View {
        List {
            ForEach(manager.items) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.icon)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(item.title).font(.body)
                        Text(item.subtitle).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
        }
        .refreshable {
            await manager.refresh()
        }
        .navigationTitle("下拉刷新")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await manager.refresh()
        }
    }
}

// MARK: - Load More Demo

struct TableLoadMoreDemoView: View {
    @StateObject private var manager = TableViewManager()

    var body: some View {
        List {
            ForEach(manager.items) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.icon)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(item.title).font(.body)
                        Text(item.subtitle).font(.caption).foregroundColor(.secondary)
                    }
                }
                .onAppear {
                    if item.id == manager.items.last?.id {
                        Task { await manager.loadMore() }
                    }
                }
            }

            if manager.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if !manager.hasMoreData {
                HStack {
                    Spacer()
                    Text("— 没有更多了 —")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
            }
        }
        .refreshable {
            await manager.refresh()
        }
        .navigationTitle("上拉加载更多")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await manager.refresh()
        }
    }
}

// MARK: - Swipe Menu Demo

struct SwipeMenuDemoView: View {
    @StateObject private var manager = TableViewManager()

    var body: some View {
        List {
            Section {
                ForEach(manager.items) { item in
                    SwipeableTableRow(
                        item: item,
                        onDelete: { manager.deleteItem(item) },
                        onFavorite: { manager.toggleFavorite(item) },
                        onMarkRead: { manager.markAsRead(item) }
                    )
                }
            } header: {
                Text("左滑: 删除/收藏 | 右滑: 标记已读")
                    .font(.caption)
            }
        }
        .listStyle(.plain)
        .navigationTitle("滑动菜单")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await manager.refresh()
        }
    }
}

// MARK: - Full Table Demo

struct FullTableDemoView: View {
    @StateObject private var manager = TableViewManager()

    var body: some View {
        List {
            if manager.items.isEmpty && !manager.isRefreshing {
                TableEmptyView(config: manager.config) {
                    Task { await manager.refresh() }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            } else {
                ForEach(manager.items) { item in
                    SwipeableTableRow(
                        item: item,
                        onDelete: { manager.deleteItem(item) },
                        onFavorite: { manager.toggleFavorite(item) },
                        onMarkRead: { manager.markAsRead(item) }
                    )
                    .onAppear {
                        if item.id == manager.items.last?.id {
                            Task { await manager.loadMore() }
                        }
                    }
                }

                if manager.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                } else if !manager.hasMoreData {
                    HStack {
                        Spacer()
                        Text("— 没有更多了 —")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await manager.refresh()
        }
        .navigationTitle("综合演示")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("清空") {
                    manager.clearAll()
                }
            }
        }
        .overlay {
            if manager.isRefreshing && manager.items.isEmpty {
                ProgressView()
            }
        }
        .task {
            await manager.refresh()
        }
    }
}

#Preview {
    NavigationStack {
        TableViewDemoView()
    }
}
