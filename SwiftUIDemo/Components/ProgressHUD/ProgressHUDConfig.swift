import SwiftUI

enum HUDMode {
    case spinner
    case annularProgress
    case thinRingProgress
    case horizontalProgress
    case customView(AnyView)
    case textOnly
}

enum HUDState {
    case loading
    case success
    case failure
    case info
}

@MainActor
struct HUDConfig {
    var backgroundColor: Color = .black.opacity(0.8)
    var contentColor: Color = .white
    var cornerRadius: CGFloat = 14
    var titleFont: Font = .system(size: 16, weight: .semibold)
    var subtitleFont: Font = .system(size: 14)
    var maskColor: Color = Color.black.opacity(0.3)
    var minShowTime: TimeInterval = 0.5
    var gracePeriod: TimeInterval = 0
}
