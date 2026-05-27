import SwiftUI

enum KolodaSwipeDirection: String, CaseIterable {
    case left, right, up, down

    var unitOffset: CGSize {
        switch self {
        case .left: return CGSize(width: -1, height: 0)
        case .right: return CGSize(width: 1, height: 0)
        case .up: return CGSize(width: 0, height: -1)
        case .down: return CGSize(width: 0, height: 1)
        }
    }
}

struct KolodaConfig {
    var cardSize: CGSize = CGSize(width: 320, height: 420)
    var cornerRadius: CGFloat = 16
    var cardSpacing: CGFloat = 8
    var visibleCardCount: Int = 3
    var swipeThreshold: CGFloat = 100
    var velocityThreshold: CGFloat = 500
    var maxRotationAngle: Double = 15
    var flyOutDistance: CGFloat = 1000
    var animationDuration: Double = 0.35
    var scaleDecrement: CGFloat = 0.05
    var offsetDecrement: CGFloat = 10
    var allowedDirections: Set<KolodaSwipeDirection> = [.left, .right, .up, .down]
    var customFlyOutDestination: ((KolodaSwipeDirection) -> CGSize)? = nil
}

struct KolodaDragState {
    var offset: CGSize = .zero
    var isDragging: Bool = false

    var direction: KolodaSwipeDirection? {
        let absX = abs(offset.width)
        let absY = abs(offset.height)
        guard absX > 10 || absY > 10 else { return nil }
        if absX > absY {
            return offset.width > 0 ? .right : .left
        } else {
            return offset.height > 0 ? .down : .up
        }
    }

    var progress: CGFloat {
        sqrt(offset.width * offset.width + offset.height * offset.height)
    }
}
