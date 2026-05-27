import SwiftUI

// MARK: - TreeView Configuration

struct TreeViewConfig {
    var indentWidth: CGFloat = 24
    var showConnectorLines: Bool = true
    var connectorLineColor: Color = .gray.opacity(0.4)
    var connectorLineWidth: CGFloat = 1
    var maxDepth: Int = .max
    var animationDuration: Double = 0.3
    var nodeHeight: CGFloat = 44
    var showCheckboxes: Bool = false
    var highlightColor: Color = .blue.opacity(0.1)
    var expandIcon: String = "chevron.right"
    var collapseIcon: String = "chevron.down"
    var leafIcon: String = "doc"
    var folderIcon: String = "folder"
    var folderOpenIcon: String = "folder.fill"

    enum IndentStyle {
        case fixed
        case progressive(multiplier: CGFloat)
        case custom((Int) -> CGFloat)
    }

    var indentStyle: IndentStyle = .fixed

    func indentForDepth(_ depth: Int) -> CGFloat {
        switch indentStyle {
        case .fixed:
            return CGFloat(depth) * indentWidth
        case .progressive(let multiplier):
            if depth == 0 { return 0 }
            return CGFloat(depth) * indentWidth * pow(multiplier, CGFloat(depth - 1))
        case .custom(let calculator):
            return calculator(depth)
        }
    }
}
