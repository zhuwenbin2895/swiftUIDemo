import SwiftUI
import UIKit

struct CYLTabBarRepresentable: UIViewControllerRepresentable {
    let config: CYLTabBarConfig
    let viewControllers: [UIViewController]
    var plusButton: CYLPlusButtonProtocol?
    var delegate: CYLTabBarControllerDelegate?

    func makeUIViewController(context: Context) -> CYLTabBarController {
        if let plus = plusButton, config.plusButtonEnabled {
            CYLPlusButtonSubclassing.registerPlusButton(plus)
        } else {
            CYLPlusButtonSubclassing.unregisterPlusButton()
        }

        let controller = CYLTabBarController(viewControllers: viewControllers, config: config)
        controller.cylDelegate = delegate
        return controller
    }

    func updateUIViewController(_ uiViewController: CYLTabBarController, context: Context) {
        uiViewController.reloadTabBar(with: config)
        uiViewController.cylDelegate = delegate
    }
}
