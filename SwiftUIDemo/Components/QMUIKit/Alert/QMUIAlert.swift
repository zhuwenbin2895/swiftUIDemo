import UIKit

// MARK: - Chainable Alert Builder

class QMUIAlertAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: (() -> Void)?

    init(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

class QMUIAlertBuilder {
    private var title: String?
    private var message: String?
    private var attributedTitle: NSAttributedString?
    private var attributedMessage: NSAttributedString?
    private var actions: [QMUIAlertAction] = []
    private var customView: UIView?
    private var preferredStyle: UIAlertController.Style = .alert

    @discardableResult
    func setTitle(_ title: String) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func setMessage(_ message: String) -> Self {
        self.message = message
        return self
    }

    @discardableResult
    func setAttributedTitle(_ attributedTitle: NSAttributedString) -> Self {
        self.attributedTitle = attributedTitle
        return self
    }

    @discardableResult
    func setAttributedMessage(_ attributedMessage: NSAttributedString) -> Self {
        self.attributedMessage = attributedMessage
        return self
    }

    @discardableResult
    func addAction(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) -> Self {
        actions.append(QMUIAlertAction(title: title, style: style, handler: handler))
        return self
    }

    @discardableResult
    func setCustomView(_ view: UIView) -> Self {
        self.customView = view
        return self
    }

    @discardableResult
    func setStyle(_ style: UIAlertController.Style) -> Self {
        self.preferredStyle = style
        return self
    }

    func show(in viewController: UIViewController) {
        if customView != nil {
            showCustomAlert(in: viewController)
        } else {
            showSystemAlert(in: viewController)
        }
    }

    private func showSystemAlert(in viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

        if let attributedTitle = attributedTitle {
            alert.setValue(attributedTitle, forKey: "attributedTitle")
        }
        if let attributedMessage = attributedMessage {
            alert.setValue(attributedMessage, forKey: "attributedMessage")
        }

        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                action.handler?()
            }
            alert.addAction(alertAction)
        }

        if actions.isEmpty {
            alert.addAction(UIAlertAction(title: "确定", style: .default))
        }

        viewController.present(alert, animated: true)
    }

    private func showCustomAlert(in viewController: UIViewController) {
        let overlay = QMUICustomAlertViewController()
        overlay.alertTitle = title
        overlay.alertMessage = message
        overlay.customContentView = customView
        overlay.actions = actions
        overlay.modalPresentationStyle = .overFullScreen
        overlay.modalTransitionStyle = .crossDissolve
        viewController.present(overlay, animated: true)
    }
}

// MARK: - Custom Alert ViewController

class QMUICustomAlertViewController: UIViewController {
    var alertTitle: String?
    var alertMessage: String?
    var customContentView: UIView?
    var actions: [QMUIAlertAction] = []

    private let containerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupContainer()
        setupContent()
        setupActions()

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tap)
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }

    private func setupContainer() {
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 14
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 270)
        ])
    }

    private func setupContent() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])

        if let title = alertTitle {
            let label = UILabel()
            label.text = title
            label.font = .boldSystemFont(ofSize: 17)
            label.textAlignment = .center
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }

        if let message = alertMessage {
            let label = UILabel()
            label.text = message
            label.font = .systemFont(ofSize: 13)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }

        if let customView = customContentView {
            customView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(customView)
            customView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        }

        // Separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        separator.tag = 999
    }

    private func setupActions() {
        guard let separator = containerView.viewWithTag(999) else { return }

        let buttonStack = UIStackView()
        buttonStack.axis = actions.count <= 2 ? .horizontal : .vertical
        buttonStack.distribution = actions.count <= 2 ? .fillEqually : .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: separator.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        let effectiveActions = actions.isEmpty ? [QMUIAlertAction(title: "确定")] : actions

        for (index, action) in effectiveActions.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(action.title, for: .normal)
            button.titleLabel?.font = action.style == .cancel ? .boldSystemFont(ofSize: 17) : .systemFont(ofSize: 17)
            if action.style == .destructive {
                button.setTitleColor(.systemRed, for: .normal)
            }
            button.tag = index
            button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            buttonStack.addArrangedSubview(button)

            if actions.count <= 2 && index < effectiveActions.count - 1 {
                let vSep = UIView()
                vSep.backgroundColor = .separator
                vSep.translatesAutoresizingMaskIntoConstraints = false
                buttonStack.addSubview(vSep)
                NSLayoutConstraint.activate([
                    vSep.widthAnchor.constraint(equalToConstant: 0.5),
                    vSep.topAnchor.constraint(equalTo: buttonStack.topAnchor),
                    vSep.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor),
                    vSep.centerXAnchor.constraint(equalTo: buttonStack.centerXAnchor)
                ])
            }
        }
    }

    @objc private func actionTapped(_ sender: UIButton) {
        let effectiveActions = actions.isEmpty ? [QMUIAlertAction(title: "确定")] : actions
        let action = effectiveActions[sender.tag]
        dismiss(animated: true) {
            action.handler?()
        }
    }
}
