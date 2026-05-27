import SwiftUI
import UIKit

// MARK: - Configuration

enum PopoverDirection {
    case top, bottom, left, right
}

struct PopoverConfig {
    var direction: PopoverDirection = .bottom
    var arrowSize: CGFloat = 10
    var cornerRadius: CGFloat = 8
    var backgroundColor: Color = .white
    var shadowRadius: CGFloat = 8
    var shadowColor: Color = .black.opacity(0.15)
    var dismissOnTapOutside: Bool = true
    var maxWidth: CGFloat = 250
    var padding: CGFloat = 12
}

// MARK: - Arrow Shape

struct PopoverArrowShape: Shape {
    let direction: PopoverDirection
    let arrowSize: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch direction {
        case .top:
            path.move(to: CGPoint(x: rect.midX - arrowSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX + arrowSize, y: rect.maxY))
        case .bottom:
            path.move(to: CGPoint(x: rect.midX - arrowSize, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX + arrowSize, y: rect.minY))
        case .left:
            path.move(to: CGPoint(x: rect.maxX, y: rect.midY - arrowSize))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + arrowSize))
        case .right:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY - arrowSize))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + arrowSize))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Popover Bubble

struct PopoverBubble<Content: View>: View {
    let config: PopoverConfig
    let content: Content

    init(config: PopoverConfig, @ViewBuilder content: () -> Content) {
        self.config = config
        self.content = content()
    }

    var body: some View {
        switch config.direction {
        case .top:
            VStack(spacing: 0) {
                bubble
                arrowView
            }
        case .bottom:
            VStack(spacing: 0) {
                arrowView
                bubble
            }
        case .left:
            HStack(spacing: 0) {
                bubble
                arrowView
            }
        case .right:
            HStack(spacing: 0) {
                arrowView
                bubble
            }
        }
    }

    private var bubble: some View {
        content
            .padding(config.padding)
            .frame(maxWidth: config.maxWidth)
            .background(config.backgroundColor)
            .cornerRadius(config.cornerRadius)
            .shadow(color: config.shadowColor, radius: config.shadowRadius, x: 0, y: 2)
    }

    private var arrowView: some View {
        PopoverArrowShape(direction: config.direction, arrowSize: config.arrowSize)
            .fill(config.backgroundColor)
            .frame(
                width: (config.direction == .left || config.direction == .right) ? config.arrowSize : config.arrowSize * 2,
                height: (config.direction == .top || config.direction == .bottom) ? config.arrowSize : config.arrowSize * 2
            )
    }
}

// MARK: - Popover Modifier

struct FloatingPopoverModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let config: PopoverConfig
    @ViewBuilder let popoverContent: () -> PopoverContent

    @State private var anchorFrame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: PopoverAnchorKey.self, value: geo.frame(in: .global))
                }
            )
            .onPreferenceChange(PopoverAnchorKey.self) { frame in
                if let frame { anchorFrame = frame }
            }
            .popoverWindow(isPresented: $isPresented, config: config, anchorFrame: anchorFrame, content: popoverContent)
    }
}

private struct PopoverAnchorKey: PreferenceKey {
    static var defaultValue: CGRect? = nil
    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}

// MARK: - Window-level Popover Overlay

private struct PopoverWindowModifier<C: View>: ViewModifier {
    @Binding var isPresented: Bool
    let config: PopoverConfig
    let anchorFrame: CGRect
    @ViewBuilder let popoverContent: () -> C

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, _ in }
            .background(
                PopoverPresenter(isPresented: $isPresented, config: config, anchorFrame: anchorFrame, popoverContent: popoverContent)
            )
    }
}

private struct PopoverPresenter<C: View>: UIViewRepresentable {
    @Binding var isPresented: Bool
    let config: PopoverConfig
    let anchorFrame: CGRect
    @ViewBuilder let popoverContent: () -> C

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if isPresented {
            if context.coordinator.overlayWindow == nil {
                showOverlay(from: uiView, context: context)
            } else {
                context.coordinator.updateContent(anchorFrame: anchorFrame, config: config, isPresented: $isPresented, content: popoverContent)
            }
        } else {
            context.coordinator.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func showOverlay(from view: UIView, context: Context) {
        guard let windowScene = view.window?.windowScene else { return }
        context.coordinator.show(
            in: windowScene,
            anchorFrame: anchorFrame,
            config: config,
            isPresented: $isPresented,
            content: popoverContent
        )
    }

    class Coordinator {
        var overlayWindow: UIWindow?
        var hostingController: UIHostingController<AnyView>?

        func show<V: View>(
            in scene: UIWindowScene,
            anchorFrame: CGRect,
            config: PopoverConfig,
            isPresented: Binding<Bool>,
            content: () -> V
        ) {
            let window = PassthroughWindow(windowScene: scene)
            window.windowLevel = .alert + 1
            window.backgroundColor = .clear

            let contentView = AnyView(content())
            let overlayView = PopoverOverlayView(
                isPresented: isPresented,
                config: config,
                anchorFrame: anchorFrame,
                content: { contentView }
            )

            let hostingVC = UIHostingController(rootView: AnyView(overlayView))
            hostingVC.view.backgroundColor = .clear
            window.rootViewController = hostingVC
            window.isHidden = false

            self.overlayWindow = window
            self.hostingController = hostingVC
        }

        func updateContent<V: View>(anchorFrame: CGRect, config: PopoverConfig, isPresented: Binding<Bool>, content: () -> V) {
            let contentView = AnyView(content())
            let overlayView = PopoverOverlayView(
                isPresented: isPresented,
                config: config,
                anchorFrame: anchorFrame,
                content: { contentView }
            )
            hostingController?.rootView = AnyView(overlayView)
        }

        func dismiss() {
            overlayWindow?.isHidden = true
            overlayWindow = nil
            hostingController = nil
        }
    }
}

private class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view === self.rootViewController?.view {
            return nil
        }
        return view
    }
}

// MARK: - Popover Overlay SwiftUI View

private struct PopoverOverlayView: View {
    @Binding var isPresented: Bool
    let config: PopoverConfig
    let anchorFrame: CGRect
    let content: () -> AnyView

    var body: some View {
        ZStack {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    if config.dismissOnTapOutside {
                        withAnimation(.easeOut(duration: 0.2)) {
                            isPresented = false
                        }
                    }
                }

            PopoverBubble(config: config) {
                content()
            }
            .fixedSize()
            .position(calculatePosition())
        }
    }

    private func calculatePosition() -> CGPoint {
        let gap: CGFloat = 4
        switch config.direction {
        case .bottom:
            return CGPoint(x: anchorFrame.midX, y: anchorFrame.maxY + gap + 30)
        case .top:
            return CGPoint(x: anchorFrame.midX, y: anchorFrame.minY - gap - 30)
        case .right:
            return CGPoint(x: anchorFrame.maxX + gap + 60, y: anchorFrame.midY)
        case .left:
            return CGPoint(x: anchorFrame.minX - gap - 60, y: anchorFrame.midY)
        }
    }
}

// MARK: - View Extension

private extension View {
    func popoverWindow<C: View>(
        isPresented: Binding<Bool>,
        config: PopoverConfig,
        anchorFrame: CGRect,
        @ViewBuilder content: @escaping () -> C
    ) -> some View {
        modifier(PopoverWindowModifier(isPresented: isPresented, config: config, anchorFrame: anchorFrame, popoverContent: content))
    }
}

extension View {
    func floatingPopover<Content: View>(
        isPresented: Binding<Bool>,
        config: PopoverConfig = PopoverConfig(),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(FloatingPopoverModifier(isPresented: isPresented, config: config, popoverContent: content))
    }
}
