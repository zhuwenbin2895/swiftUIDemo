import SwiftUI

struct KolodaStackView<Background: View>: View {
    @ObservedObject var manager: KolodaManager
    var backgroundView: () -> Background

    init(manager: KolodaManager, @ViewBuilder backgroundView: @escaping () -> Background = { EmptyView() }) {
        self.manager = manager
        self.backgroundView = backgroundView
    }

    var body: some View {
        ZStack {
            if manager.isEmpty {
                emptyStateView
            } else {
                cardStack
            }
        }
        .frame(
            width: manager.config.cardSize.width,
            height: manager.config.cardSize.height + CGFloat(manager.config.visibleCardCount) * manager.config.cardSpacing
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            backgroundView()
            if Background.self == EmptyView.self {
                Image(systemName: "rectangle.stack.badge.minus")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
                Text("没有更多卡片了")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var cardStack: some View {
        ZStack {
            ForEach(manager.visibleCards.reversed()) { card in
                cardView(for: card)
            }
        }
    }

    private func cardView(for card: VisibleCard) -> some View {
        let isTop = card.stackIndex == 0
        let offset = offsetForCard(at: card.stackIndex)
        let scale = scaleForCard(at: card.stackIndex)
        let dragOffset = isTop ? manager.dragState.offset : .zero
        let rotation = isTop ? rotationAngle : .zero

        return KolodaCardView(item: card.item, config: manager.config)
            .offset(x: dragOffset.width, y: dragOffset.height + offset)
            .rotationEffect(rotation)
            .scaleEffect(scale)
            .opacity(opacityForCard(at: card.stackIndex))
            .animation(
                isTop ? nil : .spring(response: 0.4, dampingFraction: 0.7),
                value: manager.currentIndex
            )
            .modifier(ShakeModifier(isShaking: isTop && manager.isShaking))
            .gesture(isTop ? dragGesture : nil)
            .onTapGesture {
                if isTop {
                    manager.tapCard()
                }
            }
            .zIndex(Double(manager.config.visibleCardCount - card.stackIndex))
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.8)),
                removal: .opacity
            ))
    }

    private var rotationAngle: Angle {
        let maxAngle = manager.config.maxRotationAngle
        let width = manager.dragState.offset.width
        let normalizedRotation = min(max(width / 200.0, -1), 1)
        return .degrees(normalizedRotation * maxAngle)
    }

    private func offsetForCard(at index: Int) -> CGFloat {
        CGFloat(index) * manager.config.offsetDecrement
    }

    private func scaleForCard(at index: Int) -> CGFloat {
        1.0 - CGFloat(index) * manager.config.scaleDecrement
    }

    private func opacityForCard(at index: Int) -> Double {
        if index == 0 {
            return manager.flyOutOpacity
        }
        return 1.0 - Double(index) * 0.1
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                if !manager.dragState.isDragging {
                    manager.beginDrag()
                }
                manager.updateDrag(translation: value.translation)
            }
            .onEnded { value in
                let velocity = CGSize(
                    width: value.predictedEndTranslation.width - value.translation.width,
                    height: value.predictedEndTranslation.height - value.translation.height
                )
                manager.endDrag(velocity: velocity)
            }
    }
}

struct ShakeModifier: ViewModifier {
    let isShaking: Bool
    @State private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: isShaking) { _, newValue in
                if newValue {
                    performShake()
                } else {
                    shakeOffset = 0
                }
            }
    }

    private func performShake() {
        let duration = 0.06
        withAnimation(.linear(duration: duration)) { shakeOffset = 4 }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.linear(duration: duration)) { shakeOffset = -4 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2) {
            withAnimation(.linear(duration: duration)) { shakeOffset = 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 3) {
            withAnimation(.linear(duration: duration)) { shakeOffset = 0 }
        }
    }
}
