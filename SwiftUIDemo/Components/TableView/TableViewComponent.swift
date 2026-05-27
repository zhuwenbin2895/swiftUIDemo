import SwiftUI
import Combine

// MARK: - Table Configuration

struct TableViewConfig {
    var emptyTitle: String = "暂无数据"
    var emptyIcon: String = "tray"
    var emptyDescription: String = "下拉刷新试试"
    var showEmptyView: Bool = true
    var refreshEnabled: Bool = true
    var loadMoreEnabled: Bool = true
    var swipeActionsEnabled: Bool = true
}

// MARK: - Table Item Model

struct TableItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var subtitle: String
    var icon: String
    var isRead: Bool = false
    var isFavorite: Bool = false
}

// MARK: - Empty View

struct TableEmptyView: View {
    let config: TableViewConfig
    let onRefresh: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: config.emptyIcon)
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            Text(config.emptyTitle)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(config.emptyDescription)
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
            if let onRefresh = onRefresh {
                Button("刷新") {
                    onRefresh()
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Table Manager

@MainActor
class TableViewManager: ObservableObject {
    @Published var items: [TableItem] = []
    @Published var isRefreshing = false
    @Published var isLoadingMore = false
    @Published var hasMoreData = true
    @Published var config = TableViewConfig()

    private var page = 1

    func refresh() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        page = 1
        items = Self.generateItems(page: page)
        hasMoreData = true
        isRefreshing = false
    }

    func loadMore() async {
        guard !isLoadingMore, hasMoreData else { return }
        isLoadingMore = true
        try? await Task.sleep(nanoseconds: 800_000_000)
        page += 1
        let newItems = Self.generateItems(page: page)
        items.append(contentsOf: newItems)
        hasMoreData = page < 5
        isLoadingMore = false
    }

    func deleteItem(_ item: TableItem) {
        items.removeAll { $0.id == item.id }
    }

    func toggleFavorite(_ item: TableItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
        }
    }

    func markAsRead(_ item: TableItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isRead = true
        }
    }

    func clearAll() {
        items.removeAll()
    }

    static func generateItems(page: Int) -> [TableItem] {
        let icons = ["doc.text", "photo", "video", "folder", "link", "bookmark"]
        let base = (page - 1) * 10
        return (1...10).map { i in
            TableItem(
                title: "项目 \(base + i)",
                subtitle: "这是第\(page)页的第\(i)条数据描述",
                icon: icons[(base + i) % icons.count]
            )
        }
    }
}

// MARK: - Swipeable Row

struct SwipeableTableRow: View {
    let item: TableItem
    let onDelete: () -> Void
    let onFavorite: () -> Void
    let onMarkRead: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.body)
                        .foregroundColor(item.isRead ? .secondary : .primary)
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                    if !item.isRead {
                        Circle()
                            .fill(.blue)
                            .frame(width: 6, height: 6)
                    }
                }
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) { onDelete() } label: {
                Label("删除", systemImage: "trash")
            }
            Button { onFavorite() } label: {
                Label(item.isFavorite ? "取消收藏" : "收藏", systemImage: item.isFavorite ? "star.slash" : "star")
            }
            .tint(.yellow)
        }
        .swipeActions(edge: .leading) {
            Button { onMarkRead() } label: {
                Label("已读", systemImage: "envelope.open")
            }
            .tint(.green)
        }
    }
}
