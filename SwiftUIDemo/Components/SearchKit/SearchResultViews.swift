import SwiftUI

// MARK: - 搜索结果列表

struct SearchResultsListView<T: SearchableRecord, Content: View>: View {
    let hits: [SearchHit<T>]
    let totalHits: Int
    let isLoading: Bool
    let hasMore: Bool
    var onLoadMore: (() -> Void)?
    @ViewBuilder let content: (SearchHit<T>) -> Content

    var body: some View {
        if hits.isEmpty && !isLoading {
            EmptySearchStateView()
        } else {
            LazyVStack(spacing: 0) {
                HStack {
                    Text("共 \(totalHits) 个结果")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                ForEach(hits) { hit in
                    content(hit)
                    Divider()
                }

                if hasMore {
                    LoadMoreIndicator(isLoading: isLoading)
                        .onAppear {
                            onLoadMore?()
                        }
                }
            }
        }
    }
}

// MARK: - 空状态视图

struct EmptySearchStateView: View {
    var title: String = "未找到结果"
    var message: String = "尝试调整搜索关键词或筛选条件"
    var imageName: String = "magnifyingglass"

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: imageName)
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - 加载更多指示器

struct LoadMoreIndicator: View {
    let isLoading: Bool

    var body: some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                Text("加载中...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("上拉加载更多")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

// MARK: - 排序选择器

struct SortSelectorView: View {
    let options: [SortOption]
    @Binding var selectedID: String

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    selectedID = option.id
                } label: {
                    HStack {
                        Text(option.label)
                        if selectedID == option.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down")
                Text(options.first { $0.id == selectedID }?.label ?? "排序")
                    .font(.callout)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .systemGray5))
            .cornerRadius(16)
        }
    }
}

struct SortOption: Identifiable {
    let id: String
    let label: String
}

// MARK: - 联邦搜索结果区域

struct FederatedResultSection<Content: View>: View {
    let title: String
    let icon: String
    let count: Int
    var showAll: (() -> Void)?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                Text("(\(count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if let showAll = showAll {
                    Button("查看全部") {
                        showAll()
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal)

            content()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 页码指示器

struct PaginationIndicator: View {
    let currentPage: Int
    let totalPages: Int
    let totalHits: Int

    var body: some View {
        HStack {
            Text("第 \(currentPage + 1)/\(max(totalPages, 1)) 页")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text("共 \(totalHits) 条结果")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
