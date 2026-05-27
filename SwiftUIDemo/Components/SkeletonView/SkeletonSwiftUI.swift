import SwiftUI
import UIKit

// MARK: - SwiftUI Skeleton Modifier
struct SkeletonModifier: ViewModifier {
    let isActive: Bool
    let style: SkeletonViewStyle
    let animation: SkeletonAnimationStyle

    func body(content: Content) -> some View {
        if isActive {
            content
                .hidden()
                .overlay(
                    SkeletonShapeView(style: style)
                        .fill(style.baseColor)
                        .overlay(
                            SkeletonAnimationView(style: style, animation: animation)
                        )
                        .clipped()
                )
        } else {
            content
        }
    }
}

// MARK: - Skeleton View Style
struct SkeletonViewStyle {
    var baseColor: Color = Color(UIColor.systemGray5)
    var highlightColor: Color = Color(UIColor.systemGray3)
    var cornerRadius: CGFloat = 4
    var shape: SkeletonShapeType = .rectangle

    enum SkeletonShapeType {
        case rectangle
        case circle
        case roundedRect(CGFloat)
        case capsule
    }
}

// MARK: - Skeleton Animation Style
enum SkeletonAnimationStyle {
    case none
    case shimmerLeftToRight
    case shimmerRightToLeft
    case shimmerTopToBottom
    case gradientFade
    case pulse
}

// MARK: - Skeleton Shape View
struct SkeletonShapeView: Shape {
    let style: SkeletonViewStyle

    func path(in rect: CGRect) -> Path {
        switch style.shape {
        case .rectangle:
            return RoundedRectangle(cornerRadius: style.cornerRadius).path(in: rect)
        case .circle:
            return Circle().path(in: rect)
        case .roundedRect(let radius):
            return RoundedRectangle(cornerRadius: radius).path(in: rect)
        case .capsule:
            return Capsule().path(in: rect)
        }
    }
}

// MARK: - Skeleton Animation View
struct SkeletonAnimationView: View {
    let style: SkeletonViewStyle
    let animation: SkeletonAnimationStyle
    @State private var animating = false

    var body: some View {
        switch animation {
        case .none:
            EmptyView()
        case .shimmerLeftToRight:
            shimmerHorizontalView(reversed: false)
        case .shimmerRightToLeft:
            shimmerHorizontalView(reversed: true)
        case .shimmerTopToBottom:
            shimmerVerticalView()
        case .gradientFade:
            gradientFadeView
        case .pulse:
            pulseView
        }
    }

    private func shimmerHorizontalView(reversed: Bool) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    style.highlightColor.opacity(0.6),
                    .clear
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width * 0.6)
            .offset(x: animating
                ? (reversed ? -width * 1.5 : width * 1.5)
                : (reversed ? width * 1.5 : -width * 1.5)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    animating = true
                }
            }
        }
        .clipped()
    }

    private func shimmerVerticalView() -> some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    style.highlightColor.opacity(0.6),
                    .clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height * 0.6)
            .frame(maxWidth: .infinity)
            .offset(y: animating ? height * 1.5 : -height * 1.5)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    animating = true
                }
            }
        }
        .clipped()
    }

    private var gradientFadeView: some View {
        style.highlightColor
            .opacity(animating ? 0.6 : 0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    animating = true
                }
            }
    }

    private var pulseView: some View {
        style.baseColor
            .opacity(animating ? 0.4 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    animating = true
                }
            }
    }
}

// MARK: - View Extension
extension View {
    func skeleton(
        isActive: Bool,
        style: SkeletonViewStyle = SkeletonViewStyle(),
        animation: SkeletonAnimationStyle = .shimmerLeftToRight
    ) -> some View {
        modifier(SkeletonModifier(isActive: isActive, style: style, animation: animation))
    }
}

// MARK: - Skeleton Row View (Multiline Text Skeleton)
struct SkeletonRowView: View {
    var lineCount: Int = 3
    var lineHeight: CGFloat = 12
    var spacing: CGFloat = 8
    var lastLineWidth: CGFloat = 0.6
    var style: SkeletonViewStyle = SkeletonViewStyle()
    var animation: SkeletonAnimationStyle = .shimmerLeftToRight

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<lineCount, id: \.self) { index in
                let widthFraction: CGFloat = index == lineCount - 1 ? lastLineWidth : 1.0 - CGFloat(index) * 0.03
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .fill(style.baseColor)
                        .frame(width: geometry.size.width * widthFraction, height: lineHeight)
                        .skeleton(isActive: true, style: style, animation: animation)
                }
                .frame(height: lineHeight)
            }
        }
    }
}

// MARK: - Skeleton Card View
struct SkeletonCardView: View {
    var style: SkeletonViewStyle = SkeletonViewStyle()
    var animation: SkeletonAnimationStyle = .shimmerLeftToRight
    var showAvatar: Bool = true
    var lineCount: Int = 3

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if showAvatar {
                Circle()
                    .fill(style.baseColor)
                    .frame(width: 48, height: 48)
                    .skeleton(
                        isActive: true,
                        style: SkeletonViewStyle(
                            baseColor: style.baseColor,
                            highlightColor: style.highlightColor,
                            shape: .circle
                        ),
                        animation: animation
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.baseColor)
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                    .skeleton(isActive: true, style: style, animation: animation)

                SkeletonRowView(
                    lineCount: lineCount,
                    lineHeight: 12,
                    spacing: 8,
                    style: style,
                    animation: animation
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Skeleton Table Cell View
struct SkeletonTableCellView: View {
    var style: SkeletonViewStyle = SkeletonViewStyle()
    var animation: SkeletonAnimationStyle = .shimmerLeftToRight

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(style.baseColor)
                .frame(width: 60, height: 60)
                .skeleton(isActive: true, style: style, animation: animation)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.baseColor)
                    .frame(height: 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .skeleton(isActive: true, style: style, animation: animation)

                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.baseColor)
                    .frame(width: 180, height: 12)
                    .skeleton(isActive: true, style: style, animation: animation)

                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.baseColor)
                    .frame(width: 120, height: 12)
                    .skeleton(isActive: true, style: style, animation: animation)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Skeleton Grid Item View
struct SkeletonGridItemView: View {
    var style: SkeletonViewStyle = SkeletonViewStyle()
    var animation: SkeletonAnimationStyle = .shimmerLeftToRight

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(style.baseColor)
                .aspectRatio(1, contentMode: .fit)
                .skeleton(isActive: true, style: style, animation: animation)

            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(style.baseColor)
                .frame(height: 12)
                .skeleton(isActive: true, style: style, animation: animation)

            RoundedRectangle(cornerRadius: style.cornerRadius)
                .fill(style.baseColor)
                .frame(height: 10)
                .frame(maxWidth: .infinity)
                .padding(.trailing, 20)
                .skeleton(isActive: true, style: style, animation: animation)
        }
    }
}
