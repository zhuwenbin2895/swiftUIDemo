import SwiftUI
import Combine

@MainActor
final class ProgressHUDManager: ObservableObject {
    @Published var isVisible = false
    @Published var mode: HUDMode = .spinner
    @Published var state: HUDState = .loading
    @Published var title: String?
    @Published var subtitle: String?
    @Published var progress: Double = 0
    @Published var config = HUDConfig()

    private var hideWorkItem: DispatchWorkItem?
    private var showTime: Date?
    private var graceTimer: Timer?
    private var graceElapsed = false
    private var pendingHideDelay: TimeInterval?

    func show(
        mode: HUDMode = .spinner,
        state: HUDState = .loading,
        title: String? = nil,
        subtitle: String? = nil,
        config: HUDConfig? = nil
    ) {
        let config = config ?? HUDConfig()
        hideWorkItem?.cancel()
        hideWorkItem = nil
        graceTimer?.invalidate()
        graceTimer = nil
        pendingHideDelay = nil

        self.mode = mode
        self.state = state
        self.title = title
        self.subtitle = subtitle
        self.progress = 0
        self.config = config
        self.graceElapsed = false

        let grace = config.gracePeriod
        if grace > 0 {
            let timer = Timer.scheduledTimer(withTimeInterval: grace, repeats: false) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.graceTimer = nil
                    self.graceElapsed = true
                    self.showTime = Date()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isVisible = true
                    }
                    if let pending = self.pendingHideDelay {
                        self.pendingHideDelay = nil
                        self.scheduleHide(delay: pending)
                    }
                }
            }
            graceTimer = timer
        } else {
            graceElapsed = true
            showTime = Date()
            withAnimation(.easeInOut(duration: 0.2)) {
                isVisible = true
            }
        }
    }

    func hide(afterDelay delay: TimeInterval = 0) {
        hideWorkItem?.cancel()
        hideWorkItem = nil

        if !graceElapsed {
            if delay > 0 {
                pendingHideDelay = delay
            } else {
                graceTimer?.invalidate()
                graceTimer = nil
                pendingHideDelay = nil
            }
            return
        }

        scheduleHide(delay: delay)
    }

    func updateProgress(_ value: Double) {
        progress = min(max(value, 0), 1)
    }

    private func scheduleHide(delay: TimeInterval) {
        let elapsed = Date().timeIntervalSince(showTime ?? Date())
        let remaining = max(0, config.minShowTime - elapsed)
        let totalDelay = remaining + delay

        if totalDelay <= 0 {
            performHide()
        } else {
            let workItem = DispatchWorkItem { [weak self] in
                MainActor.assumeIsolated {
                    self?.performHide()
                }
            }
            hideWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay, execute: workItem)
        }
    }

    private func performHide() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isVisible = false
        }
        hideWorkItem = nil
        showTime = nil
    }
}
