import UIKit

// MARK: - Image Text Layout

enum QMUIButtonImagePosition {
    case left
    case right
    case top
    case bottom
}

private var qmui_countdownTimerKey: UInt8 = 0
private var qmui_originalTitleKey: UInt8 = 0

extension UIButton {

    func qmui_setImagePosition(_ position: QMUIButtonImagePosition, spacing: CGFloat = 4) {
        guard let imageSize = imageView?.image?.size,
              let titleSize = titleLabel?.intrinsicContentSize else { return }

        let imageOffsetX = (imageSize.width + titleSize.width) / 2 - imageSize.width / 2
        let imageOffsetY = imageSize.height / 2 + spacing / 2
        let titleOffsetX = (imageSize.width + titleSize.width / 2) - (imageSize.width + titleSize.width) / 2
        let titleOffsetY = titleSize.height / 2 + spacing / 2

        switch position {
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing / 2, bottom: 0, right: spacing / 2)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: -spacing / 2)

        case .right:
            imageEdgeInsets = UIEdgeInsets(
                top: 0,
                left: titleSize.width + spacing / 2,
                bottom: 0,
                right: -(titleSize.width + spacing / 2)
            )
            titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -(imageSize.width + spacing / 2),
                bottom: 0,
                right: imageSize.width + spacing / 2
            )

        case .top:
            imageEdgeInsets = UIEdgeInsets(
                top: -imageOffsetY,
                left: imageOffsetX,
                bottom: imageOffsetY,
                right: -imageOffsetX
            )
            titleEdgeInsets = UIEdgeInsets(
                top: titleOffsetY,
                left: -titleOffsetX,
                bottom: -titleOffsetY,
                right: titleOffsetX
            )

        case .bottom:
            imageEdgeInsets = UIEdgeInsets(
                top: imageOffsetY,
                left: imageOffsetX,
                bottom: -imageOffsetY,
                right: -imageOffsetX
            )
            titleEdgeInsets = UIEdgeInsets(
                top: -titleOffsetY,
                left: -titleOffsetX,
                bottom: titleOffsetY,
                right: titleOffsetX
            )
        }
    }

    // MARK: - Countdown

    func qmui_startCountdown(seconds: Int, format: String = "重新获取(%d秒)") {
        isEnabled = false
        let originalTitle = title(for: .normal)
        objc_setAssociatedObject(self, &qmui_originalTitleKey, originalTitle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        var remaining = seconds
        setTitle(String(format: format, remaining), for: .normal)

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            remaining -= 1
            if remaining <= 0 {
                timer.invalidate()
                self.isEnabled = true
                let saved = objc_getAssociatedObject(self, &qmui_originalTitleKey) as? String
                self.setTitle(saved ?? "获取验证码", for: .normal)
                objc_setAssociatedObject(self, &qmui_countdownTimerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                self.setTitle(String(format: format, remaining), for: .normal)
            }
        }

        objc_setAssociatedObject(self, &qmui_countdownTimerKey, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func qmui_stopCountdown() {
        if let timer = objc_getAssociatedObject(self, &qmui_countdownTimerKey) as? Timer {
            timer.invalidate()
            objc_setAssociatedObject(self, &qmui_countdownTimerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        isEnabled = true
        let saved = objc_getAssociatedObject(self, &qmui_originalTitleKey) as? String
        setTitle(saved ?? "获取验证码", for: .normal)
    }
}
