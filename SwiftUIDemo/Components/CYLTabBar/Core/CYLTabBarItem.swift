import UIKit

class CYLTabBarItem: UITabBarItem {
    var iconOnly: Bool = false {
        didSet { updateImageInsets() }
    }

    private func updateImageInsets() {
        if iconOnly {
            imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            title = nil
        } else {
            imageInsets = .zero
        }
    }

    override var title: String? {
        get { iconOnly ? nil : super.title }
        set { super.title = iconOnly ? nil : newValue }
    }
}
