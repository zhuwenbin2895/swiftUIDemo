import SwiftUI
import Combine
import UniformTypeIdentifiers

// MARK: - TreeView

struct TreeView<CustomContent: View>: View {
    @ObservedObject var manager: TreeViewManager
    var customNodeView: ((TreeNode, TreeViewManager) -> CustomContent)?

    init(manager: TreeViewManager, @ViewBuilder customNodeView: @escaping (TreeNode, TreeViewManager) -> CustomContent) {
        self.manager = manager
        self.customNodeView = customNodeView
    }

    var body: some View {
        ScrollViewReader { proxy in
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(manager.flattenedNodes) { node in
                    TreeNodeRow(node: node, manager: manager, customContent: customNodeView)
                        .id(node.id)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .onChange(of: manager.scrollTargetNodeID) { targetID in
                guard let targetID = targetID else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(targetID, anchor: .center)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    manager.scrollTargetNodeID = nil
                }
            }
        }
    }
}

extension TreeView where CustomContent == EmptyView {
    init(manager: TreeViewManager) {
        self.manager = manager
        self.customNodeView = nil
    }
}

// MARK: - Tree Node Row

struct TreeNodeRow<CustomContent: View>: View {
    @ObservedObject var node: TreeNode
    @ObservedObject var manager: TreeViewManager
    var customContent: ((TreeNode, TreeViewManager) -> CustomContent)?
    @State private var isDragOver = false

    var body: some View {
        HStack(spacing: 0) {
            indentArea
            expandButton
            if manager.config.showCheckboxes {
                checkboxButton
            }
            if let customContent = customContent {
                customContent(node, manager)
            } else {
                defaultNodeContent
            }
            Spacer()
            if node.isLoading {
                ProgressView()
                    .scaleEffect(0.7)
                    .padding(.trailing, 8)
            }
        }
        .frame(minHeight: manager.config.nodeHeight)
        .background(backgroundColor)
        .contentShape(Rectangle())
        .onTapGesture {
            manager.toggleExpand(node)
            manager.onNodeTap?(node)
        }
        .contextMenu {
            contextMenuItems
        }
        .onDrop(of: [.text], isTargeted: $isDragOver) { providers in
            handleDrop(providers)
        }
        .onDrag {
            NSItemProvider(object: node.id as NSString)
        }
        .overlay(
            isDragOver ?
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.blue, lineWidth: 2)
                .padding(2)
            : nil
        )
    }

    // MARK: - Default Node Content (icon + title)

    private var defaultNodeContent: some View {
        HStack(spacing: 4) {
            nodeIcon
            nodeTitle
        }
    }

    // MARK: - Indent Area with Connector Lines

    private var indentArea: some View {
        HStack(spacing: 0) {
            if manager.config.showConnectorLines && node.depth > 0 {
                ForEach(0..<node.depth, id: \.self) { level in
                    connectorLine(at: level)
                }
            } else {
                Spacer()
                    .frame(width: manager.config.indentForDepth(node.depth))
            }
        }
    }

    private func connectorLine(at level: Int) -> some View {
        ZStack {
            if level == node.depth - 1 {
                Path { path in
                    let midX = manager.config.indentWidth / 2
                    path.move(to: CGPoint(x: midX, y: 0))
                    path.addLine(to: CGPoint(x: midX, y: manager.config.nodeHeight / 2))
                    path.addLine(to: CGPoint(x: manager.config.indentWidth, y: manager.config.nodeHeight / 2))
                }
                .stroke(manager.config.connectorLineColor, lineWidth: manager.config.connectorLineWidth)

                if !isLastChild {
                    Path { path in
                        let midX = manager.config.indentWidth / 2
                        path.move(to: CGPoint(x: midX, y: manager.config.nodeHeight / 2))
                        path.addLine(to: CGPoint(x: midX, y: manager.config.nodeHeight))
                    }
                    .stroke(manager.config.connectorLineColor, lineWidth: manager.config.connectorLineWidth)
                }
            } else if hasAncestorSibling(at: level) {
                Path { path in
                    let midX = manager.config.indentWidth / 2
                    path.move(to: CGPoint(x: midX, y: 0))
                    path.addLine(to: CGPoint(x: midX, y: manager.config.nodeHeight))
                }
                .stroke(manager.config.connectorLineColor, lineWidth: manager.config.connectorLineWidth)
            }
        }
        .frame(width: manager.config.indentWidth, height: manager.config.nodeHeight)
    }

    private var isLastChild: Bool {
        guard let parent = manager.findParent(of: node) else {
            return manager.roots.last?.id == node.id
        }
        return parent.children.last?.id == node.id
    }

    private func hasAncestorSibling(at level: Int) -> Bool {
        var current = node
        var currentDepth = node.depth
        while currentDepth > level + 1 {
            guard let parent = manager.findParent(of: current) else { return false }
            current = parent
            currentDepth -= 1
        }
        guard let parent = manager.findParent(of: current) else { return false }
        guard let index = parent.children.firstIndex(of: current) else { return false }
        return index < parent.children.count - 1
    }

    // MARK: - Expand Button

    private var expandButton: some View {
        Group {
            if !node.isLeaf || node.hasAsyncChildren {
                Image(systemName: node.isExpanded ? manager.config.collapseIcon : manager.config.expandIcon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
            } else {
                Spacer().frame(width: 20)
            }
        }
    }

    // MARK: - Checkbox

    private var checkboxButton: some View {
        Button {
            manager.toggleSelection(node)
        } label: {
            Image(systemName: node.isSelected ? "checkmark.square.fill" : "square")
                .foregroundColor(node.isSelected ? .blue : .secondary)
                .font(.system(size: 16))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }

    // MARK: - Icon

    private var nodeIcon: some View {
        Group {
            if let icon = node.icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                    .frame(width: 20)
            } else if node.isLeaf {
                Image(systemName: manager.config.leafIcon)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            } else {
                Image(systemName: node.isExpanded ? manager.config.folderOpenIcon : manager.config.folderIcon)
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .frame(width: 20)
            }
        }
    }

    private var iconColor: Color {
        guard let icon = node.icon else { return .secondary }
        switch icon {
        case "swift": return .orange
        case "folder", "folder.fill": return .blue
        case "network": return .green
        case "photo", "photo.artframe": return .purple
        default: return .secondary
        }
    }

    // MARK: - Title

    private var nodeTitle: some View {
        Text(node.title)
            .font(.system(size: 15))
            .foregroundColor(node.isHighlighted ? .blue : .primary)
            .fontWeight(node.isHighlighted ? .semibold : .regular)
            .lineLimit(1)
    }

    // MARK: - Background

    private var backgroundColor: Color {
        if node.isHighlighted {
            return manager.config.highlightColor
        }
        if isDragOver {
            return Color.blue.opacity(0.05)
        }
        return .clear
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuItems: some View {
        Button {
            manager.toggleExpand(node)
        } label: {
            Label(node.isExpanded ? "折叠" : "展开", systemImage: node.isExpanded ? "chevron.up" : "chevron.down")
        }
        .disabled(node.isLeaf)

        Button {
            manager.toggleSelection(node)
        } label: {
            Label(node.isSelected ? "取消选中" : "选中", systemImage: node.isSelected ? "xmark.circle" : "checkmark.circle")
        }

        Divider()

        Button {
            let newNode = TreeNode(title: "新节点", icon: "doc.badge.plus")
            manager.addNode(newNode, to: node)
            node.isExpanded = true
            manager.rebuildFlatList()
        } label: {
            Label("添加子节点", systemImage: "plus.circle")
        }

        Button(role: .destructive) {
            manager.removeNode(node)
        } label: {
            Label("删除节点", systemImage: "trash")
        }
    }

    // MARK: - Drag & Drop

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadObject(ofClass: NSString.self) { reading, _ in
            guard let sourceID = reading as? String,
                  let sourceNode = manager.findNode(id: sourceID) else { return }
            DispatchQueue.main.async {
                manager.moveNode(sourceNode, to: node)
            }
        }
        return true
    }
}
