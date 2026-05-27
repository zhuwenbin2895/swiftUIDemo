import UIKit

class TGFloatLayout: TGBaseLayout {
    var orientation: TGOrientation = .horizontal
    var itemSpacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    var noBoundaryLimit: Bool = false

    enum FloatDirection {
        case left, right
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
        case .horizontal:
            layoutHorizontalFloat(views: views, in: contentRect)
        case .vertical:
            layoutVerticalFloat(views: views, in: contentRect)
        }
    }

    private func layoutHorizontalFloat(views: [UIView], in rect: CGRect) {
        var leftEdges: [(y: CGFloat, maxX: CGFloat, height: CGFloat)] = []
        var rightEdges: [(y: CGFloat, minX: CGFloat, height: CGFloat)] = []

        for view in views {
            let margin = cachedMargin(for: view)
            var frame = view.frame

            if view.tg.widthRatio > 0 {
                frame.size.width = rect.width * view.tg.widthRatio - margin.left - margin.right
            }
            if view.tg.heightRatio > 0 {
                frame.size.height = rect.height * view.tg.heightRatio - margin.top - margin.bottom
            }

            let totalWidth = frame.width + margin.left + margin.right
            let isRight = view.tg.horizontalGravity == .right

            if isRight {
                let placement = findPlacement(totalWidth: totalWidth, totalHeight: frame.height + margin.top + margin.bottom,
                                              in: rect, leftEdges: leftEdges, rightEdges: rightEdges, floatRight: true)
                frame.origin.x = placement.x - frame.width - margin.right
                frame.origin.y = placement.y + margin.top
                rightEdges.append((y: placement.y, minX: frame.origin.x - margin.left, height: frame.height + margin.top + margin.bottom))
            } else {
                let placement = findPlacement(totalWidth: totalWidth, totalHeight: frame.height + margin.top + margin.bottom,
                                              in: rect, leftEdges: leftEdges, rightEdges: rightEdges, floatRight: false)
                frame.origin.x = placement.x + margin.left
                frame.origin.y = placement.y + margin.top
                leftEdges.append((y: placement.y, maxX: frame.origin.x + frame.width + margin.right, height: frame.height + margin.top + margin.bottom))
            }

            frame.origin.x += view.tg.offsetX
            frame.origin.y += view.tg.offsetY
            view.frame = frame
        }
    }

    private func findPlacement(totalWidth: CGFloat, totalHeight: CGFloat, in rect: CGRect,
                               leftEdges: [(y: CGFloat, maxX: CGFloat, height: CGFloat)],
                               rightEdges: [(y: CGFloat, minX: CGFloat, height: CGFloat)],
                               floatRight: Bool) -> CGPoint {
        var y = rect.origin.y
        let step: CGFloat = 1

        while true {
            let leftMax = leftEdges.filter { $0.y <= y && y < $0.y + $0.height }.map { $0.maxX }.max() ?? rect.origin.x
            let rightMin = rightEdges.filter { $0.y <= y && y < $0.y + $0.height }.map { $0.minX }.min() ?? rect.maxX

            let available = rightMin - leftMax - itemSpacing * (leftEdges.isEmpty && rightEdges.isEmpty ? 0 : 1)

            if available >= totalWidth || noBoundaryLimit {
                if floatRight {
                    return CGPoint(x: rightMin - itemSpacing, y: y)
                } else {
                    return CGPoint(x: leftMax + (leftEdges.isEmpty ? 0 : itemSpacing), y: y)
                }
            }

            y += step
            if y > rect.maxY + 1000 { break }
        }

        return CGPoint(x: floatRight ? rect.maxX : rect.origin.x, y: y)
    }

    private func layoutVerticalFloat(views: [UIView], in rect: CGRect) {
        var y = rect.origin.y

        for view in views {
            let margin = cachedMargin(for: view)
            var frame = view.frame

            if view.tg.widthRatio > 0 {
                frame.size.width = rect.width * view.tg.widthRatio - margin.left - margin.right
            }
            if view.tg.heightRatio > 0 {
                frame.size.height = rect.height * view.tg.heightRatio - margin.top - margin.bottom
            }

            frame.origin.y = y + margin.top + view.tg.offsetY

            switch view.tg.horizontalGravity {
            case .left:
                frame.origin.x = rect.origin.x + margin.left
            case .center:
                frame.origin.x = rect.midX - frame.width / 2
            case .right:
                frame.origin.x = rect.maxX - frame.width - margin.right
            case .fill:
                frame.origin.x = rect.origin.x + margin.left
                frame.size.width = rect.width - margin.left - margin.right
            }

            frame.origin.x += view.tg.offsetX
            view.frame = frame
            y = frame.maxY + margin.bottom + lineSpacing
        }
    }
}
