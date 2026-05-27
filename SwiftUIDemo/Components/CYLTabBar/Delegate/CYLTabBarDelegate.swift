import UIKit

protocol CYLTabBarControllerDelegate: AnyObject {
    func tabBarController(_ controller: CYLTabBarController, didSelectItemAt index: Int)
    func tabBarController(_ controller: CYLTabBarController, shouldSelectItemAt index: Int) -> Bool
}

extension CYLTabBarControllerDelegate {
    func tabBarController(_ controller: CYLTabBarController, didSelectItemAt index: Int) {}
    func tabBarController(_ controller: CYLTabBarController, shouldSelectItemAt index: Int) -> Bool { true }
}
