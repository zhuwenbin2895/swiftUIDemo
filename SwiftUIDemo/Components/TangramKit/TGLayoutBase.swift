import UIKit

// MARK: - Enums

enum TGGravity {
    enum Horz {
        case left, center, right, fill
    }
    enum Vert {
        case top, center, bottom, fill
    }
}

enum TGOrientation {
    case horizontal, vertical
}

enum TGLayoutTarget {
    case subviews
    case all
}

// MARK: - Layout Margin (CSS Box Model)

struct TGEdgeInsets: Equatable {
    var top: CGFloat
    var left: CGFloat
    var bottom: CGFloat
    var right: CGFloat

    static let zero = TGEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }

    init(all: CGFloat) {
        self.top = all
        self.left = all
        self.bottom = all
        self.right = all
    }
}

// MARK: - Layout Size

struct TGLayoutSize {
    var width: CGFloat
    var height: CGFloat

    static let zero = TGLayoutSize(width: 0, height: 0)
}

// MARK: - Size Class Support

enum TGSizeClass: Hashable {
    case compact
    case regular
    case any
}

struct TGSizeClassCondition: Hashable {
    var horizontal: TGSizeClass
    var vertical: TGSizeClass

    static let any = TGSizeClassCondition(horizontal: .any, vertical: .any)
    static let compactWidth = TGSizeClassCondition(horizontal: .compact, vertical: .any)
    static let regularWidth = TGSizeClassCondition(horizontal: .regular, vertical: .any)
}

// MARK: - View Layout Properties

class TGLayoutProperties {
    var useFrame: Bool = false
    var layoutMargin: TGEdgeInsets = .zero
    var padding: TGEdgeInsets = .zero
    var widthRatio: CGFloat = 0
    var heightRatio: CGFloat = 0
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var horizontalGravity: TGGravity.Horz = .left
    var verticalGravity: TGGravity.Vert = .top
    var weight: CGFloat = 0

    // Relative layout constraints
    var leftOf: UIView?
    var rightOf: UIView?
    var above: UIView?
    var below: UIView?
    var alignLeft: UIView?
    var alignRight: UIView?
    var alignTop: UIView?
    var alignBottom: UIView?
    var centerX: Bool = false
    var centerY: Bool = false

    // Table layout
    var columnSpan: Int = 1
    var rowSpan: Int = 1
}

private var tgLayoutPropertiesKey: UInt8 = 0

extension UIView {
    var tg: TGLayoutProperties {
        get {
            if let props = objc_getAssociatedObject(self, &tgLayoutPropertiesKey) as? TGLayoutProperties {
                return props
            }
            let props = TGLayoutProperties()
            objc_setAssociatedObject(self, &tgLayoutPropertiesKey, props, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return props
        }
        set {
            objc_setAssociatedObject(self, &tgLayoutPropertiesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Base Layout View

class TGBaseLayout: UIView {
    var tgPadding: TGEdgeInsets = .zero
    var tgHorizontalGravity: TGGravity.Horz = .left
    var tgVerticalGravity: TGGravity.Vert = .top
    var tgLayoutTarget: TGLayoutTarget = .subviews
    var tgAutoSizing: Bool = true

    private var cachedMargins: [ObjectIdentifier: TGEdgeInsets] = [:]
    private var needsLayoutUpdate: Bool = true

    var sizeClassConfigs: [TGSizeClassCondition: () -> Void] = [:]

    override func layoutSubviews() {
        super.layoutSubviews()
        applySizeClassConfig()
        performLayout()
        needsLayoutUpdate = false
    }

    func performLayout() {
        // Subclasses override
    }

    func estimatedSize(maxWidth: CGFloat = .greatestFiniteMagnitude, maxHeight: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let savedFrame = frame
        let savedBounds = bounds

        frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
        bounds = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)

        layoutIfNeeded()
        let size = calculateIntrinsicSize()

        frame = savedFrame
        bounds = savedBounds
        return size
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let savedFrame = frame
        let savedBounds = bounds

        frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        performLayout()
        let result = calculateIntrinsicSize()

        frame = savedFrame
        bounds = savedBounds
        return result
    }

    override var intrinsicContentSize: CGSize {
        return calculateIntrinsicSize()
    }

    func calculateIntrinsicSize() -> CGSize {
        let views = layoutSubviews(for: tgLayoutTarget)
        guard !views.isEmpty else {
            return CGSize(width: tgPadding.left + tgPadding.right,
                          height: tgPadding.top + tgPadding.bottom)
        }

        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        for view in views {
            let margin = cachedMargin(for: view)
            maxX = max(maxX, view.frame.maxX + margin.right)
            maxY = max(maxY, view.frame.maxY + margin.bottom)
        }
        return CGSize(width: maxX + tgPadding.right, height: maxY + tgPadding.bottom)
    }

    func invalidateLayoutCache() {
        cachedMargins.removeAll()
        needsLayoutUpdate = true
        setNeedsLayout()
    }

    func cachedMargin(for view: UIView) -> TGEdgeInsets {
        let id = ObjectIdentifier(view)
        if let cached = cachedMargins[id] {
            return cached
        }
        let margin = view.tg.layoutMargin
        cachedMargins[id] = margin
        return margin
    }

    private func applySizeClassConfig() {
        guard let window = window else { return }
        let hClass: TGSizeClass = window.traitCollection.horizontalSizeClass == .compact ? .compact : .regular
        let vClass: TGSizeClass = window.traitCollection.verticalSizeClass == .compact ? .compact : .regular

        for (condition, config) in sizeClassConfigs {
            let hMatch = condition.horizontal == .any || condition.horizontal == hClass
            let vMatch = condition.vertical == .any || condition.vertical == vClass
            if hMatch && vMatch {
                config()
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        invalidateLayoutCache()
    }

    func layoutSubviews(for target: TGLayoutTarget) -> [UIView] {
        switch target {
        case .subviews:
            return subviews.filter { !$0.isHidden && !$0.tg.useFrame }
        case .all:
            return subviews.filter { !$0.isHidden }
        }
    }

    func applyGravity(childFrame: inout CGRect, in containerRect: CGRect, hGravity: TGGravity.Horz, vGravity: TGGravity.Vert) {
        switch hGravity {
        case .left: break
        case .center: childFrame.origin.x = containerRect.midX - childFrame.width / 2
        case .right: childFrame.origin.x = containerRect.maxX - childFrame.width
        case .fill: childFrame.origin.x = containerRect.origin.x; childFrame.size.width = containerRect.width
        }
        switch vGravity {
        case .top: break
        case .center: childFrame.origin.y = containerRect.midY - childFrame.height / 2
        case .bottom: childFrame.origin.y = containerRect.maxY - childFrame.height
        case .fill: childFrame.origin.y = containerRect.origin.y; childFrame.size.height = containerRect.height
        }
    }
}

// MARK: - XIB Support

extension TGBaseLayout {
    override func awakeFromNib() {
        super.awakeFromNib()
        invalidateLayoutCache()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        performLayout()
    }
}
