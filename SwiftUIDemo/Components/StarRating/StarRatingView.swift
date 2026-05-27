import SwiftUI
import UIKit

// MARK: - Star Rating View

struct StarRatingView: View {
    @Binding var rating: Double
    var config: StarRatingConfig
    var onRatingChanged: ((Double) -> Void)?
    var onTouchEnded: ((Double) -> Void)?

    @State private var showLongPressHint = false
    @State private var isDragging = false
    @Environment(\.layoutDirection) private var layoutDirection

    init(
        rating: Binding<Double>,
        config: StarRatingConfig = StarRatingConfig(),
        onRatingChanged: ((Double) -> Void)? = nil,
        onTouchEnded: ((Double) -> Void)? = nil
    ) {
        self._rating = rating
        self.config = config
        self.onRatingChanged = onRatingChanged
        self.onTouchEnded = onTouchEnded
    }

    var body: some View {
        let isRTL = config.supportRTL && layoutDirection == .rightToLeft

        let mainContent = HStack(spacing: 0) {
            if config.showRatingText && config.textPosition == .left {
                ratingTextView
                    .padding(.trailing, 8)
            }

            starsContainer(isRTL: isRTL)

            if config.showRatingText && config.textPosition == .right {
                ratingTextView
                    .padding(.leading, 8)
            }
        }

        VStack(spacing: 4) {
            if config.showRatingText && config.textPosition == .top {
                ratingTextView
            }

            mainContent

            if config.showRatingText && config.textPosition == .bottom {
                ratingTextView
            }

            if config.showDescription {
                descriptionTextView
            }
        }
        .padding(config.contentInsets)
        .overlay(alignment: .top) {
            if showLongPressHint {
                Text(config.longPressHint)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .offset(y: -36)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: config.animationDuration), value: rating)
        .animation(.easeInOut(duration: 0.2), value: showLongPressHint)
    }

    // MARK: - Stars Container

    @ViewBuilder
    private func starsContainer(isRTL: Bool) -> some View {
        let stars = HStack(spacing: config.starSpacing) {
            ForEach(0..<config.totalStars, id: \.self) { index in
                starView(at: index)
            }
        }
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)

        if config.isInteractive {
            stars
                .gesture(dragGesture(isRTL: isRTL))
                .simultaneousGesture(tapGesture(isRTL: isRTL))
                .if(config.enableLongPress) { view in
                    view.simultaneousGesture(longPressGesture)
                }
        } else {
            stars
        }
    }

    // MARK: - Single Star

    @ViewBuilder
    private func starView(at index: Int) -> some View {
        let fillAmount = starFillAmount(at: index)

        ZStack {
            if let emptyImage = config.emptyImage {
                emptyImage
                    .resizable()
                    .frame(width: config.starSize, height: config.starSize)
            } else {
                StarShape()
                    .fill(config.emptyColor)
                    .frame(width: config.starSize, height: config.starSize)
                    .overlay {
                        if config.borderWidth > 0 {
                            StarShape()
                                .stroke(config.borderColor, lineWidth: config.borderWidth)
                                .frame(width: config.starSize, height: config.starSize)
                        }
                    }
            }

            if fillAmount > 0 {
                if fillAmount >= 1.0 {
                    filledStarView
                } else if fillAmount == 0.5, let halfImage = config.halfImage {
                    halfImage
                        .resizable()
                        .frame(width: config.starSize, height: config.starSize)
                } else {
                    filledStarView
                        .mask(
                            GeometryReader { geo in
                                Rectangle()
                                    .frame(width: geo.size.width * fillAmount)
                            }
                        )
                }
            }
        }
        .frame(width: config.starSize, height: config.starSize)
    }

    @ViewBuilder
    private var filledStarView: some View {
        if let filledImage = config.filledImage {
            filledImage
                .resizable()
                .frame(width: config.starSize, height: config.starSize)
        } else {
            StarShape()
                .fill(config.fillColor)
                .frame(width: config.starSize, height: config.starSize)
                .overlay {
                    if config.borderWidth > 0 {
                        StarShape()
                            .stroke(config.borderColor, lineWidth: config.borderWidth)
                            .frame(width: config.starSize, height: config.starSize)
                    }
                }
        }
    }

    // MARK: - Fill Calculation

    private func starFillAmount(at index: Int) -> Double {
        let starPosition = Double(index + 1)
        if rating >= starPosition {
            return 1.0
        } else if rating > Double(index) {
            return rating - Double(index)
        }
        return 0.0
    }

    // MARK: - Rating Text

    @ViewBuilder
    private var ratingTextView: some View {
        Text(String(format: config.textFormat, rating))
            .font(config.textFont)
            .foregroundColor(config.textColor)
            .monospacedDigit()
    }

    // MARK: - Description Text

    @ViewBuilder
    private var descriptionTextView: some View {
        if !config.descriptions.isEmpty {
            let index = max(0, min(config.descriptions.count - 1, Int(ceil(rating)) - 1))
            let text = rating > 0 ? config.descriptions[index] : ""
            Text(text)
                .font(config.descriptionFont)
                .foregroundColor(config.descriptionColor)
        }
    }

    // MARK: - Gestures

    private func dragGesture(isRTL: Bool) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                let newRating = ratingFromLocation(value.location.x, isRTL: isRTL)
                updateRating(newRating)
            }
            .onEnded { value in
                isDragging = false
                let finalRating = ratingFromLocation(value.location.x, isRTL: isRTL)
                updateRating(finalRating)
                onTouchEnded?(finalRating)
            }
    }

    private func tapGesture(isRTL: Bool) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                let newRating = ratingFromLocation(value.location.x, isRTL: isRTL)
                updateRating(newRating)
                onTouchEnded?(newRating)
            }
    }

    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in
                showLongPressHint = true
                if config.enableHapticFeedback {
                    triggerHaptic()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showLongPressHint = false
                }
            }
    }

    // MARK: - Helpers

    private func ratingFromLocation(_ x: CGFloat, isRTL: Bool) -> Double {
        let totalWidth = CGFloat(config.totalStars) * config.starSize + CGFloat(config.totalStars - 1) * config.starSpacing
        let adjustedX = isRTL ? (totalWidth - x) : x
        let clampedX = max(0, min(totalWidth, adjustedX))

        var rawRating: Double = 0
        let starUnit = config.starSize + config.starSpacing
        let starIndex = Int(clampedX / starUnit)
        let posInStar = clampedX - CGFloat(starIndex) * starUnit

        if posInStar <= config.starSize {
            rawRating = Double(starIndex) + Double(posInStar / config.starSize)
        } else {
            rawRating = Double(starIndex + 1)
        }

        return applyMode(rawRating)
    }

    private func applyMode(_ rawRating: Double) -> Double {
        let clamped = max(0, min(Double(config.totalStars), rawRating))
        switch config.ratingMode {
        case .full:
            return ceil(clamped)
        case .half:
            return (clamped * 2).rounded() / 2
        case .precise:
            return (clamped * 100).rounded() / 100
        }
    }

    private func updateRating(_ newRating: Double) {
        let clampedRating = max(0, min(Double(config.totalStars), newRating))
        if clampedRating != rating {
            rating = clampedRating
            onRatingChanged?(clampedRating)
            if config.enableHapticFeedback && isDragging {
                triggerHaptic()
            }
        }
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - View Extension

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Star Shape

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.38
        let points = 5
        let angleOffset = -CGFloat.pi / 2

        var path = Path()
        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = angleOffset + CGFloat(i) * .pi / CGFloat(points)
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
