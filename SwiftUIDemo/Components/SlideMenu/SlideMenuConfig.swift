import SwiftUI
import UIKit

// MARK: - Menu State

enum SlideMenuState: Equatable {
    case closed
    case leftOpen
    case rightOpen
    case leftPartial(CGFloat)
    case rightPartial(CGFloat)
}

// MARK: - Menu Side

enum SlideMenuSide {
    case left
    case right
}

// MARK: - Gesture State

enum SlideMenuGesturePhase {
    case began
    case changed(progress: CGFloat)
    case ended(velocity: CGFloat)
}

// MARK: - Configuration

struct SlideMenuConfig {
    var leftMenuWidth: CGFloat = 280
    var rightMenuWidth: CGFloat = 280
    var edgeTriggerWidth: CGFloat = 30
    var mainViewScale: CGFloat = 0.88
    var mainViewTranslateRatio: CGFloat = 1.0
    var mainViewCornerRadius: CGFloat = 12
    var mainViewShadowRadius: CGFloat = 10
    var mainViewShadowOpacity: CGFloat = 0.3
    var mainViewShadowColor: Color = .black

    var animationDuration: Double = 0.4
    var springDamping: CGFloat = 0.75
    var springResponse: CGFloat = 0.4

    var enableLeftMenu: Bool = true
    var enableRightMenu: Bool = false
    var enableBounceEffect: Bool = true
    var bounceDistance: CGFloat = 20

    var overlayColor: Color = .black
    var overlayMaxOpacity: CGFloat = 0.4

    var velocityThreshold: CGFloat = 500
    var progressThreshold: CGFloat = 0.35

    var partialStops: [CGFloat] = [0.5, 1.0]

    var statusBarStyleWhenOpen: UIStatusBarStyle = .lightContent
}

// MARK: - Event Callbacks

struct SlideMenuCallbacks {
    var onMenuWillOpen: ((SlideMenuSide) -> Void)?
    var onMenuDidOpen: ((SlideMenuSide) -> Void)?
    var onMenuWillClose: ((SlideMenuSide) -> Void)?
    var onMenuDidClose: ((SlideMenuSide) -> Void)?
    var onGesturePhaseChanged: ((SlideMenuGesturePhase) -> Void)?
}
