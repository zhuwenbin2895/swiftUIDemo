import SwiftUI

struct SlideMenuNavigationView<LeftMenu: View, MainContent: View, RightMenu: View>: View {
    @StateObject private var manager: SlideMenuManager

    let leftMenu: LeftMenu
    let mainContent: MainContent
    let rightMenu: RightMenu?

    init(
        config: SlideMenuConfig = SlideMenuConfig(),
        callbacks: SlideMenuCallbacks = SlideMenuCallbacks(),
        @ViewBuilder leftMenu: () -> LeftMenu,
        @ViewBuilder mainContent: () -> MainContent,
        @ViewBuilder rightMenu: () -> RightMenu
    ) {
        _manager = StateObject(wrappedValue: SlideMenuManager(config: config, callbacks: callbacks))
        self.leftMenu = leftMenu()
        self.mainContent = mainContent()
        self.rightMenu = rightMenu()
    }

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            leftMenu
        } mainContent: {
            NavigationStack {
                mainContent
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                manager.toggle(side: .left)
                            } label: {
                                Image(systemName: "line.3.horizontal")
                            }
                        }
                        if manager.config.enableRightMenu {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    manager.toggle(side: .right)
                                } label: {
                                    Image(systemName: "ellipsis")
                                }
                            }
                        }
                    }
            }
        } rightMenu: {
            if let rightMenu = rightMenu {
                rightMenu
            }
        }
        .environmentObject(manager)
    }
}

extension SlideMenuNavigationView where RightMenu == EmptyView {
    init(
        config: SlideMenuConfig = SlideMenuConfig(),
        callbacks: SlideMenuCallbacks = SlideMenuCallbacks(),
        @ViewBuilder leftMenu: () -> LeftMenu,
        @ViewBuilder mainContent: () -> MainContent
    ) {
        _manager = StateObject(wrappedValue: SlideMenuManager(config: config, callbacks: callbacks))
        self.leftMenu = leftMenu()
        self.mainContent = mainContent()
        self.rightMenu = nil
    }
}

// MARK: - Environment Key for SlideMenuManager

private struct SlideMenuManagerKey: EnvironmentKey {
    static let defaultValue: SlideMenuManager? = nil
}

extension EnvironmentValues {
    var slideMenuManager: SlideMenuManager? {
        get { self[SlideMenuManagerKey.self] }
        set { self[SlideMenuManagerKey.self] = newValue }
    }
}
