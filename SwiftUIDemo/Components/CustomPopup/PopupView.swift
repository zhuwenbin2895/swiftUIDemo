import SwiftUI
import UIKit

struct PopupView: View {
    @ObservedObject var manager: PopupManager
    @State private var dragOffset: CGFloat = 0
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        if let popup = manager.currentPopup {
            ZStack {
                maskLayer(config: popup.config)
                popupContent(config: popup.config)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.easeOut(duration: 0.25)) {
                        keyboardHeight = frame.height
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = 0
                }
            }
        }
    }

    @ViewBuilder
    private func maskLayer(config: PopupConfig) -> some View {
        config.maskColor
            .ignoresSafeArea(.all)
            .opacity(manager.isPresented ? 1 : 0)
            .onTapGesture {
                if config.tapBackgroundToDismiss {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    manager.dismiss()
                }
            }
    }

    @ViewBuilder
    private func popupContent(config: PopupConfig) -> some View {
        Group {
            switch config.style {
            case .bottom:
                VStack {
                    Spacer()
                    bottomSheet(config: config)
                        .offset(y: -keyboardHeight)
                }
            case .center:
                centerPopup(config: config)
                    .offset(y: -keyboardHeight / 2)
            case .fullscreen:
                fullscreenPopup(config: config)
            }
        }
        .modifier(PopupTransitionModifier(
            isPresented: manager.isPresented,
            style: config.style,
            animation: config.animation,
            dragOffset: dragOffset
        ))
    }

    @ViewBuilder
    private func bottomSheet(config: PopupConfig) -> some View {
        VStack(spacing: 0) {
            if config.dragToDismiss {
                dragIndicator
            }
            contentBody(config: config)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: config.maxHeight ?? UIScreen.main.bounds.height * 0.7)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous))
        .padding(.horizontal, 0)
        .gesture(config.dragToDismiss ? dragGesture : nil)
    }

    @ViewBuilder
    private func centerPopup(config: PopupConfig) -> some View {
        VStack(spacing: 16) {
            contentBody(config: config)
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 64)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
    }

    @ViewBuilder
    private func fullscreenPopup(config: PopupConfig) -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    manager.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                        .contentShape(Circle())
                }
                .padding(16)
            }
            .padding(.top, safeAreaTop)
            contentBody(config: config)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
    }

    private var safeAreaTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }

    @ViewBuilder
    private func contentBody(config: PopupConfig) -> some View {
        if let customContent = config.customContent {
            customContent
        } else {
            VStack(spacing: 12) {
                if let icon = config.icon {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.tint)
                        .padding(.top, 20)
                }

                if let title = config.title {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, config.icon == nil ? 20 : 0)
                }

                if let message = config.message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                buttonsArea(config: config)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
            }
        }
    }

    @ViewBuilder
    private func buttonsArea(config: PopupConfig) -> some View {
        if let customButtons = config.customButtons {
            customButtons
        } else if !config.buttons.isEmpty {
            if config.buttons.count == 2 {
                HStack(spacing: 12) {
                    ForEach(Array(config.buttons.enumerated()), id: \.offset) { _, button in
                        buttonView(button)
                    }
                }
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(config.buttons.enumerated()), id: \.offset) { _, button in
                        buttonView(button)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func buttonView(_ button: PopupButton) -> some View {
        Button {
            button.action()
            manager.dismiss()
        } label: {
            Text(button.title)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(buttonBackground(button.style))
                .foregroundStyle(buttonForeground(button.style))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func buttonBackground(_ style: PopupButton.ButtonStyle) -> Color {
        switch style {
        case .default:
            return .accentColor
        case .cancel:
            return Color(.secondarySystemFill)
        case .destructive:
            return .red
        }
    }

    private func buttonForeground(_ style: PopupButton.ButtonStyle) -> Color {
        switch style {
        case .default, .destructive:
            return .white
        case .cancel:
            return .primary
        }
    }

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color(.tertiaryLabel))
            .frame(width: 36, height: 5)
            .padding(.vertical, 10)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                if translation > 0 {
                    dragOffset = translation
                }
            }
            .onEnded { value in
                if value.translation.height > 120 || value.predictedEndTranslation.height > 200 {
                    manager.dismiss()
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    dragOffset = 0
                }
            }
    }
}

private struct PopupTransitionModifier: ViewModifier {
    let isPresented: Bool
    let style: PopupStyle
    let animation: PopupAnimation
    let dragOffset: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(y: offset + dragOffset)
    }

    private var opacity: Double {
        switch animation {
        case .fadeScale:
            return isPresented ? 1 : 0
        case .slideFromBottom, .spring:
            return isPresented ? 1 : (style == .bottom ? 1 : 0)
        }
    }

    private var scale: CGFloat {
        switch animation {
        case .fadeScale:
            return isPresented ? 1 : 0.8
        case .spring:
            return isPresented ? 1 : 0.5
        case .slideFromBottom:
            return 1
        }
    }

    private var offset: CGFloat {
        guard !isPresented else { return 0 }
        switch animation {
        case .slideFromBottom:
            return UIScreen.main.bounds.height
        case .fadeScale:
            return 0
        case .spring:
            return style == .bottom ? UIScreen.main.bounds.height : 0
        }
    }
}

extension View {
    func customPopup(manager: PopupManager) -> some View {
        self.overlay {
            PopupView(manager: manager)
        }
    }
}
