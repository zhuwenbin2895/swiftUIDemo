import UIKit

class CYLBadgeView: UIView, CYLBadgeViewProtocol {
    private let redDotSize: CGFloat = 8
    private let badgeHeight: CGFloat = 16
    private let badgeMinWidth: CGFloat = 16
    private let badgePadding: CGFloat = 4

    private lazy var redDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = redDotSize / 2
        view.isHidden = true
        return view
    }()

    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = badgeHeight / 2
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    private var customView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        isUserInteractionEnabled = false
        addSubview(redDotView)
        addSubview(badgeLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        redDotView.frame = CGRect(x: 0, y: 0, width: redDotSize, height: redDotSize)

        if !badgeLabel.isHidden, let text = badgeLabel.text {
            let textWidth = (text as NSString).size(withAttributes: [.font: badgeLabel.font!]).width
            let width = max(badgeMinWidth, textWidth + badgePadding * 2)
            badgeLabel.frame = CGRect(x: 0, y: 0, width: width, height: badgeHeight)
        }

        customView?.frame = bounds
    }

    func updateBadge(value: String?) {
        redDotView.isHidden = true
        customView?.isHidden = true

        if let value = value, !value.isEmpty {
            badgeLabel.text = value
            badgeLabel.isHidden = false
            setNeedsLayout()
            let textWidth = (value as NSString).size(withAttributes: [.font: badgeLabel.font!]).width
            let width = max(badgeMinWidth, textWidth + badgePadding * 2)
            frame.size = CGSize(width: width, height: badgeHeight)
        } else {
            badgeLabel.isHidden = true
            frame.size = .zero
        }
    }

    func showRedDot(_ show: Bool) {
        badgeLabel.isHidden = true
        customView?.isHidden = true
        redDotView.isHidden = !show
        frame.size = show ? CGSize(width: redDotSize, height: redDotSize) : .zero
    }

    func setCustomView(_ view: UIView?) {
        customView?.removeFromSuperview()
        customView = view
        redDotView.isHidden = true
        badgeLabel.isHidden = true

        if let view = view {
            addSubview(view)
            frame.size = view.bounds.size
            view.isHidden = false
        } else {
            frame.size = .zero
        }
    }

    func reset() {
        redDotView.isHidden = true
        badgeLabel.isHidden = true
        customView?.removeFromSuperview()
        customView = nil
        frame.size = .zero
    }
}
