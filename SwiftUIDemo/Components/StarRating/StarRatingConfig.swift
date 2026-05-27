import SwiftUI

// MARK: - Rating Mode

enum StarRatingMode {
    case full
    case half
    case precise
}

// MARK: - Text Position

enum StarRatingTextPosition {
    case left
    case right
    case top
    case bottom
}

// MARK: - Configuration

struct StarRatingConfig {
    // Star count
    var totalStars: Int = 5

    // Rating mode
    var ratingMode: StarRatingMode = .precise

    // Star appearance
    var starSize: CGFloat = 30
    var starSpacing: CGFloat = 8
    var fillColor: Color = .yellow
    var emptyColor: Color = .gray.opacity(0.3)
    var borderColor: Color = .orange
    var borderWidth: CGFloat = 0

    // Custom images
    var filledImage: Image? = nil
    var halfImage: Image? = nil
    var emptyImage: Image? = nil

    // Interaction
    var isInteractive: Bool = true
    var enableHapticFeedback: Bool = false

    // Animation
    var animationDuration: Double = 0.2

    // Text display
    var showRatingText: Bool = false
    var textFormat: String = "%.1f"
    var textFont: Font = .system(size: 14, weight: .medium)
    var textColor: Color = .primary
    var textPosition: StarRatingTextPosition = .right

    // Description text
    var showDescription: Bool = false
    var descriptions: [String] = ["很差", "较差", "一般", "较好", "很好"]
    var descriptionFont: Font = .system(size: 12)
    var descriptionColor: Color = .secondary

    // Layout
    var contentInsets: EdgeInsets = .init()
    var supportRTL: Bool = false

    // Long press
    var enableLongPress: Bool = false
    var longPressHint: String = "长按可拖动评分"

    init(totalStars: Int = 5) {
        self.totalStars = max(1, min(10, totalStars))
    }
}
