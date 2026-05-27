import UIKit

protocol CYLPlusButtonProtocol: AnyObject {
    var plusButton: UIButton { get }
    var plusButtonWidth: CGFloat { get }
    var plusButtonHeight: CGFloat { get }
    var plusButtonCenterOffset: CGPoint { get }
    var tabBarItemAttachedController: UIViewController? { get }
    func plusButtonClicked(_ sender: UIButton)
}

extension CYLPlusButtonProtocol {
    var plusButtonWidth: CGFloat { 56 }
    var plusButtonHeight: CGFloat { 56 }
    var plusButtonCenterOffset: CGPoint { .zero }
    var tabBarItemAttachedController: UIViewController? { nil }
}
