import SwiftUI

enum RefreshState: Equatable {
    case idle
    case pulling(progress: CGFloat)
    case willRefresh
    case refreshing
}

enum LoadMoreState: Equatable {
    case idle
    case loading
    case noMoreData
    case disabled
}

enum RefreshAnimationStyle {
    case system
    case rotatingArrow
    case custom(AnyView)
}

struct RefreshableListConfig {
    var headerHeight: CGFloat = 60
    var footerHeight: CGFloat = 50
    var pullToRefreshText: String = "下拉刷新"
    var releaseToRefreshText: String = "释放刷新"
    var refreshingText: String = "正在刷新..."
    var loadingMoreText: String = "加载中..."
    var noMoreDataText: String = "没有更多了"
    var animationStyle: RefreshAnimationStyle = .rotatingArrow
    var refreshEnabled: Bool = true
    var loadMoreEnabled: Bool = true
    var tintColor: Color = .accentColor
    var textColor: Color = .secondary
    var textFont: Font = .subheadline
}
