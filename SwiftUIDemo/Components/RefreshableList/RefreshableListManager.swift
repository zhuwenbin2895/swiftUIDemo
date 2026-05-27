import SwiftUI
import Combine

@MainActor
final class RefreshableListManager: ObservableObject {
    @Published var refreshState: RefreshState = .idle
    @Published var loadMoreState: LoadMoreState = .idle
    @Published var config = RefreshableListConfig()
    @Published var manualRefreshTrigger = false

    var onRefresh: (() async -> Void)?
    var onLoadMore: (() async -> Void)?

    private var isRefreshing: Bool {
        refreshState == .refreshing
    }

    func triggerRefresh() {
        guard config.refreshEnabled, !isRefreshing else { return }
        manualRefreshTrigger = true
    }

    func triggerLoadMore() {
        guard config.loadMoreEnabled,
              loadMoreState == .idle else { return }
        loadMoreState = .loading
        Task {
            await onLoadMore?()
        }
    }

    func finishLoadMore(hasMoreData: Bool) {
        withAnimation(.easeInOut(duration: 0.25)) {
            loadMoreState = hasMoreData ? .idle : .noMoreData
        }
    }

    func resetLoadMoreState() {
        loadMoreState = .idle
    }

    func disableLoadMore() {
        loadMoreState = .disabled
    }
}
