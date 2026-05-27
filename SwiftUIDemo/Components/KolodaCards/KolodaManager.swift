import SwiftUI
import Combine

protocol KolodaDelegate: AnyObject {
    func kolodaDidSwipeStart(index: Int)
    func kolodaDidSwipe(index: Int, direction: KolodaSwipeDirection)
    func kolodaDragProgress(index: Int, offset: CGSize, progress: CGFloat)
    func kolodaDidTap(index: Int)
    func kolodaDidRunOutOfCards()
}

extension KolodaDelegate {
    func kolodaDidSwipeStart(index: Int) {}
    func kolodaDidSwipe(index: Int, direction: KolodaSwipeDirection) {}
    func kolodaDragProgress(index: Int, offset: CGSize, progress: CGFloat) {}
    func kolodaDidTap(index: Int) {}
    func kolodaDidRunOutOfCards() {}
}

class KolodaManager: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var cardItems: [KolodaCardItem] = []
    @Published var dragState: KolodaDragState = KolodaDragState()
    @Published var isAnimatingSwipe: Bool = false
    @Published var flyOutOpacity: Double = 1.0
    @Published var isShaking: Bool = false
    @Published var isEmpty: Bool = false
    @Published var isDraggingCard: Bool = false

    var config: KolodaConfig
    weak var delegate: KolodaDelegate?

    private var totalCount: Int { cardItems.count }

    init(config: KolodaConfig = KolodaConfig()) {
        self.config = config
    }

    func loadCards(_ items: [KolodaCardItem]) {
        cardItems = items
        currentIndex = 0
        isEmpty = items.isEmpty
    }

    func insertCard(_ item: KolodaCardItem, at index: Int) {
        let safeIndex = min(index, cardItems.count)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardItems.insert(item, at: safeIndex)
            isEmpty = false
        }
    }

    func removeCard(at index: Int) {
        guard index < cardItems.count else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardItems.remove(at: index)
            if currentIndex >= cardItems.count {
                currentIndex = max(0, cardItems.count - 1)
            }
            isEmpty = cardItems.isEmpty || currentIndex >= cardItems.count
        }
    }

    var visibleCards: [VisibleCard] {
        var cards: [VisibleCard] = []
        for i in 0..<config.visibleCardCount {
            let index = currentIndex + i
            guard index < cardItems.count else { break }
            cards.append(VisibleCard(
                item: cardItems[index],
                stackIndex: i,
                dataIndex: index
            ))
        }
        return cards
    }

    func beginDrag() {
        dragState.isDragging = true
        isDraggingCard = true
        delegate?.kolodaDidSwipeStart(index: currentIndex)
    }

    func updateDrag(translation: CGSize) {
        dragState.offset = translation
        delegate?.kolodaDragProgress(
            index: currentIndex,
            offset: translation,
            progress: dragState.progress
        )

        let threshold = config.swipeThreshold
        if dragState.progress > threshold && !isShaking {
            triggerShake()
        }
    }

    func endDrag(velocity: CGSize) {
        dragState.isDragging = false
        isDraggingCard = false

        let speed = sqrt(velocity.width * velocity.width + velocity.height * velocity.height)
        let distance = dragState.progress

        if speed > config.velocityThreshold || distance > config.swipeThreshold {
            if let direction = dragState.direction, config.allowedDirections.contains(direction) {
                performSwipe(direction: direction)
                return
            }
        }
        resetCard()
    }

    func swipeProgrammatically(direction: KolodaSwipeDirection) {
        guard !isAnimatingSwipe, currentIndex < cardItems.count else { return }
        performSwipe(direction: direction)
    }

    func swipeToDestination(_ destination: CGSize, direction: KolodaSwipeDirection? = nil) {
        guard !isAnimatingSwipe, currentIndex < cardItems.count else { return }
        isAnimatingSwipe = true

        let resolvedDirection = direction ?? {
            let absX = abs(destination.width)
            let absY = abs(destination.height)
            if absX > absY {
                return destination.width > 0 ? KolodaSwipeDirection.right : .left
            } else {
                return destination.height > 0 ? .down : .up
            }
        }()

        withAnimation(.easeIn(duration: config.animationDuration)) {
            dragState.offset = destination
            flyOutOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) { [weak self] in
            guard let self else { return }
            self.delegate?.kolodaDidSwipe(index: self.currentIndex, direction: resolvedDirection)
            self.currentIndex += 1
            self.dragState = KolodaDragState()
            self.isAnimatingSwipe = false
            self.flyOutOpacity = 1.0
            self.isShaking = false

            if self.currentIndex >= self.cardItems.count {
                self.isEmpty = true
                self.delegate?.kolodaDidRunOutOfCards()
            }
        }
    }

    func tapCard() {
        delegate?.kolodaDidTap(index: currentIndex)
    }

    private func performSwipe(direction: KolodaSwipeDirection) {
        isAnimatingSwipe = true

        let flyOut: CGSize
        if let customDestination = config.customFlyOutDestination {
            flyOut = customDestination(direction)
        } else {
            flyOut = CGSize(
                width: direction.unitOffset.width * config.flyOutDistance,
                height: direction.unitOffset.height * config.flyOutDistance
            )
        }

        withAnimation(.easeIn(duration: config.animationDuration)) {
            dragState.offset = flyOut
            flyOutOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) { [weak self] in
            guard let self else { return }
            self.delegate?.kolodaDidSwipe(index: self.currentIndex, direction: direction)
            self.currentIndex += 1
            self.dragState = KolodaDragState()
            self.isAnimatingSwipe = false
            self.flyOutOpacity = 1.0
            self.isShaking = false

            if self.currentIndex >= self.cardItems.count {
                self.isEmpty = true
                self.delegate?.kolodaDidRunOutOfCards()
            }
        }
    }

    private func resetCard() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
            dragState.offset = .zero
            isShaking = false
        }
    }

    private func triggerShake() {
        isShaking = true
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func rewind() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        isEmpty = false
    }

    func reset() {
        currentIndex = 0
        dragState = KolodaDragState()
        isAnimatingSwipe = false
        flyOutOpacity = 1.0
        isShaking = false
        isEmpty = cardItems.isEmpty
    }
}

struct KolodaCardItem: Identifiable, Equatable {
    let id: String
    var title: String
    var subtitle: String
    var color: Color
    var imageName: String?

    static func == (lhs: KolodaCardItem, rhs: KolodaCardItem) -> Bool {
        lhs.id == rhs.id
    }
}

struct VisibleCard: Identifiable {
    var id: String { item.id }
    let item: KolodaCardItem
    let stackIndex: Int
    let dataIndex: Int
}
