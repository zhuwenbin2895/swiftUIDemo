import UIKit

class CYLTabBar: UITabBar {
    var customHeight: CGFloat?
    private(set) var plusButtonView: UIButton?
    private var plusButtonProvider: CYLPlusButtonProtocol?
    private var plusButtonCenterOffset: CGPoint = .zero

    func setupPlusButton(_ provider: CYLPlusButtonProtocol) {
        plusButtonProvider = provider
        plusButtonView?.removeFromSuperview()
        let button = provider.plusButton
        plusButtonView = button
        plusButtonCenterOffset = provider.plusButtonCenterOffset
        addSubview(button)
        setNeedsLayout()
    }

    func removePlusButton() {
        plusButtonView?.removeFromSuperview()
        plusButtonView = nil
        plusButtonProvider = nil
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        if let customHeight = customHeight {
            let bottomInset = safeAreaInsets.bottom
            sizeThatFits.height = customHeight + bottomInset
        }
        return sizeThatFits
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let plusButton = plusButtonView, let provider = plusButtonProvider else { return }

        let tabBarButtons = subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }
        let buttonCount = tabBarButtons.count

        let centerX = bounds.width / 2 + plusButtonCenterOffset.x
        let centerY = -provider.plusButtonHeight / 2 + bounds.height / 2 + plusButtonCenterOffset.y

        plusButton.frame = CGRect(
            x: centerX - provider.plusButtonWidth / 2,
            y: centerY - provider.plusButtonHeight / 2 + safeAreaInsets.bottom / 2,
            width: provider.plusButtonWidth,
            height: provider.plusButtonHeight
        )
        bringSubviewToFront(plusButton)

        guard buttonCount > 0 else { return }
        let totalWidth = bounds.width
        let plusButtonSpace = provider.plusButtonWidth + 4
        let availableWidth = totalWidth - plusButtonSpace
        let itemWidth = availableWidth / CGFloat(buttonCount)
        let halfCount = buttonCount / 2

        for (index, button) in tabBarButtons.enumerated() {
            var frame = button.frame
            frame.size.width = itemWidth
            if index < halfCount {
                frame.origin.x = CGFloat(index) * itemWidth
            } else {
                frame.origin.x = CGFloat(index) * itemWidth + plusButtonSpace
            }
            button.frame = frame
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden || !isUserInteractionEnabled || alpha < 0.01 {
            return super.hitTest(point, with: event)
        }

        if let plusButton = plusButtonView {
            let plusPoint = convert(point, to: plusButton)
            if plusButton.bounds.contains(plusPoint) {
                return plusButton
            }
        }

        return super.hitTest(point, with: event)
    }
}
