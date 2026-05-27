import UIKit
import ObjectiveC

private var skeletonableKey: UInt8 = 0
private var skeletonLayersKey: UInt8 = 0
private var isSkeletonActiveKey: UInt8 = 0
private var originalUserInteractionKey: UInt8 = 0
private var skeletonConfigKey: UInt8 = 0
private var multilineSkeletonLayersKey: UInt8 = 0

// MARK: - UIView Skeleton Extension
extension UIView {

    var isSkeletonable: Bool {
        get { objc_getAssociatedObject(self, &skeletonableKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &skeletonableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var isSkeletonActive: Bool {
        get { objc_getAssociatedObject(self, &isSkeletonActiveKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &isSkeletonActiveKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var skeletonLayers: [SkeletonLayer] {
        get { objc_getAssociatedObject(self, &skeletonLayersKey) as? [SkeletonLayer] ?? [] }
        set { objc_setAssociatedObject(self, &skeletonLayersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var originalUserInteractionEnabled: Bool? {
        get { objc_getAssociatedObject(self, &originalUserInteractionKey) as? Bool }
        set { objc_setAssociatedObject(self, &originalUserInteractionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var currentSkeletonConfig: SkeletonConfig? {
        get { objc_getAssociatedObject(self, &skeletonConfigKey) as? SkeletonConfig }
        set { objc_setAssociatedObject(self, &skeletonConfigKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var multilineSkeletonLayers: [SkeletonLayer] {
        get { objc_getAssociatedObject(self, &multilineSkeletonLayersKey) as? [SkeletonLayer] ?? [] }
        set { objc_setAssociatedObject(self, &multilineSkeletonLayersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - Show Skeleton

    func showSkeleton(config: SkeletonConfig = .default) {
        guard isSkeletonable else {
            showSkeletonForSubviews(config: config)
            return
        }

        isSkeletonActive = true
        currentSkeletonConfig = config

        if config.disableUserInteraction {
            originalUserInteractionEnabled = isUserInteractionEnabled
            isUserInteractionEnabled = false
        }

        layoutIfNeeded()

        if let label = self as? UILabel, config.numberOfLines > 0 || label.numberOfLines > 0 {
            showMultilineSkeleton(for: label, config: config)
        } else {
            let skeletonLayer = SkeletonLayer(holder: self, config: config)
            skeletonLayer.show()
            skeletonLayers.append(skeletonLayer)
        }

        showSkeletonForSubviews(config: config)
    }

    func showGradientSkeleton(baseColor: UIColor = .systemGray5, highlightColor: UIColor = .white, animation: SkeletonAnimationType = .shimmerLeftToRight) {
        var style = SkeletonStyle.gradient
        style.baseColor = baseColor
        style.highlightColor = highlightColor
        style.animation = animation
        var config = SkeletonConfig.default
        config.style = style
        showSkeleton(config: config)
    }

    // MARK: - Hide Skeleton

    func hideSkeleton() {
        isSkeletonActive = false

        for layer in skeletonLayers {
            layer.hide()
        }
        skeletonLayers.removeAll()

        for layer in multilineSkeletonLayers {
            layer.hide()
        }
        multilineSkeletonLayers.removeAll()

        if let original = originalUserInteractionEnabled {
            isUserInteractionEnabled = original
            originalUserInteractionEnabled = nil
        }

        hideSkeletonForSubviews()
    }

    // MARK: - Update Layout

    func updateSkeletonLayout() {
        for layer in skeletonLayers {
            layer.updateFrame()
        }
        updateSkeletonLayoutForSubviews()
    }

    // MARK: - Private Helpers

    private func showSkeletonForSubviews(config: SkeletonConfig) {
        for subview in subviews {
            if subview.isSkeletonable {
                subview.showSkeleton(config: config)
            } else {
                subview.showSkeletonForSubviews(config: config)
            }
        }
    }

    private func hideSkeletonForSubviews() {
        for subview in subviews {
            subview.hideSkeleton()
        }
    }

    private func updateSkeletonLayoutForSubviews() {
        for subview in subviews {
            subview.updateSkeletonLayout()
        }
    }

    private func showMultilineSkeleton(for label: UILabel, config: SkeletonConfig) {
        let numberOfLines = config.numberOfLines > 0 ? config.numberOfLines : max(label.numberOfLines, 1)
        let lineHeight = config.style.multilineHeight
        let spacing = config.style.multilineSpacing
        let lastLinePercent = config.style.multilineLastLinePercent

        label.text = " "
        label.backgroundColor = .clear

        for i in 0..<numberOfLines {
            let lineView = UIView()
            lineView.isSkeletonable = true

            let widthMultiplier: CGFloat = (i == numberOfLines - 1 && numberOfLines > 1) ? lastLinePercent : 1.0
            let decrementFactor: CGFloat = numberOfLines > 2 ? CGFloat(i) * 0.03 : 0
            let effectiveWidth = max(widthMultiplier - decrementFactor, 0.3)

            let y = CGFloat(i) * (lineHeight + spacing)
            let width = label.bounds.width * effectiveWidth
            lineView.frame = CGRect(x: 0, y: y, width: width, height: lineHeight)

            var lineConfig = config
            lineConfig.numberOfLines = 0
            let layer = SkeletonLayer(holder: lineView, config: lineConfig)

            label.addSubview(lineView)
            layer.show()
            multilineSkeletonLayers.append(layer)
        }
    }
}

// MARK: - UIStackView Extension
extension UIStackView {
    func showStackSkeleton(config: SkeletonConfig = .default) {
        for arrangedSubview in arrangedSubviews {
            arrangedSubview.isSkeletonable = true
            arrangedSubview.showSkeleton(config: config)
        }
    }

    func hideStackSkeleton() {
        for arrangedSubview in arrangedSubviews {
            arrangedSubview.hideSkeleton()
        }
    }
}
