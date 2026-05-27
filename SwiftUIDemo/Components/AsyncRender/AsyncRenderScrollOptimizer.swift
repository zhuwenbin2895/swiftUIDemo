import Foundation
import UIKit

// MARK: - Scroll State

enum ScrollState {
    case idle
    case dragging
    case decelerating
}

// MARK: - Preload Calculator

final class PreloadAreaCalculator {
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    var preloadMultiplier: CGFloat = 1.5

    func visibleRange(offset: CGFloat) -> ClosedRange<CGFloat> {
        return offset...(offset + screenHeight)
    }

    func preloadRange(offset: CGFloat, velocity: CGFloat) -> ClosedRange<CGFloat> {
        let preloadDistance = screenHeight * preloadMultiplier
        let directionBias = velocity > 0 ? preloadDistance : -preloadDistance

        let lower = offset - preloadDistance + min(directionBias, 0)
        let upper = offset + screenHeight + preloadDistance + max(directionBias, 0)
        return max(0, lower)...upper
    }

    func shouldPreload(itemFrame: CGRect, scrollOffset: CGFloat, velocity: CGFloat) -> Bool {
        let range = preloadRange(offset: scrollOffset, velocity: velocity)
        return itemFrame.maxY >= range.lowerBound && itemFrame.minY <= range.upperBound
    }
}

// MARK: - Scroll Optimizer

final class AsyncScrollOptimizer: NSObject {
    static let shared = AsyncScrollOptimizer()

    private(set) var scrollState: ScrollState = .idle
    private(set) var velocity: CGFloat = 0
    private var lastOffset: CGFloat = 0
    private var lastTime: TimeInterval = 0

    let preloadCalculator = PreloadAreaCalculator()
    var onStateChanged: ((ScrollState) -> Void)?

    func scrollViewWillBeginDragging(offset: CGFloat) {
        scrollState = .dragging
        AsyncRenderScheduler.shared.pause()
        onStateChanged?(.dragging)
    }

    func scrollViewDidScroll(offset: CGFloat) {
        let now = CACurrentMediaTime()
        if lastTime > 0 {
            let dt = now - lastTime
            if dt > 0 {
                velocity = (offset - lastOffset) / CGFloat(dt)
            }
        }
        lastOffset = offset
        lastTime = now
    }

    func scrollViewDidEndDragging(willDecelerate: Bool) {
        if !willDecelerate {
            scrollDidStop()
        }
    }

    func scrollViewDidEndDecelerating() {
        scrollDidStop()
    }

    func scrollViewWillBeginDecelerating() {
        scrollState = .decelerating
        onStateChanged?(.decelerating)
    }

    private func scrollDidStop() {
        scrollState = .idle
        velocity = 0
        AsyncRenderScheduler.shared.resume()
        onStateChanged?(.idle)
    }
}

// MARK: - Scroll Priority Manager

final class ScrollPriorityManager {
    enum TaskPriority: Int, Comparable {
        case critical = 0
        case high = 1
        case normal = 2
        case low = 3

        static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        var label: String {
            switch self {
            case .critical: return "关键"
            case .high: return "高优"
            case .normal: return "普通"
            case .low: return "低优"
            }
        }
    }

    struct PrioritizedTask {
        let priority: TaskPriority
        let name: String
        let work: () -> Void
    }

    private(set) var taskQueue: [PrioritizedTask] = []
    private let lock = NSLock()
    var autoProcess: Bool = true

    var pendingCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return taskQueue.count
    }

    func enqueue(priority: TaskPriority, name: String = "", work: @escaping () -> Void) {
        lock.lock()
        taskQueue.append(PrioritizedTask(priority: priority, name: name, work: work))
        taskQueue.sort { $0.priority < $1.priority }
        lock.unlock()

        if autoProcess {
            processNext()
        }
    }

    func processForScrollState(_ state: ScrollState) -> [String] {
        let maxPriority: TaskPriority
        switch state {
        case .idle: maxPriority = .low
        case .dragging: maxPriority = .critical
        case .decelerating: maxPriority = .high
        }

        lock.lock()
        let eligible = taskQueue.filter { $0.priority <= maxPriority }
        let skipped = taskQueue.filter { $0.priority > maxPriority }
        taskQueue.removeAll { $0.priority <= maxPriority }
        lock.unlock()

        eligible.forEach { $0.work() }

        return skipped.map { "[\($0.priority.label)] \($0.name) - 被跳过" }
    }

    func drainAll() {
        lock.lock()
        let all = taskQueue
        taskQueue.removeAll()
        lock.unlock()
        all.forEach { $0.work() }
    }

    private func processNext() {
        lock.lock()
        guard !taskQueue.isEmpty else {
            lock.unlock()
            return
        }
        let task = taskQueue.removeFirst()
        lock.unlock()

        RunLoopIdleExecutor.shared.addTask(task.work)
    }
}
