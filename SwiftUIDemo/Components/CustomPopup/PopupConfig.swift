import SwiftUI

enum PopupStyle {
    case bottom
    case center
    case fullscreen
}

enum PopupAnimation {
    case slideFromBottom
    case fadeScale
    case spring
}

struct PopupButton {
    let title: String
    var style: ButtonStyle = .default
    var action: () -> Void

    enum ButtonStyle {
        case `default`
        case cancel
        case destructive
    }
}

@MainActor
struct PopupConfig {
    var style: PopupStyle = .center
    var animation: PopupAnimation = .fadeScale
    var tapBackgroundToDismiss: Bool = true
    var dragToDismiss: Bool = true
    var showCloseButton: Bool = false
    var maskColor: Color = Color.black.opacity(0.4)
    var cornerRadius: CGFloat = 16
    var maxHeight: CGFloat? = nil
    var icon: String? = nil
    var title: String? = nil
    var message: String? = nil
    var buttons: [PopupButton] = []
    var customContent: AnyView? = nil
    var customButtons: AnyView? = nil
}

struct PopupItem: Identifiable {
    let id = UUID()
    var config: PopupConfig
}
