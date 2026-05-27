import UIKit

struct CYLTabBarItemConfig {
    var title: String?
    var normalImage: UIImage?
    var selectedImage: UIImage?
    var normalColor: UIColor?
    var selectedColor: UIColor?
    var iconOnly: Bool = false
    var animation: CYLTabBarAnimationProtocol?
}

struct CYLTabBarConfig {
    var tabBarHeight: CGFloat?
    var itemConfigs: [CYLTabBarItemConfig] = []
    var plusButtonEnabled: Bool = true
    var plusButtonIndex: Int?
    var backgroundColor: UIColor?
    var tintColor: UIColor?
    var barTintColor: UIColor?
    var isTranslucent: Bool = true
    var tabBarHidden: Bool = false
}
