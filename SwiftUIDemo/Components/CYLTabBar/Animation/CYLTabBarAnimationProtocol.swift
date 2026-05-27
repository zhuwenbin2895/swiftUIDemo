import UIKit

protocol CYLTabBarAnimationProtocol {
    func playAnimation(on imageView: UIImageView, in tabBar: UITabBar)
    func stopAnimation(on imageView: UIImageView, in tabBar: UITabBar)
}

protocol CYLLottieAnimationProviding {
    func makeAnimationView(named: String, size: CGSize) -> UIView
    func play(view: UIView)
    func stop(view: UIView)
}
