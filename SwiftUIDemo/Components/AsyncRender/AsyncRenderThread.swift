import Foundation
import UIKit

// MARK: - Thread Model

final class AsyncRenderScheduler {
    static let shared = AsyncRenderScheduler()

    let layoutQueue = DispatchQueue(label: "com.panda.layout", qos: .userInitiated, attributes: .concurrent)
    let renderQueue = DispatchQueue(label: "com.panda.render", qos: .userInitiated, attributes: .concurrent)
    let imageQueue = DispatchQueue(label: "com.panda.image", qos: .utility, attributes: .concurrent)

    private var isPaused = false
    private var pendingTasks: [() -> Void] = []
    private let lock = NSLock()

    func performLayout(_ work: @escaping () -> Void, completion: @escaping () -> Void) {
        layoutQueue.async {
            work()
            DispatchQueue.main.async { completion() }
        }
    }

    func performRender(_ work: @escaping () -> CGImage?, completion: @escaping (CGImage?) -> Void) {
        guard !isPaused else {
            lock.lock()
            pendingTasks.append { [weak self] in
                self?.performRender(work, completion: completion)
            }
            lock.unlock()
            return
        }
        renderQueue.async {
            let image = work()
            DispatchQueue.main.async { completion(image) }
        }
    }

    func performImageProcess(_ work: @escaping () -> UIImage?, completion: @escaping (UIImage?) -> Void) {
        imageQueue.async {
            let image = work()
            DispatchQueue.main.async { completion(image) }
        }
    }

    func pause() {
        isPaused = true
    }

    func resume() {
        isPaused = false
        lock.lock()
        let tasks = pendingTasks
        pendingTasks.removeAll()
        lock.unlock()
        tasks.forEach { $0() }
    }
}

// MARK: - RunLoop Idle Task

final class RunLoopIdleExecutor {
    static let shared = RunLoopIdleExecutor()

    private var tasks: [() -> Void] = []
    private var observer: CFRunLoopObserver?
    private let lock = NSLock()

    init() {
        setupObserver()
    }

    private func setupObserver() {
        let activity: CFRunLoopActivity = [.beforeWaiting, .exit]
        observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, activity.rawValue, true, Int.max) { [weak self] _, _ in
            self?.executePendingTasks()
        }
        if let observer = observer {
            CFRunLoopAddObserver(CFRunLoopGetMain(), observer, .defaultMode)
        }
    }

    func addTask(_ task: @escaping () -> Void) {
        lock.lock()
        tasks.append(task)
        lock.unlock()
    }

    private func executePendingTasks() {
        lock.lock()
        guard !tasks.isEmpty else {
            lock.unlock()
            return
        }
        let task = tasks.removeFirst()
        lock.unlock()
        task()
    }

    deinit {
        if let observer = observer {
            CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, .defaultMode)
        }
    }
}

// MARK: - Async Rounded Corner

final class AsyncCornerRadiusProcessor {
    static func processImage(_ image: UIImage, cornerRadius: CGFloat, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        AsyncRenderScheduler.shared.performImageProcess {
            let rect = CGRect(origin: .zero, size: size)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            context.addPath(path.cgPath)
            context.clip()
            image.draw(in: rect)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        } completion: { result in
            completion(result)
        }
    }
}
