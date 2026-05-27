import UIKit

class CYLLottieAnimationAdapter: CYLTabBarAnimationProtocol {
    private let animationName: String
    private let provider: CYLLottieAnimationProviding?
    private var animationViews: [UIImageView: UIView] = [:]

    init(animationName: String, provider: CYLLottieAnimationProviding? = nil) {
        self.animationName = animationName
        self.provider = provider
    }

    func playAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        if let provider = provider {
            let size = imageView.bounds.size
            let animView: UIView
            if let existing = animationViews[imageView] {
                animView = existing
            } else {
                animView = provider.makeAnimationView(named: animationName, size: size)
                animView.frame = imageView.bounds
                imageView.addSubview(animView)
                animationViews[imageView] = animView
            }
            animView.isHidden = false
            provider.play(view: animView)
        } else {
            let animView: CYLKeyframeAnimationView
            if let existing = animationViews[imageView] as? CYLKeyframeAnimationView {
                animView = existing
            } else {
                let size = imageView.bounds.isEmpty ? CGSize(width: 25, height: 25) : imageView.bounds.size
                animView = CYLKeyframeAnimationView(animationName: animationName, size: size)
                animView.frame = CGRect(origin: .zero, size: size)
                animView.center = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
                animView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                imageView.addSubview(animView)
                animationViews[imageView] = animView
            }
            animView.isHidden = false
            animView.play()
        }
    }

    func stopAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        if let provider = provider, let animView = animationViews[imageView] {
            provider.stop(view: animView)
            animView.isHidden = true
        } else if let animView = animationViews[imageView] as? CYLKeyframeAnimationView {
            animView.stop()
            animView.isHidden = true
        }
    }
}

// MARK: - Built-in Keyframe Animation View (Lottie-like vector animation)

class CYLKeyframeAnimationView: UIView {
    private let animationName: String
    private let shapeLayer = CAShapeLayer()
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private let duration: CFTimeInterval = 0.8
    private var animationGenerator: KeyframeGenerator

    init(animationName: String, size: CGSize) {
        self.animationName = animationName
        self.animationGenerator = Self.generatorForName(animationName, size: size)
        super.init(frame: CGRect(origin: .zero, size: size))
        backgroundColor = .clear
        setupShapeLayer(size: size)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupShapeLayer(size: CGSize) {
        shapeLayer.frame = bounds
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = tintColor.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        layer.addSublayer(shapeLayer)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        shapeLayer.strokeColor = tintColor.cgColor
    }

    func play() {
        stop()
        startTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        shapeLayer.path = nil
    }

    @objc private func tick() {
        let elapsed = CACurrentMediaTime() - startTime
        let progress = min(elapsed / duration, 1.0)

        shapeLayer.path = animationGenerator.path(at: progress)
        shapeLayer.strokeEnd = animationGenerator.strokeEnd(at: progress)
        shapeLayer.fillColor = animationGenerator.fillColor(at: progress)
        shapeLayer.transform = animationGenerator.transform(at: progress)

        if progress >= 1.0 {
            displayLink?.invalidate()
            displayLink = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.shapeLayer.path = nil
                self?.shapeLayer.transform = CATransform3DIdentity
                self?.isHidden = true
            }
        }
    }

    private static func generatorForName(_ name: String, size: CGSize) -> KeyframeGenerator {
        switch name {
        case "tab_home": return HomeKeyframeGenerator(size: size)
        case "tab_discover": return DiscoverKeyframeGenerator(size: size)
        case "tab_message": return MessageKeyframeGenerator(size: size)
        case "tab_profile": return ProfileKeyframeGenerator(size: size)
        default: return HomeKeyframeGenerator(size: size)
        }
    }
}

// MARK: - Keyframe Generator Protocol

protocol KeyframeGenerator {
    func path(at progress: Double) -> CGPath
    func strokeEnd(at progress: Double) -> CGFloat
    func fillColor(at progress: Double) -> CGColor?
    func transform(at progress: Double) -> CATransform3D
}

extension KeyframeGenerator {
    func fillColor(at progress: Double) -> CGColor? { nil }
    func transform(at progress: Double) -> CATransform3D { CATransform3DIdentity }
}

// MARK: - Home icon: house draws stroke-by-stroke then fills

struct HomeKeyframeGenerator: KeyframeGenerator {
    let size: CGSize

    func path(at progress: Double) -> CGPath {
        let path = CGMutablePath()
        let w = size.width
        let h = size.height
        let inset: CGFloat = 2

        // Roof triangle
        path.move(to: CGPoint(x: inset, y: h * 0.45))
        path.addLine(to: CGPoint(x: w / 2, y: inset))
        path.addLine(to: CGPoint(x: w - inset, y: h * 0.45))

        // Walls
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.8, y: h - inset))
        path.addLine(to: CGPoint(x: w * 0.2, y: h - inset))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.45))
        path.closeSubpath()

        return path
    }

    func strokeEnd(at progress: Double) -> CGFloat {
        CGFloat(min(progress * 1.5, 1.0))
    }

    func fillColor(at progress: Double) -> CGColor? {
        if progress > 0.6 {
            let alpha = CGFloat((progress - 0.6) / 0.4) * 0.2
            return UIColor.systemBlue.withAlphaComponent(alpha).cgColor
        }
        return nil
    }

    func transform(at progress: Double) -> CATransform3D {
        let scale = 1.0 + sin(progress * .pi) * 0.15
        return CATransform3DMakeScale(CGFloat(scale), CGFloat(scale), 1)
    }
}

// MARK: - Discover icon: compass circle + rotating needle

struct DiscoverKeyframeGenerator: KeyframeGenerator {
    let size: CGSize

    func path(at progress: Double) -> CGPath {
        let path = CGMutablePath()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2 - 2

        // Circle
        path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))

        // Needle (rotates with progress)
        let angle = progress * .pi * 2
        let needleLen = radius * 0.6
        let dx = CGFloat(cos(angle)) * needleLen
        let dy = CGFloat(sin(angle)) * needleLen
        path.move(to: CGPoint(x: center.x - dx * 0.3, y: center.y - dy * 0.3))
        path.addLine(to: CGPoint(x: center.x + dx, y: center.y + dy))

        // Diamond needle tip
        let tipSize: CGFloat = 4
        let tipAngle = angle + .pi / 2
        let tipDx = CGFloat(cos(tipAngle)) * tipSize
        let tipDy = CGFloat(sin(tipAngle)) * tipSize
        let tipEnd = CGPoint(x: center.x + dx, y: center.y + dy)
        path.move(to: CGPoint(x: tipEnd.x + tipDx, y: tipEnd.y + tipDy))
        path.addLine(to: CGPoint(x: tipEnd.x + CGFloat(cos(angle)) * tipSize, y: tipEnd.y + CGFloat(sin(angle)) * tipSize))
        path.addLine(to: CGPoint(x: tipEnd.x - tipDx, y: tipEnd.y - tipDy))
        path.closeSubpath()

        return path
    }

    func strokeEnd(at progress: Double) -> CGFloat { 1.0 }

    func transform(at progress: Double) -> CATransform3D {
        let bounce = 1.0 + sin(progress * .pi) * 0.1
        return CATransform3DMakeScale(CGFloat(bounce), CGFloat(bounce), 1)
    }
}

// MARK: - Message icon: speech bubble with typing dots

struct MessageKeyframeGenerator: KeyframeGenerator {
    let size: CGSize

    func path(at progress: Double) -> CGPath {
        let path = CGMutablePath()
        let w = size.width
        let h = size.height
        let inset: CGFloat = 2

        // Rounded rectangle bubble
        let bubbleRect = CGRect(x: inset, y: inset, width: w - inset * 2, height: h * 0.7)
        path.addRoundedRect(in: bubbleRect, cornerWidth: 4, cornerHeight: 4)

        // Tail
        path.move(to: CGPoint(x: w * 0.25, y: bubbleRect.maxY))
        path.addLine(to: CGPoint(x: w * 0.15, y: h - inset))
        path.addLine(to: CGPoint(x: w * 0.4, y: bubbleRect.maxY))

        // Typing dots with wave animation
        let dotRadius: CGFloat = 2
        let centerY = bubbleRect.midY
        for i in 0..<3 {
            let phase = progress * .pi * 2 - Double(i) * 0.5
            let offsetY = CGFloat(sin(phase)) * 3
            let cx = w * (0.3 + CGFloat(i) * 0.15)
            path.addEllipse(in: CGRect(x: cx - dotRadius, y: centerY - dotRadius + offsetY, width: dotRadius * 2, height: dotRadius * 2))
        }

        return path
    }

    func strokeEnd(at progress: Double) -> CGFloat { 1.0 }

    func fillColor(at progress: Double) -> CGColor? {
        let alpha = CGFloat(sin(progress * .pi)) * 0.15
        return UIColor.systemBlue.withAlphaComponent(alpha).cgColor
    }

    func transform(at progress: Double) -> CATransform3D {
        let scale = 1.0 + sin(progress * .pi) * 0.12
        return CATransform3DMakeScale(CGFloat(scale), CGFloat(scale), 1)
    }
}

// MARK: - Profile icon: person silhouette with pulse

struct ProfileKeyframeGenerator: KeyframeGenerator {
    let size: CGSize

    func path(at progress: Double) -> CGPath {
        let path = CGMutablePath()
        let w = size.width
        let h = size.height
        let centerX = w / 2

        // Head circle
        let headRadius = w * 0.18
        let headCenter = CGPoint(x: centerX, y: h * 0.3)
        path.addEllipse(in: CGRect(x: headCenter.x - headRadius, y: headCenter.y - headRadius, width: headRadius * 2, height: headRadius * 2))

        // Body arc
        let bodyTop = h * 0.55
        path.move(to: CGPoint(x: w * 0.2, y: h - 2))
        path.addQuadCurve(to: CGPoint(x: w * 0.8, y: h - 2), control: CGPoint(x: centerX, y: bodyTop))

        // Pulse ring expanding
        let pulseRadius = w * 0.4 * CGFloat(progress)
        if progress > 0.2 {
            path.addEllipse(in: CGRect(x: centerX - pulseRadius, y: headCenter.y - pulseRadius, width: pulseRadius * 2, height: pulseRadius * 2))
        }

        return path
    }

    func strokeEnd(at progress: Double) -> CGFloat { 1.0 }

    func transform(at progress: Double) -> CATransform3D {
        let scale = 1.0 + sin(progress * .pi * 2) * 0.08
        return CATransform3DMakeScale(CGFloat(scale), CGFloat(scale), 1)
    }
}
