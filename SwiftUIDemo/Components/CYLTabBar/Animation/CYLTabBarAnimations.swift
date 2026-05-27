import UIKit

struct CYLBounceAnimation: CYLTabBarAnimationProtocol {
    func playAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = 0.5
        bounceAnimation.calculationMode = .cubic
        imageView.layer.add(bounceAnimation, forKey: "bounce")
    }

    func stopAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        imageView.layer.removeAnimation(forKey: "bounce")
    }
}

struct CYLRotationAnimation: CYLTabBarAnimationProtocol {
    func playAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 0.5
        rotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        imageView.layer.add(rotation, forKey: "rotation")
    }

    func stopAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        imageView.layer.removeAnimation(forKey: "rotation")
    }
}

struct CYLScaleAnimation: CYLTabBarAnimationProtocol {
    func playAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            imageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5) {
                imageView.transform = .identity
            }
        }
    }

    func stopAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        imageView.transform = .identity
    }
}

struct CYLShakeAnimation: CYLTabBarAnimationProtocol {
    func playAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        let shake = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        shake.values = [0, -0.15, 0.15, -0.1, 0.1, -0.05, 0.05, 0]
        shake.duration = 0.4
        shake.calculationMode = .cubic
        imageView.layer.add(shake, forKey: "shake")
    }

    func stopAnimation(on imageView: UIImageView, in tabBar: UITabBar) {
        imageView.layer.removeAnimation(forKey: "shake")
    }
}
