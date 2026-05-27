import UIKit

// MARK: - Skeleton Animation Type
enum SkeletonAnimationType {
    case none
    case shimmerLeftToRight
    case shimmerRightToLeft
    case shimmerTopToBottom
    case gradientFade
    case pulse
}

// MARK: - Skeleton Shape
enum SkeletonShape {
    case rectangle
    case circle
    case roundedRect(cornerRadius: CGFloat)
}

// MARK: - Skeleton Style
struct SkeletonStyle {
    var baseColor: UIColor
    var highlightColor: UIColor
    var animation: SkeletonAnimationType
    var shape: SkeletonShape
    var cornerRadius: CGFloat
    var multilineHeight: CGFloat
    var multilineSpacing: CGFloat
    var multilineLastLinePercent: CGFloat

    static var `default`: SkeletonStyle {
        SkeletonStyle(
            baseColor: UIColor.systemGray5,
            highlightColor: UIColor.systemGray3,
            animation: .shimmerLeftToRight,
            shape: .rectangle,
            cornerRadius: 4,
            multilineHeight: 12,
            multilineSpacing: 8,
            multilineLastLinePercent: 0.6
        )
    }

    static var gradient: SkeletonStyle {
        SkeletonStyle(
            baseColor: UIColor.systemGray5,
            highlightColor: UIColor.white.withAlphaComponent(0.6),
            animation: .shimmerLeftToRight,
            shape: .rectangle,
            cornerRadius: 4,
            multilineHeight: 12,
            multilineSpacing: 8,
            multilineLastLinePercent: 0.6
        )
    }

    static var circle: SkeletonStyle {
        SkeletonStyle(
            baseColor: UIColor.systemGray5,
            highlightColor: UIColor.systemGray3,
            animation: .pulse,
            shape: .circle,
            cornerRadius: 0,
            multilineHeight: 12,
            multilineSpacing: 8,
            multilineLastLinePercent: 0.6
        )
    }
}

// MARK: - Skeleton Configuration
struct SkeletonConfig {
    var style: SkeletonStyle
    var numberOfLines: Int
    var animationDuration: TimeInterval
    var disableUserInteraction: Bool
    var customSize: CGSize?
    var insets: UIEdgeInsets

    static var `default`: SkeletonConfig {
        SkeletonConfig(
            style: .default,
            numberOfLines: 0,
            animationDuration: 1.5,
            disableUserInteraction: true,
            customSize: nil,
            insets: .zero
        )
    }
}
