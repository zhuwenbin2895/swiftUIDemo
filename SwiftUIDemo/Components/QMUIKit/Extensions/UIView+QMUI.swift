import UIKit

// MARK: - Frame Convenience Properties

extension UIView {
    var qmui_x: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }

    var qmui_y: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    var qmui_width: CGFloat {
        get { frame.size.width }
        set { frame.size.width = newValue }
    }

    var qmui_height: CGFloat {
        get { frame.size.height }
        set { frame.size.height = newValue }
    }

    var qmui_right: CGFloat {
        get { frame.origin.x + frame.size.width }
        set { frame.origin.x = newValue - frame.size.width }
    }

    var qmui_bottom: CGFloat {
        get { frame.origin.y + frame.size.height }
        set { frame.origin.y = newValue - frame.size.height }
    }

    var qmui_centerX: CGFloat {
        get { center.x }
        set { center.x = newValue }
    }

    var qmui_centerY: CGFloat {
        get { center.y }
        set { center.y = newValue }
    }

    // MARK: - Remove All Subviews

    func qmui_removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Get ViewController

    var qmui_viewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController {
                return vc
            }
            responder = next
        }
        return nil
    }

    // MARK: - Corner Radius

    func qmui_setCornerRadius(_ radius: CGFloat, corners: UIRectCorner = .allCorners) {
        if corners == .allCorners {
            layer.cornerRadius = radius
            layer.masksToBounds = true
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }

    // MARK: - Border

    func qmui_setBorder(color: UIColor, width: CGFloat = 1.0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    func qmui_removeBorder() {
        layer.borderColor = nil
        layer.borderWidth = 0
    }

    // MARK: - Shadow

    func qmui_setShadow(
        color: UIColor = .black,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 4,
        opacity: Float = 0.1
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }

    func qmui_removeShadow() {
        layer.shadowOpacity = 0
    }
}
