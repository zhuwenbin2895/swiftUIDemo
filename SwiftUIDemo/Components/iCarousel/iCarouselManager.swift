import SwiftUI
import Combine

class iCarouselManager: ObservableObject {
    @Published var items: [iCarouselItem] = []
    @Published var currentOffset: CGFloat = 0
    @Published var currentIndex: Int = 0
    @Published var isDragging: Bool = false
    @Published var config: iCarouselConfig
    @Published var reuseStats: ReuseStats = ReuseStats()

    struct ReuseStats {
        var totalCreated: Int = 0
        var totalReused: Int = 0
        var poolSize: Int = 0
        var activeCount: Int = 0
        var recycledCount: Int = 0
    }

    weak var delegate: iCarouselDelegate?

    private var autoScrollTimer: AnyCancellable?
    private var dragStartOffset: CGFloat = 0
    private var velocity: CGFloat = 0
    private var displayLink: CADisplayLink?
    private var reusePool: [String: Set<Int>] = [:]
    private var activeViews: Set<Int> = []
    private var previousVisibleIndices: Set<Int> = []

    init(config: iCarouselConfig = iCarouselConfig()) {
        self.config = config
    }

    // MARK: - Content Management

    func loadItems(_ items: [iCarouselItem]) {
        self.items = items
        currentOffset = 0
        currentIndex = 0
        startAutoScrollIfNeeded()
    }

    func addItem(_ item: iCarouselItem, at index: Int? = nil) {
        if let index = index, index <= items.count {
            items.insert(item, at: index)
        } else {
            items.append(item)
        }
    }

    func removeItem(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        items.remove(at: index)
        if currentIndex >= items.count {
            currentIndex = max(0, items.count - 1)
            currentOffset = CGFloat(currentIndex)
        }
    }

    // MARK: - Scrolling

    func scrollToIndex(_ index: Int, animated: Bool = true) {
        guard !items.isEmpty else { return }
        let targetIndex: Int
        if config.isInfinite {
            targetIndex = index
        } else {
            targetIndex = max(0, min(index, items.count - 1))
        }

        if animated {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                currentOffset = CGFloat(targetIndex)
                currentIndex = wrappedIndex(targetIndex)
            }
        } else {
            currentOffset = CGFloat(targetIndex)
            currentIndex = wrappedIndex(targetIndex)
        }
        delegate?.carouselCurrentIndexChanged(to: currentIndex)
    }

    func onDragBegan() {
        isDragging = true
        dragStartOffset = currentOffset
        stopAutoScroll()
        stopDeceleration()
        delegate?.carouselWillBeginDragging()
    }

    func onDragChanged(translation: CGFloat) {
        guard config.isUserScrollEnabled else { return }
        let dragSensitivity: CGFloat = config.itemSpacing
        let dragDelta = -translation / dragSensitivity
        currentOffset = dragStartOffset + dragDelta

        if !config.isInfinite {
            let minOffset: CGFloat = 0
            let maxOffset = CGFloat(items.count - 1)
            currentOffset = max(minOffset - 0.5, min(maxOffset + 0.5, currentOffset))
        }

        updateCurrentIndex()
        delegate?.carouselDidScroll(offset: currentOffset)
    }

    func onDragEnded(predictedTranslation: CGFloat) {
        guard config.isUserScrollEnabled else { return }
        isDragging = false
        delegate?.carouselDidEndDragging()

        let dragSensitivity: CGFloat = config.itemSpacing
        velocity = -(predictedTranslation - (currentOffset - dragStartOffset) * dragSensitivity) / dragSensitivity

        startDeceleration()
        startAutoScrollIfNeeded()
    }

    // MARK: - Auto Scroll

    func startAutoScrollIfNeeded() {
        guard config.autoScrollEnabled, !items.isEmpty else { return }
        stopAutoScroll()
        autoScrollTimer = Timer.publish(every: config.autoScrollInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.autoScrollNext()
            }
    }

    func stopAutoScroll() {
        autoScrollTimer?.cancel()
        autoScrollTimer = nil
    }

    private func autoScrollNext() {
        guard !isDragging else { return }
        let nextIndex = currentIndex + 1
        if config.isInfinite || nextIndex < items.count {
            scrollToIndex(nextIndex)
        } else {
            scrollToIndex(0)
        }
    }

    // MARK: - Deceleration

    private func startDeceleration() {
        stopDeceleration()
        displayLink = CADisplayLink(target: self, selector: #selector(decelerationStep))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func decelerationStep() {
        velocity *= config.decelerationRate
        currentOffset += velocity * 0.016

        if !config.isInfinite {
            let minOffset: CGFloat = 0
            let maxOffset = CGFloat(items.count - 1)
            if currentOffset < minOffset {
                currentOffset = minOffset
                velocity = 0
            } else if currentOffset > maxOffset {
                currentOffset = maxOffset
                velocity = 0
            }
        }

        updateCurrentIndex()
        delegate?.carouselDidScroll(offset: currentOffset)

        if abs(velocity) < 0.01 {
            stopDeceleration()
            snapToNearest()
        }
    }

    private func snapToNearest() {
        let finalTarget: CGFloat
        let target = round(currentOffset)
        if config.isInfinite {
            finalTarget = target
        } else {
            finalTarget = max(0, min(CGFloat(items.count - 1), target))
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            currentOffset = finalTarget
            currentIndex = wrappedIndex(Int(finalTarget))
        }
        delegate?.carouselCurrentIndexChanged(to: currentIndex)
    }

    private func stopDeceleration() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - Index Helpers

    func wrappedIndex(_ index: Int) -> Int {
        guard !items.isEmpty else { return 0 }
        let count = items.count
        return ((index % count) + count) % count
    }

    private func updateCurrentIndex() {
        let newIndex = wrappedIndex(Int(round(currentOffset)))
        if newIndex != currentIndex {
            currentIndex = newIndex
            delegate?.carouselCurrentIndexChanged(to: currentIndex)
        }
    }

    // MARK: - Transform Calculation

    func transformForItem(at itemOffset: CGFloat) -> iCarouselTransform {
        if let customTransform = config.customTransform {
            return customTransform(itemOffset, config.itemSize)
        }

        switch config.carouselType {
        case .linear:
            return linearTransform(offset: itemOffset)
        case .cylindrical:
            return cylindricalTransform(offset: itemOffset)
        case .coverFlow:
            return coverFlowTransform(offset: itemOffset)
        case .timeMachine:
            return timeMachineTransform(offset: itemOffset)
        case .rotary:
            return rotaryTransform(offset: itemOffset)
        case .invertedCoverFlow:
            return invertedCoverFlowTransform(offset: itemOffset)
        case .custom:
            return linearTransform(offset: itemOffset)
        }
    }

    // MARK: - Linear

    private func linearTransform(offset: CGFloat) -> iCarouselTransform {
        var t = iCarouselTransform()
        t.offset = CGSize(width: offset * config.itemSpacing, height: 0)
        let absOffset = abs(offset)
        t.scale = max(0.7, 1.0 - absOffset * 0.1)
        t.opacity = max(0.3, 1.0 - absOffset * 0.2)
        t.zIndex = -absOffset
        return t
    }

    // MARK: - Cylindrical

    private func cylindricalTransform(offset: CGFloat) -> iCarouselTransform {
        var t = iCarouselTransform()
        let count = max(CGFloat(config.visibleItems), CGFloat(items.count))
        let radius = config.radius ?? (config.itemSpacing * count / (2 * .pi))
        let angle = offset * (2 * .pi / count)

        t.offset = CGSize(
            width: sin(angle) * radius,
            height: 0
        )
        t.rotation3D = (Double(angle) * 180 / .pi, (0, 1, 0))
        t.perspective = 1.0 / config.perspectiveDepth
        let z = cos(angle) * radius
        t.zIndex = Double(z)
        t.opacity = max(0.3, Double((z + radius) / (2 * radius)))
        t.scale = max(0.6, (z + radius * 1.5) / (radius * 2.5))
        return t
    }

    // MARK: - Cover Flow

    private func coverFlowTransform(offset: CGFloat) -> iCarouselTransform {
        var t = iCarouselTransform()
        let absOffset = min(abs(offset), 3.0)
        let sign: CGFloat = offset < 0 ? -1 : (offset > 0 ? 1 : 0)

        let centerSpacing = config.itemSpacing * 0.45
        let sideSpacing = config.itemSpacing * 0.35

        if absOffset < 1.0 {
            let progress = absOffset
            t.offset = CGSize(width: sign * progress * centerSpacing, height: 0)
            let rotationAngle = sign * progress * 55
            t.rotation3D = (Double(rotationAngle), (0, 1, 0))
            t.scale = 1.0 - progress * 0.15
        } else {
            let extra = absOffset - 1.0
            t.offset = CGSize(width: sign * (centerSpacing + extra * sideSpacing), height: 0)
            t.rotation3D = (Double(sign * 55), (0, 1, 0))
            t.scale = 0.85 - extra * 0.05
        }

        t.perspective = 1.0 / config.perspectiveDepth
        t.zIndex = -Double(absOffset)
        t.opacity = max(0.2, 1.0 - Double(absOffset) * 0.25)
        return t
    }

    // MARK: - Time Machine

    private func timeMachineTransform(offset: CGFloat) -> iCarouselTransform {
        var t = iCarouselTransform()
        let spacing: CGFloat = config.itemSize.height * 0.4
        t.offset = CGSize(width: 0, height: offset * spacing)

        let absOffset = abs(offset)
        t.scale = max(0.5, 1.0 - absOffset * 0.12)
        t.opacity = max(0.0, 1.0 - Double(absOffset) * 0.3)
        t.zIndex = -Double(absOffset)

        let tiltAngle = config.tilt * offset * 15
        t.rotation3D = (Double(tiltAngle), (1, 0, 0))
        t.perspective = 1.0 / config.perspectiveDepth
        return t
    }

    // MARK: - Rotary

    private func rotaryTransform(offset: CGFloat) -> iCarouselTransform {
        var t = iCarouselTransform()
        let count = max(CGFloat(config.visibleItems), CGFloat(items.count))
        let radius = config.radius ?? config.itemSpacing * 1.2
        let angle = offset * (2 * .pi / count)

        t.offset = CGSize(
            width: sin(angle) * radius,
            height: (1 - cos(angle)) * radius * 0.3
        )

        let z = cos(angle)
        t.zIndex = Double(z) * 100
        t.scale = max(0.5, 0.7 + z * 0.3)
        t.opacity = max(0.2, 0.5 + Double(z) * 0.5)
        t.rotation3D = (Double(angle) * 180 / .pi * 0.3, (0, 1, 0))
        t.perspective = 1.0 / config.perspectiveDepth
        return t
    }

    // MARK: - Inverted Cover Flow

    private func invertedCoverFlowTransform(offset: CGFloat) -> iCarouselTransform {
        var t = iCarouselTransform()
        let absOffset = min(abs(offset), 3.0)
        let sign: CGFloat = offset < 0 ? -1 : (offset > 0 ? 1 : 0)

        let centerSpacing = config.itemSpacing * 0.45
        let sideSpacing = config.itemSpacing * 0.35

        if absOffset < 1.0 {
            let progress = absOffset
            t.offset = CGSize(width: sign * progress * centerSpacing, height: 0)
            let rotationAngle = -sign * progress * 55
            t.rotation3D = (Double(rotationAngle), (0, 1, 0))
            t.scale = 1.0 - progress * 0.15
        } else {
            let extra = absOffset - 1.0
            t.offset = CGSize(width: sign * (centerSpacing + extra * sideSpacing), height: 0)
            t.rotation3D = (Double(-sign * 55), (0, 1, 0))
            t.scale = 0.85 - extra * 0.05
        }

        t.perspective = 1.0 / config.perspectiveDepth
        t.zIndex = -Double(absOffset)
        t.opacity = max(0.2, 1.0 - Double(absOffset) * 0.25)
        return t
    }

    // MARK: - View Reuse Pool

    func updateVisibleSet(currentVisible: Set<Int>) {
        let recycled = previousVisibleIndices.subtracting(currentVisible)
        let activated = currentVisible.subtracting(previousVisibleIndices)

        for idx in recycled {
            activeViews.remove(idx)
            let key = "card"
            if reusePool[key] == nil { reusePool[key] = [] }
            reusePool[key]?.insert(idx)
            reuseStats.recycledCount += 1
        }

        for idx in activated {
            let key = "card"
            if let pool = reusePool[key], pool.contains(idx) {
                reusePool[key]?.remove(idx)
                reuseStats.totalReused += 1
            } else {
                reuseStats.totalCreated += 1
            }
            activeViews.insert(idx)
        }

        reuseStats.poolSize = reusePool.values.reduce(0) { $0 + $1.count }
        reuseStats.activeCount = activeViews.count
        previousVisibleIndices = currentVisible
    }

    func resetReuseStats() {
        reuseStats = ReuseStats()
        reusePool.removeAll()
        activeViews.removeAll()
        previousVisibleIndices.removeAll()
    }

    // MARK: - Visible Items

    func visibleItemIndices() -> [Int] {
        guard !items.isEmpty else { return [] }
        let half = config.visibleItems / 2
        let center = Int(round(currentOffset))
        var indices: [Int] = []

        for i in (center - half)...(center + half) {
            if config.isInfinite {
                indices.append(wrappedIndex(i))
            } else if i >= 0 && i < items.count {
                indices.append(i)
            }
        }
        return indices
    }

    func itemOffset(for index: Int, from center: Int) -> CGFloat {
        if config.isInfinite {
            let count = items.count
            var diff = index - wrappedIndex(center)
            if diff > count / 2 { diff -= count }
            if diff < -count / 2 { diff += count }
            return CGFloat(diff) + (currentOffset - CGFloat(center))
        } else {
            return CGFloat(index) - currentOffset
        }
    }
}
