import SwiftUI
import Combine

class SlideMenuManager: ObservableObject {
    @Published var menuState: SlideMenuState = .closed
    @Published var dragOffset: CGFloat = 0
    @Published var mainViewScale: CGFloat = 1.0
    @Published var overlayOpacity: CGFloat = 0
    @Published var isDragging: Bool = false

    var config: SlideMenuConfig
    var callbacks: SlideMenuCallbacks

    private var cancellables = Set<AnyCancellable>()

    init(config: SlideMenuConfig = SlideMenuConfig(), callbacks: SlideMenuCallbacks = SlideMenuCallbacks()) {
        self.config = config
        self.callbacks = callbacks
    }

    // MARK: - Computed Properties

    var isMenuOpen: Bool {
        menuState != .closed
    }

    var isLeftOpen: Bool {
        if case .leftOpen = menuState { return true }
        if case .leftPartial = menuState { return true }
        return false
    }

    var isRightOpen: Bool {
        if case .rightOpen = menuState { return true }
        if case .rightPartial = menuState { return true }
        return false
    }

    var currentProgress: CGFloat {
        switch menuState {
        case .closed:
            return 0
        case .leftOpen, .rightOpen:
            return 1.0
        case .leftPartial(let p), .rightPartial(let p):
            return p
        }
    }

    // MARK: - Public Actions

    func openLeft(animated: Bool = true) {
        callbacks.onMenuWillOpen?(.left)
        withAnimation(animated ? springAnimation : .none) {
            menuState = .leftOpen
            dragOffset = config.leftMenuWidth
            mainViewScale = config.mainViewScale
            overlayOpacity = config.overlayMaxOpacity
        }
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) { [weak self] in
                self?.callbacks.onMenuDidOpen?(.left)
            }
        } else {
            callbacks.onMenuDidOpen?(.left)
        }
    }

    func openRight(animated: Bool = true) {
        guard config.enableRightMenu else { return }
        callbacks.onMenuWillOpen?(.right)
        withAnimation(animated ? springAnimation : .none) {
            menuState = .rightOpen
            dragOffset = -config.rightMenuWidth
            mainViewScale = config.mainViewScale
            overlayOpacity = config.overlayMaxOpacity
        }
        if animated {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) { [weak self] in
                self?.callbacks.onMenuDidOpen?(.right)
            }
        } else {
            callbacks.onMenuDidOpen?(.right)
        }
    }

    func openLeftPartial(stop: CGFloat) {
        let clampedStop = min(max(stop, 0), 1.0)
        callbacks.onMenuWillOpen?(.left)
        withAnimation(springAnimation) {
            menuState = .leftPartial(clampedStop)
            dragOffset = config.leftMenuWidth * clampedStop
            mainViewScale = 1.0 - (1.0 - config.mainViewScale) * clampedStop
            overlayOpacity = config.overlayMaxOpacity * clampedStop
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) { [weak self] in
            self?.callbacks.onMenuDidOpen?(.left)
        }
    }

    func openRightPartial(stop: CGFloat) {
        guard config.enableRightMenu else { return }
        let clampedStop = min(max(stop, 0), 1.0)
        callbacks.onMenuWillOpen?(.right)
        withAnimation(springAnimation) {
            menuState = .rightPartial(clampedStop)
            dragOffset = -config.rightMenuWidth * clampedStop
            mainViewScale = 1.0 - (1.0 - config.mainViewScale) * clampedStop
            overlayOpacity = config.overlayMaxOpacity * clampedStop
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) { [weak self] in
            self?.callbacks.onMenuDidOpen?(.right)
        }
    }

    func close(animated: Bool = true) {
        let side: SlideMenuSide = dragOffset >= 0 ? .left : .right
        callbacks.onMenuWillClose?(side)

        if animated && config.enableBounceEffect {
            withAnimation(.spring(response: config.springResponse, dampingFraction: config.springDamping)) {
                dragOffset = 0
                mainViewScale = 1.0
                overlayOpacity = 0
                menuState = .closed
            }
        } else if animated {
            withAnimation(.easeInOut(duration: config.animationDuration)) {
                dragOffset = 0
                mainViewScale = 1.0
                overlayOpacity = 0
                menuState = .closed
            }
        } else {
            dragOffset = 0
            mainViewScale = 1.0
            overlayOpacity = 0
            menuState = .closed
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (animated ? config.animationDuration : 0)) { [weak self] in
            self?.callbacks.onMenuDidClose?(side)
        }
    }

    func toggle(side: SlideMenuSide) {
        switch side {
        case .left:
            isLeftOpen ? close() : openLeft()
        case .right:
            isRightOpen ? close() : openRight()
        }
    }

    // MARK: - Gesture Handling

    func handleDragChanged(value: DragGesture.Value, screenWidth: CGFloat) {
        let translation = value.translation.width
        isDragging = true
        callbacks.onGesturePhaseChanged?(.changed(progress: abs(translation) / config.leftMenuWidth))

        if isMenuOpen {
            handleOpenMenuDrag(translation: translation)
        } else {
            handleClosedMenuDrag(translation: translation, startX: value.startLocation.x, screenWidth: screenWidth)
        }
    }

    func handleDragEnded(value: DragGesture.Value) {
        isDragging = false
        let velocity = value.predictedEndTranslation.width - value.translation.width
        callbacks.onGesturePhaseChanged?(.ended(velocity: velocity))

        let translation = value.translation.width
        let speed = abs(velocity)

        if isLeftOpen || dragOffset > 0 {
            if speed > config.velocityThreshold && translation < 0 {
                close()
            } else if dragOffset > config.leftMenuWidth * config.progressThreshold {
                snapToNearestStop(side: .left)
            } else {
                close()
            }
        } else if isRightOpen || dragOffset < 0 {
            if speed > config.velocityThreshold && translation > 0 {
                close()
            } else if abs(dragOffset) > config.rightMenuWidth * config.progressThreshold {
                snapToNearestStop(side: .right)
            } else {
                close()
            }
        } else {
            if speed > config.velocityThreshold {
                if translation > 0 && config.enableLeftMenu {
                    openLeft()
                } else if translation < 0 && config.enableRightMenu {
                    openRight()
                } else {
                    close()
                }
            } else if translation > 0 && abs(translation) > config.leftMenuWidth * config.progressThreshold && config.enableLeftMenu {
                openLeft()
            } else if translation < 0 && abs(translation) > config.rightMenuWidth * config.progressThreshold && config.enableRightMenu {
                openRight()
            } else {
                close()
            }
        }
    }

    // MARK: - Private Helpers

    private var springAnimation: Animation {
        .spring(response: config.springResponse, dampingFraction: config.springDamping)
    }

    private func handleOpenMenuDrag(translation: CGFloat) {
        if isLeftOpen {
            let newOffset = config.leftMenuWidth + translation
            let clamped = max(0, min(newOffset, config.leftMenuWidth + (config.enableBounceEffect ? config.bounceDistance : 0)))
            dragOffset = clamped
            let progress = clamped / config.leftMenuWidth
            mainViewScale = 1.0 - (1.0 - config.mainViewScale) * min(progress, 1.0)
            overlayOpacity = config.overlayMaxOpacity * min(progress, 1.0)
        } else if isRightOpen {
            let newOffset = -config.rightMenuWidth + translation
            let clamped = min(0, max(newOffset, -(config.rightMenuWidth + (config.enableBounceEffect ? config.bounceDistance : 0))))
            dragOffset = clamped
            let progress = abs(clamped) / config.rightMenuWidth
            mainViewScale = 1.0 - (1.0 - config.mainViewScale) * min(progress, 1.0)
            overlayOpacity = config.overlayMaxOpacity * min(progress, 1.0)
        }
    }

    private func handleClosedMenuDrag(translation: CGFloat, startX: CGFloat, screenWidth: CGFloat) {
        let isFromLeftEdge = startX < config.edgeTriggerWidth
        let isFromRightEdge = startX > screenWidth - config.edgeTriggerWidth

        if translation > 0 && config.enableLeftMenu && isFromLeftEdge {
            let maxOffset = config.leftMenuWidth + (config.enableBounceEffect ? config.bounceDistance : 0)
            dragOffset = min(translation, maxOffset)
            let progress = min(dragOffset / config.leftMenuWidth, 1.0)
            mainViewScale = 1.0 - (1.0 - config.mainViewScale) * progress
            overlayOpacity = config.overlayMaxOpacity * progress
        } else if translation < 0 && config.enableRightMenu && isFromRightEdge {
            let maxOffset = config.rightMenuWidth + (config.enableBounceEffect ? config.bounceDistance : 0)
            dragOffset = max(translation, -maxOffset)
            let progress = min(abs(dragOffset) / config.rightMenuWidth, 1.0)
            mainViewScale = 1.0 - (1.0 - config.mainViewScale) * progress
            overlayOpacity = config.overlayMaxOpacity * progress
        }
    }

    private func snapToNearestStop(side: SlideMenuSide) {
        let menuWidth = side == .left ? config.leftMenuWidth : config.rightMenuWidth
        let currentProgress = abs(dragOffset) / menuWidth
        let stops = config.partialStops.sorted()

        var nearestStop: CGFloat = 1.0
        var minDistance: CGFloat = .greatestFiniteMagnitude

        for stop in stops {
            let distance = abs(currentProgress - stop)
            if distance < minDistance {
                minDistance = distance
                nearestStop = stop
            }
        }

        if nearestStop >= 0.95 {
            side == .left ? openLeft() : openRight()
        } else {
            side == .left ? openLeftPartial(stop: nearestStop) : openRightPartial(stop: nearestStop)
        }
    }
}
