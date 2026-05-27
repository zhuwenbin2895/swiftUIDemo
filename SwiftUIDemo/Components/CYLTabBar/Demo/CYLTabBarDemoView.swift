import SwiftUI
import UIKit

// MARK: - Main Demo List

struct CYLTabBarDemoView: View {
    var body: some View {
        List {
            Section("基础功能") {
                NavigationLink("基础 TabBar") {
                    BasicTabBarDemo()
                        .navigationTitle("基础 TabBar")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("动态刷新 TabBar") {
                    DynamicRefreshTabBarDemo()
                        .navigationTitle("动态刷新")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("横竖屏适配") {
                    OrientationTabBarDemo()
                        .navigationTitle("横竖屏适配")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            Section("样式定制") {
                NavigationLink("纯图标模式 (垂直居中)") {
                    IconOnlyTabBarDemo()
                        .navigationTitle("纯图标模式")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("自定义 TabBar 高度") {
                    CustomHeightTabBarDemo()
                        .navigationTitle("自定义高度")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("UIAppearance 配置") {
                    AppearanceTabBarDemo()
                        .navigationTitle("UIAppearance")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            Section("中间加号按钮") {
                NavigationLink("默认加号按钮") {
                    PlusButtonTabBarDemo()
                        .navigationTitle("加号按钮")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("自定义位置/偏移") {
                    PlusButtonOffsetDemo()
                        .navigationTitle("自定义偏移")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("加号关联控制器") {
                    PlusButtonControllerDemo()
                        .navigationTitle("关联控制器")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("一键移除加号按钮") {
                    PlusButtonRemoveDemo()
                        .navigationTitle("一键移除")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            Section("动画效果") {
                NavigationLink("内置动画 (弹跳/旋转/缩放)") {
                    AnimationTabBarDemo()
                        .navigationTitle("Tab 动画")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("Lottie 动画 (模拟)") {
                    LottieTabBarDemo()
                        .navigationTitle("Lottie 模拟")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            Section("角标功能") {
                NavigationLink("红点角标") {
                    RedDotBadgeDemo()
                        .navigationTitle("红点角标")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("数字角标") {
                    NumberBadgeDemo()
                        .navigationTitle("数字角标")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("自定义角标视图") {
                    CustomBadgeDemo()
                        .navigationTitle("自定义角标")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            Section("交互事件") {
                NavigationLink("点击事件回调") {
                    ClickEventDemo()
                        .navigationTitle("点击回调")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("切换拦截") {
                    InterceptionDemo()
                        .navigationTitle("切换拦截")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            Section("高级功能") {
                NavigationLink("多 TabBar 嵌套") {
                    NestedTabBarDemo()
                        .navigationTitle("多 TabBar 嵌套")
                        .navigationBarTitleDisplayMode(.inline)
                }
                NavigationLink("加号按钮低耦合") {
                    DecoupledPlusButtonDemo()
                        .navigationTitle("低耦合演示")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .navigationTitle("CYLTabBar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper: Create simple VCs for demos

private func makeSimpleVC(title: String, color: UIColor, icon: String) -> UIViewController {
    let vc = UIViewController()
    vc.view.backgroundColor = color

    let label = UILabel()
    label.text = title
    label.font = .systemFont(ofSize: 20, weight: .semibold)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(label)
    NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
    ])

    let config = UIImage.SymbolConfiguration(pointSize: 20)
    vc.tabBarItem = UITabBarItem(
        title: title,
        image: UIImage(systemName: icon, withConfiguration: config),
        selectedImage: UIImage(systemName: "\(icon).fill", withConfiguration: config) ?? UIImage(systemName: icon, withConfiguration: config)
    )
    return vc
}

private func makeDefaultVCs() -> [UIViewController] {
    [
        makeSimpleVC(title: "首页", color: .systemBackground, icon: "house"),
        makeSimpleVC(title: "发现", color: .systemBackground, icon: "safari"),
        makeSimpleVC(title: "消息", color: .systemBackground, icon: "message"),
        makeSimpleVC(title: "我的", color: .systemBackground, icon: "person")
    ]
}

private func makeDefaultItemConfigs() -> [CYLTabBarItemConfig] {
    let config = UIImage.SymbolConfiguration(pointSize: 20)
    return [
        CYLTabBarItemConfig(title: "首页",
                           normalImage: UIImage(systemName: "house", withConfiguration: config),
                           selectedImage: UIImage(systemName: "house.fill", withConfiguration: config)),
        CYLTabBarItemConfig(title: "发现",
                           normalImage: UIImage(systemName: "safari", withConfiguration: config),
                           selectedImage: UIImage(systemName: "safari.fill", withConfiguration: config)),
        CYLTabBarItemConfig(title: "消息",
                           normalImage: UIImage(systemName: "message", withConfiguration: config),
                           selectedImage: UIImage(systemName: "message.fill", withConfiguration: config)),
        CYLTabBarItemConfig(title: "我的",
                           normalImage: UIImage(systemName: "person", withConfiguration: config),
                           selectedImage: UIImage(systemName: "person.fill", withConfiguration: config))
    ]
}

// MARK: - 1. Basic TabBar Demo

struct BasicTabBarDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = .systemBlue
        return CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 2. Dynamic Refresh Demo

struct DynamicRefreshTabBarDemo: UIViewControllerRepresentable {
    class Coordinator {
        var timer: Timer?
        var toggleState = false
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = .systemBlue
        let controller = CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)

        context.coordinator.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak controller] _ in
            guard let controller = controller else { return }
            context.coordinator.toggleState.toggle()
            var newConfig = config
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 20)
            if context.coordinator.toggleState {
                newConfig.itemConfigs = [
                    CYLTabBarItemConfig(title: "推荐",
                                       normalImage: UIImage(systemName: "star", withConfiguration: iconConfig),
                                       selectedImage: UIImage(systemName: "star.fill", withConfiguration: iconConfig)),
                    CYLTabBarItemConfig(title: "热门",
                                       normalImage: UIImage(systemName: "flame", withConfiguration: iconConfig),
                                       selectedImage: UIImage(systemName: "flame.fill", withConfiguration: iconConfig)),
                    CYLTabBarItemConfig(title: "收藏",
                                       normalImage: UIImage(systemName: "heart", withConfiguration: iconConfig),
                                       selectedImage: UIImage(systemName: "heart.fill", withConfiguration: iconConfig)),
                    CYLTabBarItemConfig(title: "设置",
                                       normalImage: UIImage(systemName: "gear", withConfiguration: iconConfig),
                                       selectedImage: UIImage(systemName: "gear", withConfiguration: iconConfig))
                ]
                newConfig.tintColor = .systemPurple
            } else {
                newConfig.itemConfigs = makeDefaultItemConfigs()
                newConfig.tintColor = .systemBlue
            }
            controller.reloadTabBar(with: newConfig)
        }
        return controller
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}

    static func dismantleUIViewController(_ vc: CYLTabBarController, coordinator: Coordinator) {
        coordinator.timer?.invalidate()
    }
}

// MARK: - 3. Orientation Demo

struct OrientationTabBarDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = .systemGreen

        let vcs = makeDefaultVCs()
        let infoLabel = UILabel()
        infoLabel.text = "旋转设备查看 TabBar 适配效果\n横屏时 TabBar 项目会自动重新布局"
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.font = .systemFont(ofSize: 16)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        vcs[0].view.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: vcs[0].view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: vcs[0].view.centerYAnchor),
            infoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: vcs[0].view.leadingAnchor, constant: 20)
        ])

        return CYLTabBarController(viewControllers: vcs, config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 4. Icon Only Demo

struct IconOnlyTabBarDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 22)
        var config = CYLTabBarConfig()
        config.itemConfigs = [
            CYLTabBarItemConfig(normalImage: UIImage(systemName: "house", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "house.fill", withConfiguration: iconConfig),
                               iconOnly: true),
            CYLTabBarItemConfig(normalImage: UIImage(systemName: "safari", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "safari.fill", withConfiguration: iconConfig),
                               iconOnly: true),
            CYLTabBarItemConfig(normalImage: UIImage(systemName: "message", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "message.fill", withConfiguration: iconConfig),
                               iconOnly: true),
            CYLTabBarItemConfig(normalImage: UIImage(systemName: "person", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "person.fill", withConfiguration: iconConfig),
                               iconOnly: true)
        ]
        config.plusButtonEnabled = false
        config.tintColor = .systemIndigo
        return CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 5. Custom Height Demo

struct CustomHeightTabBarDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tabBarHeight = 70
        config.tintColor = .systemOrange

        let vcs = makeDefaultVCs()
        let label = UILabel()
        label.text = "TabBar 高度: 70pt (默认 49pt)"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vcs[0].view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vcs[0].view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vcs[0].view.centerYAnchor)
        ])

        return CYLTabBarController(viewControllers: vcs, config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 6. UIAppearance Demo

struct AppearanceTabBarDemo: View {
    @State private var selectedScheme = 0
    private let schemes: [(name: String, bg: UIColor, selected: UIColor, unselected: UIColor)] = [
        ("深色主题", .black, .systemCyan, .darkGray),
        ("暖色主题", UIColor(red: 0.98, green: 0.95, blue: 0.9, alpha: 1), .systemOrange, .systemBrown),
        ("冷色主题", UIColor(red: 0.92, green: 0.95, blue: 1.0, alpha: 1), .systemIndigo, .systemGray)
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("通过 UITabBar.cylAppearance() 全局配置样式")
                    .font(.subheadline)
                Picker("配色方案", selection: $selectedScheme) {
                    ForEach(0..<schemes.count, id: \.self) { i in
                        Text(schemes[i].name).tag(i)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            .background(Color(.secondarySystemBackground))

            AppearanceTabBarContent(
                backgroundColor: schemes[selectedScheme].bg,
                selectedColor: schemes[selectedScheme].selected,
                unselectedColor: schemes[selectedScheme].unselected
            )
            .id(selectedScheme)
        }
    }
}

struct AppearanceTabBarContent: UIViewControllerRepresentable {
    let backgroundColor: UIColor
    let selectedColor: UIColor
    let unselectedColor: UIColor

    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()

        UITabBar.cylAppearance(
            backgroundColor: backgroundColor,
            tintColor: selectedColor,
            unselectedColor: unselectedColor
        )

        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = selectedColor
        config.isTranslucent = false

        let controller = CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)

        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBar.cylModernAppearance(
                backgroundColor: backgroundColor,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                shadowColor: .separator
            )
            controller.tabBar.standardAppearance = tabBarAppearance
            controller.tabBar.scrollEdgeAppearance = tabBarAppearance
        }

        return controller
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}

    static func dismantleUIViewController(_ vc: CYLTabBarController, coordinator: ()) {
        UITabBar.cylAppearance(
            backgroundColor: nil,
            tintColor: nil,
            unselectedColor: nil
        )
    }
}

// MARK: - 7. Plus Button Demo

struct PlusButtonTabBarDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        let plusBtn = CYLPlusButton { _ in
            print("[CYLTabBar] Plus button clicked!")
        }
        CYLPlusButtonSubclassing.registerPlusButton(plusBtn)

        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = true
        config.tintColor = .systemBlue
        return CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 8. Plus Button Offset Demo

struct PlusButtonOffsetDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        let plusBtn = CYLPlusButton(
            width: 60,
            height: 60,
            centerOffset: CGPoint(x: 0, y: -20)
        ) { _ in
            print("[CYLTabBar] Offset plus button clicked!")
        }
        CYLPlusButtonSubclassing.registerPlusButton(plusBtn)

        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = true
        config.tintColor = .systemTeal

        let vcs = makeDefaultVCs()
        let label = UILabel()
        label.text = "加号按钮向上偏移 20pt\n超出区域仍可点击"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        vcs[0].view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vcs[0].view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vcs[0].view.centerYAnchor)
        ])

        return CYLTabBarController(viewControllers: vcs, config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 9. Plus Button with Controller Demo

struct PlusButtonControllerDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        let publishVC = UIViewController()
        publishVC.view.backgroundColor = .systemPurple
        let titleLabel = UILabel()
        titleLabel.text = "发布页面"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        publishVC.view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: publishVC.view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: publishVC.view.centerYAnchor)
        ])

        let nav = UINavigationController(rootViewController: publishVC)
        nav.modalPresentationStyle = .pageSheet

        let plusBtn = CYLPlusButton(attachedController: nav) { _ in
            print("[CYLTabBar] Opening publish page")
        }
        CYLPlusButtonSubclassing.registerPlusButton(plusBtn)

        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = true
        config.tintColor = .systemBlue
        return CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 10. Plus Button Remove Demo

struct PlusButtonRemoveDemo: View {
    @State private var showPlusButton = true

    var body: some View {
        VStack(spacing: 0) {
            Toggle("显示加号按钮", isOn: $showPlusButton)
                .padding()
                .background(Color(.systemBackground))

            PlusButtonRemoveTabBar(showPlusButton: showPlusButton)
        }
    }
}

struct PlusButtonRemoveTabBar: UIViewControllerRepresentable {
    let showPlusButton: Bool

    func makeUIViewController(context: Context) -> CYLTabBarController {
        let plusBtn = CYLPlusButton { _ in }
        CYLPlusButtonSubclassing.registerPlusButton(plusBtn)

        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = showPlusButton
        config.tintColor = .systemBlue
        return CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {
        if showPlusButton {
            let plusBtn = CYLPlusButton { _ in }
            CYLPlusButtonSubclassing.registerPlusButton(plusBtn)
        } else {
            CYLPlusButtonSubclassing.unregisterPlusButton()
        }
        var config = vc.config
        config.plusButtonEnabled = showPlusButton
        vc.reloadTabBar(with: config)
    }
}

// MARK: - 11. Animation Demo

struct AnimationTabBarDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 20)
        var config = CYLTabBarConfig()
        config.itemConfigs = [
            CYLTabBarItemConfig(title: "弹跳",
                               normalImage: UIImage(systemName: "house", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "house.fill", withConfiguration: iconConfig),
                               animation: CYLBounceAnimation()),
            CYLTabBarItemConfig(title: "旋转",
                               normalImage: UIImage(systemName: "safari", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "safari.fill", withConfiguration: iconConfig),
                               animation: CYLRotationAnimation()),
            CYLTabBarItemConfig(title: "缩放",
                               normalImage: UIImage(systemName: "message", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "message.fill", withConfiguration: iconConfig),
                               animation: CYLScaleAnimation()),
            CYLTabBarItemConfig(title: "摇晃",
                               normalImage: UIImage(systemName: "person", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "person.fill", withConfiguration: iconConfig),
                               animation: CYLShakeAnimation())
        ]
        config.plusButtonEnabled = false
        config.tintColor = .systemBlue

        let vcs = [
            makeSimpleVC(title: "弹跳动画", color: .systemBackground, icon: "house"),
            makeSimpleVC(title: "旋转动画", color: .systemBackground, icon: "safari"),
            makeSimpleVC(title: "缩放动画", color: .systemBackground, icon: "message"),
            makeSimpleVC(title: "摇晃动画", color: .systemBackground, icon: "person")
        ]
        return CYLTabBarController(viewControllers: vcs, config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 12. Lottie Animation Demo

struct LottieTabBarDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 20)

        var config = CYLTabBarConfig()
        config.itemConfigs = [
            CYLTabBarItemConfig(title: "首页",
                               normalImage: UIImage(systemName: "house", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "house.fill", withConfiguration: iconConfig),
                               animation: CYLLottieAnimationAdapter(animationName: "tab_home")),
            CYLTabBarItemConfig(title: "发现",
                               normalImage: UIImage(systemName: "safari", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "safari.fill", withConfiguration: iconConfig),
                               animation: CYLLottieAnimationAdapter(animationName: "tab_discover")),
            CYLTabBarItemConfig(title: "消息",
                               normalImage: UIImage(systemName: "message", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "message.fill", withConfiguration: iconConfig),
                               animation: CYLLottieAnimationAdapter(animationName: "tab_message")),
            CYLTabBarItemConfig(title: "我的",
                               normalImage: UIImage(systemName: "person", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "person.fill", withConfiguration: iconConfig),
                               animation: CYLLottieAnimationAdapter(animationName: "tab_profile"))
        ]
        config.plusButtonEnabled = false
        config.tintColor = .systemPink

        let vcs = makeDefaultVCs()
        let label = UILabel()
        label.text = "Lottie 矢量关键帧动画\n每个Tab使用独立的路径动画\n(切换Tab查看不同动画效果)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        vcs[0].view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vcs[0].view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vcs[0].view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: vcs[0].view.leadingAnchor, constant: 20)
        ])

        return CYLTabBarController(viewControllers: vcs, config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 13. Red Dot Badge Demo

struct RedDotBadgeDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = .systemBlue

        let controller = CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            controller.showRedDot(atIndex: 0)
            controller.showRedDot(atIndex: 2)
        }
        return controller
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 14. Number Badge Demo

struct NumberBadgeDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = .systemBlue

        let controller = CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            controller.setBadgeValue("3", atIndex: 0)
            controller.setBadgeValue("99+", atIndex: 2)
        }
        return controller
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 15. Custom Badge Demo

struct CustomBadgeDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = .systemBlue

        let controller = CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let starView = UIImageView(image: UIImage(systemName: "star.fill"))
            starView.tintColor = .systemOrange
            starView.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
            controller.setCustomBadgeView(starView, atIndex: 0)

            let newLabel = UILabel()
            newLabel.text = "NEW"
            newLabel.font = .systemFont(ofSize: 8, weight: .bold)
            newLabel.textColor = .white
            newLabel.backgroundColor = .systemGreen
            newLabel.textAlignment = .center
            newLabel.layer.cornerRadius = 6
            newLabel.clipsToBounds = true
            newLabel.frame = CGRect(x: 0, y: 0, width: 26, height: 12)
            controller.setCustomBadgeView(newLabel, atIndex: 2)
        }
        return controller
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 16. Click Event Demo

class ClickEventCoordinator: NSObject, CYLTabBarControllerDelegate {
    var onSelect: ((Int) -> Void)?

    func tabBarController(_ controller: CYLTabBarController, didSelectItemAt index: Int) {
        onSelect?(index)
    }
}

struct ClickEventDemo: View {
    @State private var lastClickedIndex: Int?
    @State private var clickCount = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("点击次数: \(clickCount)")
                Spacer()
                if let index = lastClickedIndex {
                    Text("最后点击: Tab \(index)")
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))

            ClickEventTabBar(onSelect: { index in
                lastClickedIndex = index
                clickCount += 1
            })
        }
    }
}

struct ClickEventTabBar: UIViewControllerRepresentable {
    let onSelect: (Int) -> Void

    func makeCoordinator() -> ClickEventCoordinator {
        let coord = ClickEventCoordinator()
        coord.onSelect = onSelect
        return coord
    }

    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = .systemBlue

        let controller = CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)
        controller.cylDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {
        context.coordinator.onSelect = onSelect
    }
}

// MARK: - 17. Interception Demo

class InterceptionCoordinator: NSObject, CYLTabBarControllerDelegate {
    var blockedIndex: Int = 2
    var onBlocked: (() -> Void)?

    func tabBarController(_ controller: CYLTabBarController, shouldSelectItemAt index: Int) -> Bool {
        if index == blockedIndex {
            onBlocked?()
            return false
        }
        return true
    }
}

struct InterceptionDemo: View {
    @State private var blockedAttempts = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("第3个Tab (消息) 被拦截，无法切换")
                    .font(.subheadline)
                Text("拦截次数: \(blockedAttempts)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))

            InterceptionTabBar(onBlocked: {
                blockedAttempts += 1
            })
        }
    }
}

struct InterceptionTabBar: UIViewControllerRepresentable {
    let onBlocked: () -> Void

    func makeCoordinator() -> InterceptionCoordinator {
        let coord = InterceptionCoordinator()
        coord.onBlocked = onBlocked
        return coord
    }

    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = false
        config.tintColor = .systemBlue

        let controller = CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)
        controller.cylDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {
        context.coordinator.onBlocked = onBlocked
    }
}

// MARK: - 18. Nested TabBar Demo

struct NestedTabBarDemo: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CYLTabBarController {
        CYLPlusButtonSubclassing.unregisterPlusButton()
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18)

        // Inner TabBar 1
        var innerConfig1 = CYLTabBarConfig()
        innerConfig1.itemConfigs = [
            CYLTabBarItemConfig(title: "推荐",
                               normalImage: UIImage(systemName: "star", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "star.fill", withConfiguration: iconConfig)),
            CYLTabBarItemConfig(title: "关注",
                               normalImage: UIImage(systemName: "heart", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "heart.fill", withConfiguration: iconConfig))
        ]
        innerConfig1.plusButtonEnabled = false
        innerConfig1.tintColor = .systemPink
        innerConfig1.tabBarHeight = 44

        let innerVCs1 = [
            makeSimpleVC(title: "推荐内容", color: UIColor.systemPink.withAlphaComponent(0.05), icon: "star"),
            makeSimpleVC(title: "关注内容", color: UIColor.systemRed.withAlphaComponent(0.05), icon: "heart")
        ]
        let innerTabBar1 = CYLTabBarController(viewControllers: innerVCs1, config: innerConfig1)
        innerTabBar1.tabBarItem = UITabBarItem(title: "发现",
                                               image: UIImage(systemName: "safari", withConfiguration: iconConfig),
                                               selectedImage: UIImage(systemName: "safari.fill", withConfiguration: iconConfig))

        // Regular VCs for outer
        let homeVC = makeSimpleVC(title: "首页", color: .systemBackground, icon: "house")
        let messageVC = makeSimpleVC(title: "消息", color: .systemBackground, icon: "message")
        let profileVC = makeSimpleVC(title: "我的", color: .systemBackground, icon: "person")

        var outerConfig = CYLTabBarConfig()
        outerConfig.itemConfigs = [
            CYLTabBarItemConfig(title: "首页",
                               normalImage: UIImage(systemName: "house", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "house.fill", withConfiguration: iconConfig)),
            CYLTabBarItemConfig(title: "发现",
                               normalImage: UIImage(systemName: "safari", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "safari.fill", withConfiguration: iconConfig)),
            CYLTabBarItemConfig(title: "消息",
                               normalImage: UIImage(systemName: "message", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "message.fill", withConfiguration: iconConfig)),
            CYLTabBarItemConfig(title: "我的",
                               normalImage: UIImage(systemName: "person", withConfiguration: iconConfig),
                               selectedImage: UIImage(systemName: "person.fill", withConfiguration: iconConfig))
        ]
        outerConfig.plusButtonEnabled = false
        outerConfig.tintColor = .systemBlue

        return CYLTabBarController(viewControllers: [homeVC, innerTabBar1, messageVC, profileVC], config: outerConfig)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {}
}

// MARK: - 19. Decoupled Plus Button Demo

struct DecoupledPlusButtonDemo: View {
    @State private var moduleEnabled = true
    @State private var message = "加号按钮模块可独立启用/禁用"

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text(message)
                    .font(.subheadline)
                Toggle("加号按钮模块", isOn: $moduleEnabled)
                Text("加号按钮通过 CYLPlusButtonSubclassing 注册\n独立于业务逻辑，可一键移除")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color(.secondarySystemBackground))

            DecoupledTabBar(moduleEnabled: moduleEnabled)
        }
    }
}

struct DecoupledTabBar: UIViewControllerRepresentable {
    let moduleEnabled: Bool

    func makeUIViewController(context: Context) -> CYLTabBarController {
        if moduleEnabled {
            let plusBtn = CYLPlusButton { _ in }
            CYLPlusButtonSubclassing.registerPlusButton(plusBtn)
        } else {
            CYLPlusButtonSubclassing.unregisterPlusButton()
        }

        var config = CYLTabBarConfig()
        config.itemConfigs = makeDefaultItemConfigs()
        config.plusButtonEnabled = moduleEnabled
        config.tintColor = .systemBlue
        return CYLTabBarController(viewControllers: makeDefaultVCs(), config: config)
    }

    func updateUIViewController(_ vc: CYLTabBarController, context: Context) {
        if moduleEnabled {
            let plusBtn = CYLPlusButton { _ in }
            CYLPlusButtonSubclassing.registerPlusButton(plusBtn)
        } else {
            CYLPlusButtonSubclassing.unregisterPlusButton()
        }
        var config = vc.config
        config.plusButtonEnabled = moduleEnabled
        vc.reloadTabBar(with: config)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CYLTabBarDemoView()
    }
}
