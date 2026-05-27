import UIKit

class TGLinearLayout: TGBaseLayout {
    var orientation: TGOrientation = .vertical
    var spacing: CGFloat = 0
    var shrinkType: ShrinkType = .none

    enum ShrinkType {
        case none
        case average
        case weight
    }

    convenience init(orientation: TGOrientation) {
        self.init(frame: .zero)
        self.orientation = orientation
    }

    override func performLayout() {
        let views = layoutSubviews(for: tgLayoutTarget)
        guard !views.isEmpty else { return }

        let contentRect = CGRect(
            x: tgPadding.left,
            y: tgPadding.top,
            width: bounds.width - tgPadding.left - tgPadding.right,
            height: bounds.height - tgPadding.top - tgPadding.bottom
        )

        switch orientation {
        case .vertical:
            layoutVertical(views: views, in: contentRect)
        case .horizontal:
            layoutHorizontal(views: views, in: contentRect)
        }
    }

    private func layoutVertical(views: [UIView], in rect: CGRect) {
        var y = rect.origin.y
        let totalWeight = views.reduce(CGFloat(0)) { $0 + $1.tg.weight }
        let fixedHeight = views.filter { $0.tg.weight == 0 }.reduce(CGFloat(0)) {
            $0 + $1.frame.height + cachedMargin(for: $1).top + cachedMargin(for: $1).bottom
        }
        let totalSpacing = spacing * CGFloat(views.count - 1)
        let remainingHeight = rect.height - fixedHeight - totalSpacing

        for view in views {
            let margin = cachedMargin(for: view)
            y += margin.top

            var childFrame = view.frame
            childFrame.origin.y = y + view.tg.offsetY

            if view.tg.widthRatio > 0 {
                childFrame.size.width = rect.width * view.tg.widthRatio - margin.left - margin.right
            }
            if view.tg.heightRatio > 0 {
                childFrame.size.height = rect.height * view.tg.heightRatio - margin.top - margin.bottom
            }
            if view.tg.weight > 0 && totalWeight > 0 {
                childFrame.size.height = remainingHeight * (view.tg.weight / totalWeight)
            }

            let hGravity = view.tg.horizontalGravity != .left ? view.tg.horizontalGravity : tgHorizontalGravity
            switch hGravity {
            case .left:
                childFrame.origin.x = rect.origin.x + margin.left + view.tg.offsetX
            case .center:
                childFrame.origin.x = rect.origin.x + (rect.width - childFrame.width) / 2 + view.tg.offsetX
            case .right:
                childFrame.origin.x = rect.maxX - childFrame.width - margin.right + view.tg.offsetX
            case .fill:
                childFrame.origin.x = rect.origin.x + margin.left
                childFrame.size.width = rect.width - margin.left - margin.right
            }

            view.frame = childFrame
            y = childFrame.maxY + margin.bottom + spacing
        }
    }

    private func layoutHorizontal(views: [UIView], in rect: CGRect) {
        var x = rect.origin.x
        let totalWeight = views.reduce(CGFloat(0)) { $0 + $1.tg.weight }
        let fixedWidth = views.filter { $0.tg.weight == 0 }.reduce(CGFloat(0)) {
            $0 + $1.frame.width + cachedMargin(for: $1).left + cachedMargin(for: $1).right
        }
        let totalSpacing = spacing * CGFloat(views.count - 1)
        let remainingWidth = rect.width - fixedWidth - totalSpacing

        for view in views {
            let margin = cachedMargin(for: view)
            x += margin.left

            var childFrame = view.frame
            childFrame.origin.x = x + view.tg.offsetX

            if view.tg.widthRatio > 0 {
                childFrame.size.width = rect.width * view.tg.widthRatio - margin.left - margin.right
            }
            if view.tg.heightRatio > 0 {
                childFrame.size.height = rect.height * view.tg.heightRatio - margin.top - margin.bottom
            }
            if view.tg.weight > 0 && totalWeight > 0 {
                childFrame.size.width = remainingWidth * (view.tg.weight / totalWeight)
            }

            let vGravity = view.tg.verticalGravity != .top ? view.tg.verticalGravity : tgVerticalGravity
            switch vGravity {
            case .top:
                childFrame.origin.y = rect.origin.y + margin.top + view.tg.offsetY
            case .center:
                childFrame.origin.y = rect.origin.y + (rect.height - childFrame.height) / 2 + view.tg.offsetY
            case .bottom:
                childFrame.origin.y = rect.maxY - childFrame.height - margin.bottom + view.tg.offsetY
            case .fill:
                childFrame.origin.y = rect.origin.y + margin.top
                childFrame.size.height = rect.height - margin.top - margin.bottom
            }

            view.frame = childFrame
            x = childFrame.maxX + margin.right + spacing
        }
    }

    override func calculateIntrinsicSize() -> CGSize {
        let views = layoutSubviews(for: tgLayoutTarget)
        guard !views.isEmpty else { return CGSize(width: tgPadding.left + tgPadding.right, height: tgPadding.top + tgPadding.bottom) }

        var width: CGFloat = 0
        var height: CGFloat = 0

        switch orientation {
        case .vertical:
            for view in views {
                let margin = cachedMargin(for: view)
                let w = view.frame.width + margin.left + margin.right
                width = max(width, w)
                height += view.frame.height + margin.top + margin.bottom
            }
            height += spacing * CGFloat(views.count - 1)
        case .horizontal:
            for view in views {
                let margin = cachedMargin(for: view)
                let h = view.frame.height + margin.top + margin.bottom
                height = max(height, h)
                width += view.frame.width + margin.left + margin.right
            }
            width += spacing * CGFloat(views.count - 1)
        }

        return CGSize(width: width + tgPadding.left + tgPadding.right,
                      height: height + tgPadding.top + tgPadding.bottom)
    }
}
