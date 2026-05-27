import UIKit

extension UITabBar {
    static func cylAppearance(
        backgroundColor: UIColor? = nil,
        tintColor: UIColor? = nil,
        unselectedColor: UIColor? = nil,
        barTintColor: UIColor? = nil
    ) {
        let appearance = UITabBar.appearance()
        if let bgColor = backgroundColor {
            appearance.backgroundColor = bgColor
        }
        if let tint = tintColor {
            appearance.tintColor = tint
        }
        if let unselected = unselectedColor {
            appearance.unselectedItemTintColor = unselected
        }
        if let barTint = barTintColor {
            appearance.barTintColor = barTint
        }
    }

    @available(iOS 15.0, *)
    static func cylModernAppearance(
        backgroundColor: UIColor = .systemBackground,
        selectedColor: UIColor = .systemBlue,
        unselectedColor: UIColor = .secondaryLabel,
        shadowColor: UIColor? = nil
    ) -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor

        let normal = UITabBarItemAppearance()
        normal.normal.iconColor = unselectedColor
        normal.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
        normal.selected.iconColor = selectedColor
        normal.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        appearance.stackedLayoutAppearance = normal

        if let shadow = shadowColor {
            appearance.shadowColor = shadow
        }

        return appearance
    }
}
