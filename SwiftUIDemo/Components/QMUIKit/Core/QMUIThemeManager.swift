import SwiftUI
import UIKit
import Combine

// MARK: - Theme Configuration

enum QMUIThemeMode: String, CaseIterable {
    case light
    case dark
    case system
}

struct QMUIThemeConfig {
    var primaryColor: UIColor
    var secondaryColor: UIColor
    var backgroundColor: UIColor
    var surfaceColor: UIColor
    var textColor: UIColor
    var textSecondaryColor: UIColor
    var separatorColor: UIColor
    var font: UIFont
    var fontBold: UIFont
    var fontSize: CGFloat
    var cornerRadius: CGFloat
    var cornerRadiusSmall: CGFloat
    var cornerRadiusLarge: CGFloat
}

extension Notification.Name {
    static let qmuiThemeDidChange = Notification.Name("QMUIThemeDidChangeNotification")
}

// MARK: - Theme Manager

class QMUIThemeManager: ObservableObject {
    static let shared = QMUIThemeManager()

    @Published var themeMode: QMUIThemeMode = .system {
        didSet { applyTheme() }
    }

    @Published private(set) var currentConfig: QMUIThemeConfig

    var primaryColor: UIColor {
        get { currentConfig.primaryColor }
        set { currentConfig.primaryColor = newValue; applyTheme() }
    }

    var fontSize: CGFloat {
        get { currentConfig.fontSize }
        set {
            currentConfig.fontSize = newValue
            currentConfig.font = .systemFont(ofSize: newValue)
            currentConfig.fontBold = .boldSystemFont(ofSize: newValue)
            applyTheme()
        }
    }

    var cornerRadius: CGFloat {
        get { currentConfig.cornerRadius }
        set {
            currentConfig.cornerRadius = newValue
            currentConfig.cornerRadiusSmall = newValue * 0.5
            currentConfig.cornerRadiusLarge = newValue * 1.5
            applyTheme()
        }
    }

    private var lightConfig: QMUIThemeConfig
    private var darkConfig: QMUIThemeConfig

    private init() {
        lightConfig = QMUIThemeConfig(
            primaryColor: UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),
            secondaryColor: UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1.0),
            backgroundColor: UIColor(white: 1.0, alpha: 1.0),
            surfaceColor: UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0),
            textColor: UIColor(white: 0.0, alpha: 1.0),
            textSecondaryColor: UIColor(white: 0.4, alpha: 1.0),
            separatorColor: UIColor(white: 0.82, alpha: 1.0),
            font: .systemFont(ofSize: 16),
            fontBold: .boldSystemFont(ofSize: 16),
            fontSize: 16,
            cornerRadius: 8,
            cornerRadiusSmall: 4,
            cornerRadiusLarge: 12
        )

        darkConfig = QMUIThemeConfig(
            primaryColor: UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),
            secondaryColor: UIColor(red: 0.6, green: 0.5, blue: 1.0, alpha: 1.0),
            backgroundColor: UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0),
            surfaceColor: UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0),
            textColor: UIColor(white: 0.95, alpha: 1.0),
            textSecondaryColor: UIColor(white: 0.6, alpha: 1.0),
            separatorColor: UIColor(white: 0.25, alpha: 1.0),
            font: .systemFont(ofSize: 16),
            fontBold: .boldSystemFont(ofSize: 16),
            fontSize: 16,
            cornerRadius: 8,
            cornerRadiusSmall: 4,
            cornerRadiusLarge: 12
        )

        currentConfig = lightConfig
        applyTheme()
        observeSystemAppearance()
    }

    private var appearanceCancellable: AnyCancellable?

    private func observeSystemAppearance() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            // App may not have a scene yet at init; retry once the scene connects.
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(sceneDidConnect),
                name: UIScene.didActivateNotification,
                object: nil
            )
            return
        }
        attachTraitObserver(to: scene)
    }

    @objc private func sceneDidConnect(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
        if let scene = notification.object as? UIWindowScene {
            attachTraitObserver(to: scene)
        }
    }

    private func attachTraitObserver(to scene: UIWindowScene) {
        guard let window = scene.windows.first else { return }
        window.registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (_: UIWindow, _: UITraitCollection) in
            guard let self, self.themeMode == .system else { return }
            self.applyTheme()
        }
    }

    func updateLightTheme(_ config: QMUIThemeConfig) {
        lightConfig = config
        applyTheme()
    }

    func updateDarkTheme(_ config: QMUIThemeConfig) {
        darkConfig = config
        applyTheme()
    }

    private func applyTheme() {
        let isDark: Bool
        switch themeMode {
        case .light:
            isDark = false
        case .dark:
            isDark = true
        case .system:
            let style = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                .windows.first?.traitCollection.userInterfaceStyle
            isDark = style == .dark
        }

        currentConfig = isDark ? darkConfig : lightConfig
        NotificationCenter.default.post(name: .qmuiThemeDidChange, object: self)
    }

    // SwiftUI Color helpers
    var primarySwiftUIColor: Color { Color(currentConfig.primaryColor) }
    var backgroundSwiftUIColor: Color { Color(currentConfig.backgroundColor) }
    var textSwiftUIColor: Color { Color(currentConfig.textColor) }
}
