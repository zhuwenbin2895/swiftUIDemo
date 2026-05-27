import UIKit

class TGFlowLayout: TGBaseLayout {
    var orientation: TGOrientation = .horizontal
    var itemSpacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    var arrangedCount: Int = 0 // 0 means auto

    convenience init(orientation: TGOrientation, arrangedCount: Int = 0) {
        self.init(frame: .zero)
        self.orientation = orientation
        self.arrangedCount = arrangedCount
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
            layoutHorizontalFlow(views: views, in: contentRect)
        case .vertical:
            layoutVerticalFlow(views: views, in: contentRect)
        }
    }

    private func layoutHorizontalFlow(views: [UIView], in rect: CGRect) {
        var x = rect.origin.x
        var y = rect.origin.y
        var lineHeight: CGFloat = 0
        var countInLine = 0

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
            let needsWrap = arrangedCount > 0 ? (countInLine >= arrangedCount) : (x + totalWidth > rect.maxX && countInLine > 0)

            if needsWrap {
                x = rect.origin.x
                y += lineHeight + lineSpacing
                lineHeight = 0
                countInLine = 0
            }

            frame.origin.x = x + margin.left + view.tg.offsetX
            frame.origin.y = y + margin.top + view.tg.offsetY
            view.frame = frame

            lineHeight = max(lineHeight, frame.height + margin.top + margin.bottom)
            x += totalWidth + itemSpacing
            countInLine += 1
        }
    }

    private func layoutVerticalFlow(views: [UIView], in rect: CGRect) {
        var x = rect.origin.x
        var y = rect.origin.y
        var colWidth: CGFloat = 0
        var countInCol = 0

        for view in views {
            let margin = cachedMargin(for: view)
            var frame = view.frame

            if view.tg.widthRatio > 0 {
                frame.size.width = rect.width * view.tg.widthRatio - margin.left - margin.right
            }
            if view.tg.heightRatio > 0 {
                frame.size.height = rect.height * view.tg.heightRatio - margin.top - margin.bottom
            }

            let totalHeight = frame.height + margin.top + margin.bottom
            let needsWrap = arrangedCount > 0 ? (countInCol >= arrangedCount) : (y + totalHeight > rect.maxY && countInCol > 0)

            if needsWrap {
                y = rect.origin.y
                x += colWidth + itemSpacing
                colWidth = 0
                countInCol = 0
            }

            frame.origin.x = x + margin.left + view.tg.offsetX
            frame.origin.y = y + margin.top + view.tg.offsetY
            view.frame = frame

            colWidth = max(colWidth, frame.width + margin.left + margin.right)
            y += totalHeight + lineSpacing
            countInCol += 1
        }
    }
}
