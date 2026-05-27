import UIKit

// MARK: - Long Press Copy

private var qmui_copyEnabledKey: UInt8 = 0
private var qmui_contentInsetsKey: UInt8 = 0

extension UILabel {

    var qmui_copyEnabled: Bool {
        get {
            objc_getAssociatedObject(self, &qmui_copyEnabledKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &qmui_copyEnabledKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            isUserInteractionEnabled = newValue
            if newValue {
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(qmui_handleLongPress(_:)))
                addGestureRecognizer(longPress)
            } else {
                gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer }
                    .forEach { removeGestureRecognizer($0) }
            }
        }
    }

    @objc private func qmui_handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        UIPasteboard.general.string = text
        showCopyFeedback()
    }

    private func showCopyFeedback() {
        let originalColor = backgroundColor
        UIView.animate(withDuration: 0.15) {
            self.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.backgroundColor = originalColor
            }
        }
    }
}

// MARK: - Padded Label

class QMUIPaddedLabel: UILabel {
    var contentInsets: UIEdgeInsets = .zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + contentInsets.left + contentInsets.right,
            height: size.height + contentInsets.top + contentInsets.bottom
        )
    }
}

// MARK: - Line Height

extension UILabel {
    func qmui_setLineHeight(_ lineHeight: CGFloat) {
        guard let text = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight - font.lineHeight
        paragraphStyle.alignment = textAlignment

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font as Any,
            .foregroundColor: textColor as Any
        ]

        attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
