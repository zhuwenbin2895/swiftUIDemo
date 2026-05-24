import SwiftUI

struct ProgressHUDView: View {
    @ObservedObject var manager: ProgressHUDManager

    var body: some View {
        ZStack {
            if manager.isVisible {
                manager.config.maskColor
                    .ignoresSafeArea()
                    .onTapGesture {}

                hudContent
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
        }
        .allowsHitTesting(manager.isVisible)
        .animation(.easeInOut(duration: 0.2), value: manager.isVisible)
    }

    @ViewBuilder
    private var hudContent: some View {
        VStack(spacing: 12) {
            indicatorView
            textContent
        }
        .padding(24)
        .frame(minWidth: 100, minHeight: modeIsTextOnly ? 0 : 100)
        .background(manager.config.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: manager.config.cornerRadius))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
    }

    @ViewBuilder
    private var indicatorView: some View {
        switch manager.mode {
        case .spinner:
            stateIndicator
        case .annularProgress:
            annularProgressView(lineWidth: 8)
        case .thinRingProgress:
            annularProgressView(lineWidth: 3)
        case .horizontalProgress:
            horizontalProgressView
        case .customView(let view):
            view
        case .textOnly:
            EmptyView()
        }
    }

    @ViewBuilder
    private var stateIndicator: some View {
        switch manager.state {
        case .loading:
            ProgressView()
                .scaleEffect(1.5)
                .tint(manager.config.contentColor)
                .frame(width: 40, height: 40)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
        case .failure:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
        case .info:
            Image(systemName: "info.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
        }
    }

    private func annularProgressView(lineWidth: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(manager.config.contentColor.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: manager.progress)
                .stroke(manager.config.contentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: manager.progress)
        }
        .frame(width: 40, height: 40)
    }

    private var horizontalProgressView: some View {
        VStack {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(manager.config.contentColor.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(manager.config.contentColor)
                        .frame(width: geo.size.width * manager.progress)
                        .animation(.linear(duration: 0.1), value: manager.progress)
                }
            }
            .frame(width: 180, height: 8)
        }
    }

    @ViewBuilder
    private var textContent: some View {
        VStack(spacing: 4) {
            if let title = manager.title {
                Text(title)
                    .font(manager.config.titleFont)
                    .foregroundColor(manager.config.contentColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let subtitle = manager.subtitle {
                Text(subtitle)
                    .font(manager.config.subtitleFont)
                    .foregroundColor(manager.config.contentColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: 220)
    }

    private var modeIsTextOnly: Bool {
        if case .textOnly = manager.mode { return true }
        return false
    }
}

struct ProgressHUDModifier: ViewModifier {
    @ObservedObject var manager: ProgressHUDManager

    func body(content: Content) -> some View {
        content.overlay {
            ProgressHUDView(manager: manager)
        }
    }
}

extension View {
    func progressHUD(manager: ProgressHUDManager) -> some View {
        modifier(ProgressHUDModifier(manager: manager))
    }
}
