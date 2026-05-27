import SwiftUI
import Combine

@MainActor
final class PopupManager: ObservableObject {
    @Published var currentPopup: PopupItem?
    @Published var isPresented: Bool = false

    private var queue: [PopupItem] = []
    private var isAnimating = false

    func show(_ config: PopupConfig) {
        let item = PopupItem(config: config)
        if currentPopup != nil || isAnimating {
            queue.append(item)
        } else {
            present(item)
        }
    }

    func dismiss() {
        guard currentPopup != nil else { return }
        isAnimating = true
        withAnimation(dismissAnimation) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.currentPopup = nil
            self?.isAnimating = false
            self?.showNext()
        }
    }

    private func present(_ item: PopupItem) {
        currentPopup = item
        isAnimating = true
        withAnimation(presentAnimation(for: item.config.animation)) {
            isPresented = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.isAnimating = false
        }
    }

    private func showNext() {
        guard !queue.isEmpty else { return }
        let next = queue.removeFirst()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.present(next)
        }
    }

    private func presentAnimation(for type: PopupAnimation) -> Animation {
        switch type {
        case .slideFromBottom:
            return .easeOut(duration: 0.3)
        case .fadeScale:
            return .easeInOut(duration: 0.25)
        case .spring:
            return .spring(response: 0.4, dampingFraction: 0.7)
        }
    }

    private var dismissAnimation: Animation {
        .easeIn(duration: 0.25)
    }

    var queueCount: Int { queue.count }
}
