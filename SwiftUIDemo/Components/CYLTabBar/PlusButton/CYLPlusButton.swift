import UIKit

class CYLPlusButton: NSObject, CYLPlusButtonProtocol {
    private(set) lazy var plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = _plusButtonWidth / 2
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()

    private var _plusButtonWidth: CGFloat
    private var _plusButtonHeight: CGFloat
    private var _centerOffset: CGPoint
    private var _attachedController: UIViewController?
    private var _clickHandler: ((UIButton) -> Void)?

    var plusButtonWidth: CGFloat { _plusButtonWidth }
    var plusButtonHeight: CGFloat { _plusButtonHeight }
    var plusButtonCenterOffset: CGPoint { _centerOffset }
    var tabBarItemAttachedController: UIViewController? { _attachedController }

    init(
        width: CGFloat = 56,
        height: CGFloat = 56,
        centerOffset: CGPoint = .zero,
        attachedController: UIViewController? = nil,
        clickHandler: ((UIButton) -> Void)? = nil
    ) {
        _plusButtonWidth = width
        _plusButtonHeight = height
        _centerOffset = centerOffset
        _attachedController = attachedController
        _clickHandler = clickHandler
        super.init()
    }

    func plusButtonClicked(_ sender: UIButton) {
        _clickHandler?(sender)
    }
}
