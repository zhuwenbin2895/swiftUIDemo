import SwiftUI
import UIKit
import Combine

// MARK: - Keyboard State

enum KeyboardState {
    case hidden
    case showing
    case shown
    case hiding
}

// MARK: - Keyboard Info

struct KeyboardInfo {
    let height: CGFloat
    let animationDuration: TimeInterval
    let animationCurve: UIView.AnimationCurve
    let state: KeyboardState

    static let initial = KeyboardInfo(height: 0, animationDuration: 0, animationCurve: .easeInOut, state: .hidden)
}

// MARK: - Keyboard Manager

@MainActor
class KeyboardManager: ObservableObject {
    static let shared = KeyboardManager()

    @Published var keyboardInfo: KeyboardInfo = .initial
    @Published var isKeyboardVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0

    var onKeyboardWillShow: ((KeyboardInfo) -> Void)?
    var onKeyboardDidShow: ((KeyboardInfo) -> Void)?
    var onKeyboardWillHide: ((KeyboardInfo) -> Void)?
    var onKeyboardDidHide: ((KeyboardInfo) -> Void)?

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.handleKeyboardWillShow(notification)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.handleKeyboardDidShow(notification)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.handleKeyboardWillHide(notification)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleKeyboardDidHide()
            }
            .store(in: &cancellables)
    }

    private func handleKeyboardWillShow(_ notification: Notification) {
        let info = extractInfo(from: notification, state: .showing)
        keyboardInfo = info
        keyboardHeight = info.height
        isKeyboardVisible = true
        onKeyboardWillShow?(info)
    }

    private func handleKeyboardDidShow(_ notification: Notification) {
        let info = extractInfo(from: notification, state: .shown)
        keyboardInfo = info
        onKeyboardDidShow?(info)
    }

    private func handleKeyboardWillHide(_ notification: Notification) {
        let info = extractInfo(from: notification, state: .hiding)
        keyboardInfo = info
        onKeyboardWillHide?(info)
    }

    private func handleKeyboardDidHide() {
        let info = KeyboardInfo(height: 0, animationDuration: 0.25, animationCurve: .easeInOut, state: .hidden)
        keyboardInfo = info
        keyboardHeight = 0
        isKeyboardVisible = false
        onKeyboardDidHide?(info)
    }

    private func extractInfo(from notification: Notification, state: KeyboardState) -> KeyboardInfo {
        let userInfo = notification.userInfo
        let frame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let duration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        let curveValue = (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? 7
        let curve = UIView.AnimationCurve(rawValue: curveValue) ?? .easeInOut
        return KeyboardInfo(height: frame.height, animationDuration: duration, animationCurve: curve, state: state)
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Keyboard Adaptive Modifier

struct KeyboardAdaptiveModifier: ViewModifier {
    @ObservedObject var keyboardManager = KeyboardManager.shared
    var extraOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardManager.isKeyboardVisible ? keyboardManager.keyboardHeight + extraOffset : 0)
            .animation(.easeOut(duration: 0.25), value: keyboardManager.keyboardHeight)
    }
}

extension View {
    func keyboardAdaptive(extraOffset: CGFloat = 0) -> some View {
        modifier(KeyboardAdaptiveModifier(extraOffset: extraOffset))
    }
}

// MARK: - Keyboard Avoiding ScrollView

struct KeyboardAvoidingScrollView<Content: View>: View {
    @ObservedObject var keyboardManager = KeyboardManager.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                content
                    .padding(.bottom, keyboardManager.isKeyboardVisible ? keyboardManager.keyboardHeight : 0)
            }
            .animation(.easeOut(duration: 0.25), value: keyboardManager.keyboardHeight)
            .onTapGesture {
                keyboardManager.dismissKeyboard()
            }
        }
    }
}
