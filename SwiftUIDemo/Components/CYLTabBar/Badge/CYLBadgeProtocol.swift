import UIKit

protocol CYLBadgeViewProtocol: UIView {
    func updateBadge(value: String?)
    func showRedDot(_ show: Bool)
    func setCustomView(_ view: UIView?)
    func reset()
}
