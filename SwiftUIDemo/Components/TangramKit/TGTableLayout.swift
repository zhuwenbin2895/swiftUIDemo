import UIKit

class TGTableLayout: TGBaseLayout {
    var columns: Int = 1
    var rowSpacing: CGFloat = 0
    var columnSpacing: CGFloat = 0

    convenience init(columns: Int) {
        self.init(frame: .zero)
        self.columns = max(1, columns)
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

        let grid = buildGrid(views: views)
        let colWidth = (contentRect.width - columnSpacing * CGFloat(columns - 1)) / CGFloat(columns)

        var y = contentRect.origin.y

        for row in grid {
            var rowHeight: CGFloat = 0
            for cell in row {
                let margin = cachedMargin(for: cell.view)
                let h = cell.view.frame.height + margin.top + margin.bottom
                rowHeight = max(rowHeight, h / CGFloat(cell.rowSpan))
            }

            for cell in row {
                let margin = cachedMargin(for: cell.view)
                let spanWidth = colWidth * CGFloat(cell.colSpan) + columnSpacing * CGFloat(cell.colSpan - 1)
                let spanHeight = rowHeight * CGFloat(cell.rowSpan) + rowSpacing * CGFloat(cell.rowSpan - 1)

                var frame = cell.view.frame
                frame.origin.x = contentRect.origin.x + CGFloat(cell.col) * (colWidth + columnSpacing) + margin.left
                frame.origin.y = y + margin.top
                frame.size.width = spanWidth - margin.left - margin.right
                frame.size.height = spanHeight - margin.top - margin.bottom

                if cell.view.tg.widthRatio > 0 {
                    frame.size.width = spanWidth * cell.view.tg.widthRatio
                }
                if cell.view.tg.heightRatio > 0 {
                    frame.size.height = spanHeight * cell.view.tg.heightRatio
                }

                cell.view.frame = frame
            }

            y += rowHeight + rowSpacing
        }
    }

    private struct GridCell {
        let view: UIView
        let row: Int
        let col: Int
        let rowSpan: Int
        let colSpan: Int
    }

    private func buildGrid(views: [UIView]) -> [[GridCell]] {
        var grid: [[GridCell]] = []
        var occupied: Set<String> = []
        var currentRow = 0
        var currentCol = 0

        for view in views {
            let colSpan = min(view.tg.columnSpan, columns)
            let rowSpan = view.tg.rowSpan

            while occupied.contains("\(currentRow),\(currentCol)") {
                currentCol += 1
                if currentCol >= columns {
                    currentCol = 0
                    currentRow += 1
                }
            }

            if currentCol + colSpan > columns {
                currentCol = 0
                currentRow += 1
            }

            while occupied.contains("\(currentRow),\(currentCol)") {
                currentCol += 1
                if currentCol >= columns {
                    currentCol = 0
                    currentRow += 1
                }
            }

            let cell = GridCell(view: view, row: currentRow, col: currentCol, rowSpan: rowSpan, colSpan: colSpan)

            for r in currentRow..<(currentRow + rowSpan) {
                for c in currentCol..<(currentCol + colSpan) {
                    occupied.insert("\(r),\(c)")
                }
            }

            while grid.count <= currentRow {
                grid.append([])
            }
            grid[currentRow].append(cell)

            currentCol += colSpan
            if currentCol >= columns {
                currentCol = 0
                currentRow += 1
            }
        }

        return grid
    }

    override func calculateIntrinsicSize() -> CGSize {
        let views = layoutSubviews(for: tgLayoutTarget)
        guard !views.isEmpty else { return CGSize(width: tgPadding.left + tgPadding.right, height: tgPadding.top + tgPadding.bottom) }

        let grid = buildGrid(views: views)
        let colWidth = (bounds.width - tgPadding.left - tgPadding.right - columnSpacing * CGFloat(columns - 1)) / CGFloat(columns)

        var totalHeight: CGFloat = 0
        for row in grid {
            var rowHeight: CGFloat = 0
            for cell in row {
                let margin = cachedMargin(for: cell.view)
                let h = cell.view.frame.height + margin.top + margin.bottom
                rowHeight = max(rowHeight, h / CGFloat(cell.rowSpan))
            }
            totalHeight += rowHeight
        }
        totalHeight += rowSpacing * CGFloat(max(0, grid.count - 1))

        let width = CGFloat(columns) * colWidth + CGFloat(columns - 1) * columnSpacing + tgPadding.left + tgPadding.right
        return CGSize(width: width, height: totalHeight + tgPadding.top + tgPadding.bottom)
    }
}
