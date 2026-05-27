import UIKit

class TGRelativeLayout: TGBaseLayout {

    override func performLayout() {
        let views = layoutSubviews(for: tgLayoutTarget)
        guard !views.isEmpty else { return }

        let contentRect = CGRect(
            x: tgPadding.left,
            y: tgPadding.top,
            width: bounds.width - tgPadding.left - tgPadding.right,
            height: bounds.height - tgPadding.top - tgPadding.bottom
        )

        var resolved: Set<ObjectIdentifier> = []
        var iterations = 0
        let maxIterations = views.count * 2

        while resolved.count < views.count && iterations < maxIterations {
            iterations += 1
            for view in views where !resolved.contains(ObjectIdentifier(view)) {
                if canResolve(view: view, resolved: resolved) {
                    resolveFrame(for: view, in: contentRect)
                    resolved.insert(ObjectIdentifier(view))
                }
            }
        }

        for view in views where !resolved.contains(ObjectIdentifier(view)) {
            resolveFrame(for: view, in: contentRect)
        }
    }

    private func canResolve(view: UIView, resolved: Set<ObjectIdentifier>) -> Bool {
        let props = view.tg
        let deps: [UIView?] = [props.leftOf, props.rightOf, props.above, props.below,
                                props.alignLeft, props.alignRight, props.alignTop, props.alignBottom]
        for dep in deps.compactMap({ $0 }) {
            if !resolved.contains(ObjectIdentifier(dep)) {
                return false
            }
        }
        return true
    }

    private func resolveFrame(for view: UIView, in contentRect: CGRect) {
        let props = view.tg
        let margin = cachedMargin(for: view)
        var frame = view.frame

        if props.widthRatio > 0 {
            frame.size.width = contentRect.width * props.widthRatio - margin.left - margin.right
        }
        if props.heightRatio > 0 {
            frame.size.height = contentRect.height * props.heightRatio - margin.top - margin.bottom
        }

        // Horizontal positioning
        if let leftOf = props.leftOf {
            frame.origin.x = leftOf.frame.minX - frame.width - margin.right
        } else if let rightOf = props.rightOf {
            frame.origin.x = rightOf.frame.maxX + margin.left
        } else if let alignLeft = props.alignLeft {
            frame.origin.x = alignLeft.frame.minX + margin.left
        } else if let alignRight = props.alignRight {
            frame.origin.x = alignRight.frame.maxX - frame.width - margin.right
        } else if props.centerX {
            frame.origin.x = contentRect.midX - frame.width / 2
        } else {
            frame.origin.x = contentRect.origin.x + margin.left
        }

        // Vertical positioning
        if let above = props.above {
            frame.origin.y = above.frame.minY - frame.height - margin.bottom
        } else if let below = props.below {
            frame.origin.y = below.frame.maxY + margin.top
        } else if let alignTop = props.alignTop {
            frame.origin.y = alignTop.frame.minY + margin.top
        } else if let alignBottom = props.alignBottom {
            frame.origin.y = alignBottom.frame.maxY - frame.height - margin.bottom
        } else if props.centerY {
            frame.origin.y = contentRect.midY - frame.height / 2
        } else {
            frame.origin.y = contentRect.origin.y + margin.top
        }

        frame.origin.x += props.offsetX
        frame.origin.y += props.offsetY

        view.frame = frame
    }
}
