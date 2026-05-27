import UIKit

class SkeletonLayer {
    private weak var holder: UIView?
    private var skeletonLayer: CAGradientLayer?
    private var animationLayer: CAGradientLayer?
    private let config: SkeletonConfig

    init(holder: UIView, config: SkeletonConfig) {
        self.holder = holder
        self.config = config
    }

    func show() {
        guard let holder = holder else { return }

        let baseLayer = CAGradientLayer()
        baseLayer.frame = holder.bounds
        baseLayer.colors = [config.style.baseColor.cgColor, config.style.baseColor.cgColor]
        baseLayer.startPoint = CGPoint(x: 0, y: 0.5)
        baseLayer.endPoint = CGPoint(x: 1, y: 0.5)

        applyShape(to: baseLayer, in: holder)
        holder.layer.addSublayer(baseLayer)
        self.skeletonLayer = baseLayer

        if config.style.animation != .none {
            addAnimation(to: baseLayer)
        }
    }

    func hide() {
        animationLayer?.removeAllAnimations()
        animationLayer?.removeFromSuperlayer()
        skeletonLayer?.removeAllAnimations()
        skeletonLayer?.removeFromSuperlayer()
        animationLayer = nil
        skeletonLayer = nil
    }

    func updateFrame() {
        guard let holder = holder else { return }
        skeletonLayer?.frame = holder.bounds
        animationLayer?.frame = holder.bounds
        applyShape(to: skeletonLayer, in: holder)
    }

    private func applyShape(to layer: CAGradientLayer?, in view: UIView) {
        guard let layer = layer else { return }
        switch config.style.shape {
        case .rectangle:
            layer.cornerRadius = config.style.cornerRadius
        case .circle:
            layer.cornerRadius = min(view.bounds.width, view.bounds.height) / 2
        case .roundedRect(let radius):
            layer.cornerRadius = radius
        }
        layer.masksToBounds = true
    }

    private func addAnimation(to baseLayer: CAGradientLayer) {
        switch config.style.animation {
        case .none:
            break
        case .shimmerLeftToRight:
            addShimmerAnimation(to: baseLayer, direction: .leftToRight)
        case .shimmerRightToLeft:
            addShimmerAnimation(to: baseLayer, direction: .rightToLeft)
        case .shimmerTopToBottom:
            addShimmerAnimation(to: baseLayer, direction: .topToBottom)
        case .gradientFade:
            addGradientFadeAnimation(to: baseLayer)
        case .pulse:
            addPulseAnimation(to: baseLayer)
        }
    }

    private enum ShimmerDirection {
        case leftToRight, rightToLeft, topToBottom
    }

    private func addShimmerAnimation(to baseLayer: CAGradientLayer, direction: ShimmerDirection) {
        let shimmerLayer = CAGradientLayer()
        shimmerLayer.frame = baseLayer.bounds

        let baseColor = config.style.baseColor
        let highlightColor = config.style.highlightColor

        shimmerLayer.colors = [
            baseColor.cgColor,
            highlightColor.cgColor,
            baseColor.cgColor
        ]
        shimmerLayer.locations = [0.0, 0.5, 1.0]

        switch direction {
        case .leftToRight:
            shimmerLayer.startPoint = CGPoint(x: -1, y: 0.5)
            shimmerLayer.endPoint = CGPoint(x: 2, y: 0.5)
        case .rightToLeft:
            shimmerLayer.startPoint = CGPoint(x: 2, y: 0.5)
            shimmerLayer.endPoint = CGPoint(x: -1, y: 0.5)
        case .topToBottom:
            shimmerLayer.startPoint = CGPoint(x: 0.5, y: -1)
            shimmerLayer.endPoint = CGPoint(x: 0.5, y: 2)
        }

        applyShape(to: shimmerLayer, in: baseLayer.bounds.size)
        baseLayer.addSublayer(shimmerLayer)
        animationLayer = shimmerLayer

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = config.animationDuration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        shimmerLayer.add(animation, forKey: "shimmer")
    }

    private func addGradientFadeAnimation(to baseLayer: CAGradientLayer) {
        baseLayer.colors = [
            config.style.baseColor.cgColor,
            config.style.highlightColor.cgColor
        ]
        baseLayer.startPoint = CGPoint(x: 0, y: 0)
        baseLayer.endPoint = CGPoint(x: 1, y: 1)

        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = [
            config.style.baseColor.cgColor,
            config.style.highlightColor.cgColor
        ]
        animation.toValue = [
            config.style.highlightColor.cgColor,
            config.style.baseColor.cgColor
        ]
        animation.duration = config.animationDuration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        baseLayer.add(animation, forKey: "gradientFade")
    }

    private func addPulseAnimation(to baseLayer: CAGradientLayer) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.4
        animation.duration = config.animationDuration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        baseLayer.add(animation, forKey: "pulse")
    }

    private func applyShape(to layer: CAGradientLayer?, in size: CGSize) {
        guard let layer = layer else { return }
        switch config.style.shape {
        case .rectangle:
            layer.cornerRadius = config.style.cornerRadius
        case .circle:
            layer.cornerRadius = min(size.width, size.height) / 2
        case .roundedRect(let radius):
            layer.cornerRadius = radius
        }
        layer.masksToBounds = true
    }
}
