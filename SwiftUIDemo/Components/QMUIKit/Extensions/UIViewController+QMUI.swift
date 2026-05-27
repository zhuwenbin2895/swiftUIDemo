import UIKit

// MARK: - Navigation Bar Control

private var qmui_prefersNavigationBarHiddenKey: UInt8 = 0
private var qmui_preferredStatusBarStyleKey: UInt8 = 0
private var qmui_interceptBackActionKey: UInt8 = 0

extension UIViewController {

    // MARK: - Navigation Bar Hidden

    var qmui_prefersNavigationBarHidden: Bool {
        get {
            objc_getAssociatedObject(self, &qmui_prefersNavigationBarHiddenKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &qmui_prefersNavigationBarHiddenKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            navigationController?.setNavigationBarHidden(newValue, animated: true)
        }
    }

    // MARK: - Status Bar Style

    var qmui_statusBarStyle: UIStatusBarStyle {
        get {
            objc_getAssociatedObject(self, &qmui_preferredStatusBarStyleKey) as? UIStatusBarStyle ?? .default
        }
        set {
            objc_setAssociatedObject(self, &qmui_preferredStatusBarStyleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    // MARK: - Auto Content Inset

    func qmui_adjustScrollViewInsets(_ scrollView: UIScrollView) {
        let topInset = view.safeAreaInsets.top
        let bottomInset = view.safeAreaInsets.bottom
        scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    // MARK: - Intercept Back Action

    typealias QMUIBackActionHandler = () -> Bool

    var qmui_interceptBackAction: QMUIBackActionHandler? {
        get {
            objc_getAssociatedObject(self, &qmui_interceptBackActionKey) as? QMUIBackActionHandler
        }
        set {
            objc_setAssociatedObject(self, &qmui_interceptBackActionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue != nil {
                setupBackInterception()
            }
        }
    }

    private func setupBackInterception() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(qmui_handleBackAction)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func qmui_handleBackAction() {
        if let handler = qmui_interceptBackAction {
            let shouldPop = handler()
            if shouldPop {
                navigationController?.popViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
