import SwiftUI

struct RefreshableListContainer<Content: View>: View {
    @ObservedObject var manager: RefreshableListManager
    let content: () -> Content

    @State private var scrollOffset: CGFloat = 0
    @State private var topInset: CGFloat = 0
    @State private var isInteracting = false

    private var config: RefreshableListConfig { manager.config }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: topInset)

                content()

                if config.loadMoreEnabled {
                    LoadMoreFooterView(state: manager.loadMoreState, config: config)
                }
            }
            .overlay(alignment: .top) {
                if config.refreshEnabled {
                    RefreshHeaderView(state: manager.refreshState, config: config)
                        .frame(height: config.headerHeight)
                        .offset(y: headerOffsetY)
                        .opacity(headerOpacity)
                }
            }
        }
        .onScrollGeometryChange(for: ScrollMetrics.self) { geo in
            ScrollMetrics(
                offsetY: geo.contentOffset.y,
                contentHeight: geo.contentSize.height,
                containerHeight: geo.containerSize.height
            )
        } action: { _, newValue in
            handleScrollChange(newValue)
        }
        .onScrollPhaseChange { _, newPhase in
            let wasInteracting = isInteracting
            isInteracting = (newPhase == .interacting)
            if wasInteracting && !isInteracting {
                handleRelease()
            }
        }
        .onChange(of: manager.manualRefreshTrigger) { _, triggered in
            if triggered {
                manager.manualRefreshTrigger = false
                triggerRefresh()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: topInset)
    }

    private var headerOffsetY: CGFloat {
        if manager.refreshState == .refreshing {
            return 0
        }
        return -config.headerHeight + min(scrollOffset, config.headerHeight)
    }

    private var headerOpacity: Double {
        switch manager.refreshState {
        case .refreshing:
            return 1
        case .pulling(let progress):
            return Double(min(progress, 1))
        case .willRefresh:
            return 1
        case .idle:
            return scrollOffset > 5 ? Double(min(scrollOffset / config.headerHeight, 1)) : 0
        }
    }

    private func handleScrollChange(_ metrics: ScrollMetrics) {
        let overscroll = max(0, -metrics.offsetY)
        scrollOffset = overscroll

        guard config.refreshEnabled, manager.refreshState != .refreshing else { return }

        let threshold = config.headerHeight

        if isInteracting {
            if overscroll >= threshold {
                manager.refreshState = .willRefresh
            } else if overscroll > 0 {
                manager.refreshState = .pulling(progress: overscroll / threshold)
            } else {
                if manager.refreshState != .idle {
                    manager.refreshState = .idle
                }
            }
        }

        if config.loadMoreEnabled,
           manager.loadMoreState == .idle,
           metrics.contentHeight > metrics.containerHeight {
            let distanceFromBottom = metrics.contentHeight - (metrics.offsetY + metrics.containerHeight)
            if distanceFromBottom < 50 {
                manager.triggerLoadMore()
            }
        }
    }

    private func handleRelease() {
        guard config.refreshEnabled else { return }
        if manager.refreshState == .willRefresh {
            triggerRefresh()
        }
    }

    private func triggerRefresh() {
        manager.refreshState = .refreshing
        topInset = config.headerHeight
        Task {
            await manager.onRefresh?()
            withAnimation(.easeInOut(duration: 0.3)) {
                manager.refreshState = .idle
                topInset = 0
            }
        }
    }
}

private struct ScrollMetrics: Equatable {
    let offsetY: CGFloat
    let contentHeight: CGFloat
    let containerHeight: CGFloat
}

extension View {
    func refreshableList(manager: RefreshableListManager) -> some View {
        RefreshableListContainer(manager: manager) {
            self
        }
    }
}
