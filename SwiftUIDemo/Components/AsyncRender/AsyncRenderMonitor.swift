import Foundation
import UIKit
import QuartzCore
import Combine

// MARK: - Render Monitor

final class AsyncRenderMonitor: ObservableObject {
    static let shared = AsyncRenderMonitor()

    @Published var currentFPS: Int = 60
    @Published var renderLogs: [RenderLog] = []
    @Published var isMonitoring = false

    private var displayLink: CADisplayLink?
    private var lastTimestamp: TimeInterval = 0
    private var frameCount: Int = 0
    private let maxLogs = 200

    struct RenderLog: Identifiable {
        let id = UUID()
        let timestamp: TimeInterval
        let taskName: String
        let duration: TimeInterval
        let thread: String

        var formattedDuration: String {
            String(format: "%.2fms", duration * 1000)
        }

        var isWarning: Bool {
            duration > 0.016
        }
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
        lastTimestamp = 0
        frameCount = 0
    }

    func stopMonitoring() {
        isMonitoring = false
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp

        if elapsed >= 1.0 {
            let fps = Int(Double(frameCount) / elapsed)
            DispatchQueue.main.async { [weak self] in
                self?.currentFPS = fps
            }
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }

    func logRender(taskName: String, startTime: TimeInterval) {
        let duration = CACurrentMediaTime() - startTime
        let threadName = Thread.isMainThread ? "Main" : "BG-\(Thread.current.name ?? "unknown")"
        let log = RenderLog(timestamp: CACurrentMediaTime(), taskName: taskName, duration: duration, thread: threadName)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.renderLogs.insert(log, at: 0)
            if self.renderLogs.count > self.maxLogs {
                self.renderLogs = Array(self.renderLogs.prefix(self.maxLogs))
            }
        }
    }

    func measureBlock(name: String, work: () -> Void) {
        let start = CACurrentMediaTime()
        work()
        logRender(taskName: name, startTime: start)
    }

    func measureAsync(name: String, work: @escaping (@escaping () -> Void) -> Void) {
        let start = CACurrentMediaTime()
        work { [weak self] in
            self?.logRender(taskName: name, startTime: start)
        }
    }

    func clearLogs() {
        renderLogs.removeAll()
    }
}

// MARK: - FPS Label (UIKit)

final class FPSLabel: UILabel {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: TimeInterval = 0
    private var frameCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        textAlignment = .center
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        textColor = .green
        layer.cornerRadius = 4
        clipsToBounds = true

        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func tick(_ link: CADisplayLink) {
        guard lastTimestamp > 0 else {
            lastTimestamp = link.timestamp
            return
        }
        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp
        if elapsed >= 0.5 {
            let fps = Int(Double(frameCount) / elapsed)
            text = " \(fps) FPS "
            textColor = fps >= 55 ? .green : (fps >= 30 ? .yellow : .red)
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }

    deinit {
        displayLink?.invalidate()
    }
}
