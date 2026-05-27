import UIKit

// MARK: - QMUITextView with Placeholder and Auto Height

class QMUITextView: UITextView {
    var qmui_placeholder: String? {
        didSet { setNeedsDisplay() }
    }

    var qmui_placeholderColor: UIColor = .placeholderText {
        didSet { setNeedsDisplay() }
    }

    var qmui_maxHeight: CGFloat = 0
    var qmui_autoHeight: Bool = false

    var qmui_heightDidChange: ((CGFloat) -> Void)?

    private var placeholderLabel: UILabel?

    override var text: String! {
        didSet { textChanged() }
    }

    override var attributedText: NSAttributedString! {
        didSet { textChanged() }
    }

    override var font: UIFont? {
        didSet { placeholderLabel?.font = font }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        setupPlaceholder()
    }

    private func setupPlaceholder() {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = qmui_placeholderColor
        label.font = font
        label.isHidden = !text.isEmpty
        addSubview(label)
        placeholderLabel = label
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel?.frame = CGRect(
            x: textContainerInset.left + textContainer.lineFragmentPadding,
            y: textContainerInset.top,
            width: bounds.width - textContainerInset.left - textContainerInset.right - 2 * textContainer.lineFragmentPadding,
            height: 0
        )
        placeholderLabel?.text = qmui_placeholder
        placeholderLabel?.sizeToFit()
    }

    @objc private func textChanged() {
        placeholderLabel?.isHidden = !text.isEmpty
        if qmui_autoHeight {
            updateHeight()
        }
    }

    private func updateHeight() {
        let maxSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        var newHeight = sizeThatFits(maxSize).height

        if qmui_maxHeight > 0 {
            newHeight = min(newHeight, qmui_maxHeight)
            isScrollEnabled = sizeThatFits(maxSize).height > qmui_maxHeight
        } else {
            isScrollEnabled = false
        }

        if bounds.height != newHeight {
            qmui_heightDidChange?(newHeight)
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        if qmui_autoHeight {
            let maxSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
            var height = sizeThatFits(maxSize).height
            if qmui_maxHeight > 0 {
                height = min(height, qmui_maxHeight)
            }
            return CGSize(width: UIView.noIntrinsicMetric, height: height)
        }
        return super.intrinsicContentSize
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
