import UIKit

// MARK: - QMUITextField

class QMUITextField: UITextField {
    var qmui_placeholderColor: UIColor? {
        didSet { updatePlaceholder() }
    }

    var qmui_textInsets: UIEdgeInsets = .zero

    var qmui_maxLength: Int = 0 {
        didSet {
            if qmui_maxLength > 0 {
                addTarget(self, action: #selector(textDidChange), for: .editingChanged)
            }
        }
    }

    override var placeholder: String? {
        didSet { updatePlaceholder() }
    }

    private func updatePlaceholder() {
        guard let placeholder = placeholder, let color = qmui_placeholderColor else { return }
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: color]
        )
    }

    @objc private func textDidChange() {
        guard qmui_maxLength > 0 else { return }
        guard let text = self.text else { return }

        if markedTextRange == nil && text.count > qmui_maxLength {
            self.text = String(text.prefix(qmui_maxLength))
        }
    }

    // MARK: - Text Insets

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: qmui_textInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: qmui_textInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: qmui_textInsets)
    }
}
