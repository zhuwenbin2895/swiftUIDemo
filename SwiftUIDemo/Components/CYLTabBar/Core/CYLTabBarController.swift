import UIKit

class CYLTabBarController: UITabBarController {
    weak var cylDelegate: CYLTabBarControllerDelegate?
    private(set) var config: CYLTabBarConfig
    private var badgeViews: [Int: CYLBadgeView] = [:]
    private var itemAnimations: [Int: CYLTabBarAnimationProtocol] = [:]

    var cylTabBar: CYLTabBar? {
        tabBar as? CYLTabBar
    }

    init(viewControllers: [UIViewController], config: CYLTabBarConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        setupTabBar()
        configureViewControllers(viewControllers, with: config.itemConfigs)
    }

    required init?(coder: NSCoder) {
        self.config = CYLTabBarConfig()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        applyAppearance()
        setupPlusButtonIfNeeded()
    }

    private func setupTabBar() {
        let customTabBar = CYLTabBar()
        customTabBar.customHeight = config.tabBarHeight
        setValue(customTabBar, forKey: "tabBar")
    }

    private func configureViewControllers(_ vcs: [UIViewController], with configs: [CYLTabBarItemConfig]) {
        for (index, vc) in vcs.enumerated() {
            guard index < configs.count else { break }
            let itemConfig = configs[index]
            let tabBarItem = CYLTabBarItem()
            tabBarItem.title = itemConfig.title
            tabBarItem.image = itemConfig.normalImage?.withRenderingMode(.alwaysOriginal)
            tabBarItem.selectedImage = itemConfig.selectedImage?.withRenderingMode(.alwaysOriginal)
            tabBarItem.iconOnly = itemConfig.iconOnly

            if let animation = itemConfig.animation {
                itemAnimations[index] = animation
            }

            vc.tabBarItem = tabBarItem
        }
        self.viewControllers = vcs
    }

    private func applyAppearance() {
        if let bgColor = config.backgroundColor {
            tabBar.backgroundColor = bgColor
        }
        if let tint = config.tintColor {
            tabBar.tintColor = tint
        }
        if let barTint = config.barTintColor {
            tabBar.barTintColor = barTint
        }
        tabBar.isTranslucent = config.isTranslucent

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            if let bgColor = config.backgroundColor {
                appearance.backgroundColor = bgColor
            }
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func setupPlusButtonIfNeeded() {
        guard config.plusButtonEnabled,
              let provider = CYLPlusButtonSubclassing.registeredPlusButton else { return }
        cylTabBar?.setupPlusButton(provider)
        provider.plusButton.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
    }

    @objc private func plusButtonTapped(_ sender: UIButton) {
        guard let provider = CYLPlusButtonSubclassing.registeredPlusButton else { return }
        provider.plusButtonClicked(sender)

        if let vc = provider.tabBarItemAttachedController {
            present(vc, animated: true)
        }
    }

    // MARK: - Public API

    func reloadTabBar(with newConfig: CYLTabBarConfig) {
        self.config = newConfig
        cylTabBar?.customHeight = newConfig.tabBarHeight

        if let vcs = viewControllers {
            configureViewControllers(vcs, with: newConfig.itemConfigs)
        }

        applyAppearance()

        if newConfig.plusButtonEnabled {
            setupPlusButtonIfNeeded()
        } else {
            cylTabBar?.removePlusButton()
        }

        cylTabBar?.setNeedsLayout()
        cylTabBar?.layoutIfNeeded()
    }

    func setAnimation(_ animation: CYLTabBarAnimationProtocol, atIndex index: Int) {
        itemAnimations[index] = animation
    }

    // MARK: - Badge API

    func setBadgeValue(_ value: String?, atIndex index: Int) {
        let badge = getOrCreateBadge(atIndex: index)
        badge.updateBadge(value: value)
    }

    func showRedDot(atIndex index: Int) {
        let badge = getOrCreateBadge(atIndex: index)
        badge.showRedDot(true)
    }

    func hideRedDot(atIndex index: Int) {
        let badge = getOrCreateBadge(atIndex: index)
        badge.showRedDot(false)
    }

    func hideBadge(atIndex index: Int) {
        badgeViews[index]?.reset()
    }

    func setCustomBadgeView(_ view: UIView, atIndex index: Int) {
        let badge = getOrCreateBadge(atIndex: index)
        badge.setCustomView(view)
    }

    private func getOrCreateBadge(atIndex index: Int) -> CYLBadgeView {
        if let existing = badgeViews[index] {
            return existing
        }
        let badge = CYLBadgeView()
        badgeViews[index] = badge
        attachBadge(badge, toTabAtIndex: index)
        return badge
    }

    private func attachBadge(_ badge: CYLBadgeView, toTabAtIndex index: Int) {
        let tabBarButtons = tabBar.subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }
        guard index < tabBarButtons.count else { return }

        let button = tabBarButtons[index]
        button.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badge.centerXAnchor.constraint(equalTo: button.centerXAnchor, constant: 14),
            badge.centerYAnchor.constraint(equalTo: button.topAnchor, constant: 8)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for (index, badge) in badgeViews {
            if badge.superview == nil {
                attachBadge(badge, toTabAtIndex: index)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.cylTabBar?.setNeedsLayout()
            self.cylTabBar?.layoutIfNeeded()
        })
    }

    private func playAnimationForSelectedTab(_ index: Int) {
        guard let animation = itemAnimations[index] else { return }
        let tabBarButtons = tabBar.subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }
        guard index < tabBarButtons.count else { return }

        let button = tabBarButtons[index]
        if let imageView = button.subviews.compactMap({ $0 as? UIImageView }).first
            ?? button.subviews.first(where: { String(describing: type(of: $0)).contains("ImageView") }) as? UIImageView {
            animation.playAnimation(on: imageView, in: tabBar)
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension CYLTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return true }
        return cylDelegate?.tabBarController(self, shouldSelectItemAt: index) ?? true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        cylDelegate?.tabBarController(self, didSelectItemAt: index)
        playAnimationForSelectedTab(index)
    }
}
