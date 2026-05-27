import SwiftUI

struct RefreshHeaderView: View {
    let state: RefreshState
    let config: RefreshableListConfig

    var body: some View {
        HStack(spacing: 12) {
            animationView
            Text(statusText)
                .font(config.textFont)
                .foregroundStyle(config.textColor)
        }
        .frame(height: config.headerHeight)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var animationView: some View {
        switch config.animationStyle {
        case .system:
            systemAnimation
        case .rotatingArrow:
            arrowAnimation
        case .custom(let view):
            if state == .refreshing {
                ProgressView()
                    .tint(config.tintColor)
            } else {
                view
            }
        }
    }

    @ViewBuilder
    private var systemAnimation: some View {
        switch state {
        case .idle, .pulling:
            Image(systemName: "arrow.down")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(config.tintColor)
        case .willRefresh:
            Image(systemName: "arrow.down")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(config.tintColor)
                .rotationEffect(.degrees(180))
        case .refreshing:
            ProgressView()
                .tint(config.tintColor)
        }
    }

    @ViewBuilder
    private var arrowAnimation: some View {
        switch state {
        case .idle:
            Image(systemName: "arrow.down")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(config.tintColor)
        case .pulling(let progress):
            Image(systemName: "arrow.down")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(config.tintColor)
                .rotationEffect(.degrees(Double(min(progress, 1.0)) * 180))
        case .willRefresh:
            Image(systemName: "arrow.up")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(config.tintColor)
        case .refreshing:
            RotatingIconView(tintColor: config.tintColor)
        }
    }

    private var statusText: String {
        switch state {
        case .idle, .pulling:
            return config.pullToRefreshText
        case .willRefresh:
            return config.releaseToRefreshText
        case .refreshing:
            return config.refreshingText
        }
    }
}

struct RotatingIconView: View {
    let tintColor: Color
    @State private var isRotating = false

    var body: some View {
        Image(systemName: "arrow.trianglehead.2.clockwise")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(tintColor)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRotating)
            .onAppear { isRotating = true }
    }
}

struct LoadMoreFooterView: View {
    let state: LoadMoreState
    let config: RefreshableListConfig

    var body: some View {
        Group {
            switch state {
            case .idle, .disabled:
                EmptyView()
            case .loading:
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(config.tintColor)
                    Text(config.loadingMoreText)
                        .font(config.textFont)
                        .foregroundStyle(config.textColor)
                }
                .frame(height: config.footerHeight)
                .frame(maxWidth: .infinity)
            case .noMoreData:
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(config.textColor.opacity(0.3))
                        .frame(width: 30, height: 0.5)
                    Text(config.noMoreDataText)
                        .font(config.textFont)
                        .foregroundStyle(config.textColor)
                    Rectangle()
                        .fill(config.textColor.opacity(0.3))
                        .frame(width: 30, height: 0.5)
                }
                .frame(height: config.footerHeight)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
