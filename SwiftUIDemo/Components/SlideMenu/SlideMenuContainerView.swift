import SwiftUI

struct SlideMenuContainerView<LeftMenu: View, MainContent: View, RightMenu: View>: View {
    @ObservedObject var manager: SlideMenuManager
    let leftMenu: LeftMenu
    let mainContent: MainContent
    let rightMenu: RightMenu?

    init(
        manager: SlideMenuManager,
        @ViewBuilder leftMenu: () -> LeftMenu,
        @ViewBuilder mainContent: () -> MainContent,
        @ViewBuilder rightMenu: () -> RightMenu
    ) {
        self.manager = manager
        self.leftMenu = leftMenu()
        self.mainContent = mainContent()
        self.rightMenu = rightMenu()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Left Menu
                if manager.config.enableLeftMenu {
                    leftMenu
                        .frame(width: manager.config.leftMenuWidth)
                        .offset(x: leftMenuOffset)
                        .zIndex(0)
                }

                // Right Menu
                if manager.config.enableRightMenu, let rightMenu = rightMenu {
                    HStack {
                        Spacer()
                        rightMenu
                            .frame(width: manager.config.rightMenuWidth)
                            .offset(x: rightMenuOffset)
                    }
                    .zIndex(0)
                }

                // Main Content
                mainContentView(geometry: geometry)
                    .zIndex(1)
            }
            .gesture(dragGesture(screenWidth: geometry.size.width))
            .onChange(of: geometry.size) { _, _ in
                if manager.isMenuOpen {
                    manager.close(animated: false)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }

    // MARK: - Main Content View

    @ViewBuilder
    private func mainContentView(geometry: GeometryProxy) -> some View {
        ZStack {
            mainContent
                .frame(width: geometry.size.width, height: geometry.size.height)

            if manager.overlayOpacity > 0 {
                manager.config.overlayColor
                    .opacity(manager.overlayOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        manager.close()
                    }
            }
        }
        .scaleEffect(manager.mainViewScale)
        .offset(x: manager.dragOffset * manager.config.mainViewTranslateRatio)
        .cornerRadius(manager.isMenuOpen || manager.isDragging ? manager.config.mainViewCornerRadius : 0)
        .shadow(
            color: manager.config.mainViewShadowColor.opacity(
                manager.isMenuOpen || manager.isDragging ? manager.config.mainViewShadowOpacity : 0
            ),
            radius: manager.config.mainViewShadowRadius,
            x: manager.dragOffset > 0 ? -5 : 5,
            y: 0
        )
    }

    // MARK: - Menu Offsets

    private var leftMenuOffset: CGFloat {
        let progress = max(0, manager.dragOffset / manager.config.leftMenuWidth)
        return -manager.config.leftMenuWidth * 0.3 * (1 - min(progress, 1.0))
    }

    private var rightMenuOffset: CGFloat {
        let progress = max(0, abs(manager.dragOffset) / manager.config.rightMenuWidth)
        return manager.config.rightMenuWidth * 0.3 * (1 - min(progress, 1.0))
    }

    // MARK: - Gesture

    private func dragGesture(screenWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let startX = value.startLocation.x
                let isFromLeftEdge = startX < manager.config.edgeTriggerWidth
                let isFromRightEdge = startX > screenWidth - manager.config.edgeTriggerWidth

                if !manager.isDragging {
                    if manager.isMenuOpen || isFromLeftEdge || isFromRightEdge {
                        manager.callbacks.onGesturePhaseChanged?(.began)
                    } else {
                        return
                    }
                }

                if manager.isMenuOpen || isFromLeftEdge || isFromRightEdge {
                    manager.handleDragChanged(value: value, screenWidth: screenWidth)
                }
            }
            .onEnded { value in
                if manager.isDragging {
                    manager.handleDragEnded(value: value)
                }
            }
    }
}

// MARK: - Convenience init without right menu

extension SlideMenuContainerView where RightMenu == EmptyView {
    init(
        manager: SlideMenuManager,
        @ViewBuilder leftMenu: () -> LeftMenu,
        @ViewBuilder mainContent: () -> MainContent
    ) {
        self.manager = manager
        self.leftMenu = leftMenu()
        self.mainContent = mainContent()
        self.rightMenu = nil
    }
}
