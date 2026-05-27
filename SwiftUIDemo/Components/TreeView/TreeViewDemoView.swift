import SwiftUI
import Combine

// MARK: - TreeView Demo

struct TreeViewDemoView: View {
    var body: some View {
        List {
            Section("基础功能") {
                NavigationLink("基础树形结构") {
                    BasicTreeDemo()
                }
                NavigationLink("连接线显示") {
                    ConnectorLinesDemo()
                }
                NavigationLink("自定义缩进") {
                    CustomIndentDemo()
                }
            }
            Section("节点操作") {
                NavigationLink("复选框多选") {
                    CheckboxTreeDemo()
                }
                NavigationLink("自定义节点视图") {
                    CustomNodeViewDemo()
                }
                NavigationLink("自定义节点图标") {
                    CustomIconDemo()
                }
                NavigationLink("节点高亮") {
                    HighlightDemo()
                }
            }
            Section("交互操作") {
                NavigationLink("展开/折叠动画") {
                    ExpandCollapseDemo()
                }
                NavigationLink("长按菜单 & 拖拽") {
                    DragDropDemo()
                }
                NavigationLink("搜索并展开路径") {
                    SearchTreeDemo()
                }
                NavigationLink("滚动到指定节点") {
                    ScrollToNodeDemo()
                }
            }
            Section("数据操作") {
                NavigationLink("展开/折叠全部") {
                    ExpandAllDemo()
                }
                NavigationLink("异步加载子节点") {
                    AsyncLoadDemo()
                }
                NavigationLink("动态增删节点") {
                    DynamicNodeDemo()
                }
            }
            Section("性能测试") {
                NavigationLink("大数据量树") {
                    LargeDataDemo()
                }
                NavigationLink("JSON 解析构建") {
                    JSONParseDemo()
                }
            }
        }
        .navigationTitle("TreeView")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Basic Tree Demo

struct BasicTreeDemo: View {
    @StateObject private var manager = TreeViewManager()

    var body: some View {
        ScrollView {
            TreeView(manager: manager)
                .padding()
        }
        .navigationTitle("基础树形结构")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.rebuildFlatList()
        }
    }
}

// MARK: - Connector Lines Demo

struct ConnectorLinesDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        config.connectorLineColor = .blue.opacity(0.3)
        config.connectorLineWidth = 1.5
        return TreeViewManager(config: config)
    }()

    var body: some View {
        ScrollView {
            TreeView(manager: manager)
                .padding()
        }
        .navigationTitle("连接线显示")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.expandToLevel(2)
        }
    }
}

// MARK: - Custom Indent Demo

struct CustomIndentDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.indentWidth = 32
        config.indentStyle = .progressive(multiplier: 0.85)
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    @State private var indentWidth: CGFloat = 32

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("缩进宽度: \(Int(indentWidth))pt")
                    .font(.caption)
                Slider(value: $indentWidth, in: 12...48, step: 4)
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("自定义缩进")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.expandToLevel(3)
        }
        .onChange(of: indentWidth) { newValue in
            manager.config.indentWidth = newValue
            manager.objectWillChange.send()
        }
    }
}

// MARK: - Checkbox Demo

struct CheckboxTreeDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showCheckboxes = true
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    @State private var selectedCount = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("已选中: \(selectedCount) 个节点")
                    .font(.subheadline)
                Spacer()
                Button("全选") { manager.selectAll(); updateCount() }
                Button("取消") { manager.deselectAll(); updateCount() }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("复选框多选")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.expandToLevel(2)
            manager.onNodeTap = { _ in updateCount() }
        }
    }

    private func updateCount() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedCount = manager.getSelectedNodes().count
        }
    }
}

// MARK: - Custom Icon Demo

struct CustomIconDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.expandIcon = "arrowtriangle.right.fill"
        config.collapseIcon = "arrowtriangle.down.fill"
        config.leafIcon = "doc.text"
        config.folderIcon = "folder"
        config.folderOpenIcon = "folder.fill"
        config.showConnectorLines = false
        return TreeViewManager(config: config)
    }()

    var body: some View {
        ScrollView {
            TreeView(manager: manager)
                .padding()
        }
        .navigationTitle("自定义节点图标")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.expandToLevel(2)
        }
    }
}

// MARK: - Highlight Demo

struct HighlightDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        config.highlightColor = .yellow.opacity(0.3)
        return TreeViewManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("高亮 Views") {
                    clearAndHighlight(["1-1-2-1", "1-1-2-2", "1-1-2-3"])
                }
                .buttonStyle(.bordered)
                Button("高亮 Models") {
                    clearAndHighlight(["1-1-3-1", "1-1-3-2"])
                }
                .buttonStyle(.bordered)
                Button("清除") {
                    for node in manager.flattenedNodes {
                        node.isHighlighted = false
                    }
                    manager.objectWillChange.send()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("节点高亮")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.expandToLevel(3)
        }
    }

    private func clearAndHighlight(_ ids: [String]) {
        for root in manager.roots {
            clearHighlight(root)
        }
        for id in ids {
            if let node = manager.findNode(id: id) {
                node.isHighlighted = true
                manager.expandPath(to: node)
            }
        }
        manager.objectWillChange.send()
        manager.rebuildFlatList()
    }

    private func clearHighlight(_ node: TreeNode) {
        node.isHighlighted = false
        for child in node.children {
            clearHighlight(child)
        }
    }
}

// MARK: - Expand/Collapse Demo

struct ExpandCollapseDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        config.animationDuration = 0.35
        return TreeViewManager(config: config)
    }()

    @State private var expandLevel: Double = 1

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Button("全部展开") {
                        withAnimation { manager.expandAll() }
                    }
                    .buttonStyle(.bordered)
                    Button("全部折叠") {
                        withAnimation { manager.collapseAll() }
                    }
                    .buttonStyle(.bordered)
                }
                HStack {
                    Text("展开到第 \(Int(expandLevel)) 层")
                        .font(.caption)
                    Slider(value: $expandLevel, in: 0...4, step: 1)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("展开/折叠动画")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.rebuildFlatList()
        }
        .onChange(of: expandLevel) { newValue in
            withAnimation {
                manager.expandToLevel(Int(newValue))
            }
        }
    }
}

// MARK: - Drag & Drop Demo

struct DragDropDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    @State private var message = "长按节点弹出菜单，拖拽节点可移动位置"

    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("长按菜单 & 拖拽")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.expandToLevel(2)
            manager.onNodeMove = { source, target in
                message = "已将 \"\(source.title)\" 移至 \"\(target.title)\" 下"
            }
        }
    }
}

// MARK: - Search Demo

struct SearchTreeDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        config.highlightColor = .orange.opacity(0.2)
        return TreeViewManager(config: config)
    }()

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索节点...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        manager.search("")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            if !manager.searchResults.isEmpty {
                Text("找到 \(manager.searchResults.count) 个结果")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("搜索并展开路径")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.rebuildFlatList()
        }
        .onChange(of: searchText) { newValue in
            manager.search(newValue)
        }
    }
}

// MARK: - Expand All Demo

struct ExpandAllDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button("展开全部") {
                        withAnimation { manager.expandAll() }
                    }.buttonStyle(.borderedProminent)
                    Button("折叠全部") {
                        withAnimation { manager.collapseAll() }
                    }.buttonStyle(.bordered)
                    Button("展开1层") {
                        withAnimation { manager.expandToLevel(1) }
                    }.buttonStyle(.bordered)
                    Button("展开2层") {
                        withAnimation { manager.expandToLevel(2) }
                    }.buttonStyle(.bordered)
                    Button("展开3层") {
                        withAnimation { manager.expandToLevel(3) }
                    }.buttonStyle(.bordered)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))

            Text("已选中节点: \(manager.getSelectedNodes().map(\.title).joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .lineLimit(2)

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("展开/折叠全部")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.config.showCheckboxes = true
            manager.roots = TreeViewManager.sampleData()
            manager.rebuildFlatList()
        }
    }
}

// MARK: - Async Load Demo

struct AsyncLoadDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    @State private var loadCount = 0

    var body: some View {
        VStack(spacing: 0) {
            Text("点击带异步标记的节点会延迟加载子节点 (已加载 \(loadCount) 次)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("异步加载子节点")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let asyncRoot = TreeNode(id: "async-1", title: "远程数据", icon: "cloud", hasAsyncChildren: true)
            let asyncRoot2 = TreeNode(id: "async-2", title: "数据库表", icon: "cylinder", hasAsyncChildren: true)
            let asyncRoot3 = TreeNode(id: "async-3", title: "API接口", icon: "network", hasAsyncChildren: true)
            manager.roots = [asyncRoot, asyncRoot2, asyncRoot3]
            manager.rebuildFlatList()

            manager.asyncChildLoader = { node in
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                self.loadCount += 1
                let count = Int.random(in: 2...5)
                return (0..<count).map { i in
                    let child = TreeNode(
                        id: "\(node.id)-child-\(i)",
                        title: "\(node.title) - 子项 \(i + 1)",
                        icon: "doc",
                        hasAsyncChildren: node.depth < 2
                    )
                    return child
                }
            }
        }
    }
}

// MARK: - Dynamic Node Demo

struct DynamicNodeDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    @State private var newNodeName = ""
    @State private var selectedParentID: String? = nil
    @State private var nodeCount = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    TextField("节点名称", text: $newNodeName)
                        .textFieldStyle(.roundedBorder)
                    Button("添加") {
                        addNode()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newNodeName.isEmpty)
                }
                HStack {
                    Text("总节点数: \(nodeCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("删除选中") {
                        let selected = manager.getSelectedNodes()
                        for node in selected {
                            manager.removeNode(node)
                        }
                        updateCount()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("动态增删节点")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.config.showCheckboxes = true
            let root = TreeNode(id: "root", title: "根节点", icon: "folder.fill")
            manager.roots = [root]
            manager.rebuildFlatList()
            updateCount()
        }
    }

    private func addNode() {
        let node = TreeNode(title: newNodeName, icon: "doc.badge.plus")
        let selected = manager.getSelectedNodes()
        let parent = selected.first ?? manager.roots.first
        manager.addNode(node, to: parent)
        if let parent = parent {
            parent.isExpanded = true
            manager.objectWillChange.send()
            manager.rebuildFlatList()
        }
        newNodeName = ""
        updateCount()
    }

    private func updateCount() {
        var count = 0
        for root in manager.roots {
            count += 1 + root.allDescendants().count
        }
        nodeCount = count
    }
}

// MARK: - Large Data Demo

struct LargeDataDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    @State private var generationTime: TimeInterval = 0
    @State private var totalNodes = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("大数据量性能测试")
                    .font(.subheadline.bold())
                Text("共 \(totalNodes) 个节点，生成耗时 \(String(format: "%.2f", generationTime))s")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack {
                    Button("展开2层") {
                        withAnimation { manager.expandToLevel(2) }
                    }.buttonStyle(.bordered)
                    Button("展开3层") {
                        withAnimation { manager.expandToLevel(3) }
                    }.buttonStyle(.bordered)
                    Button("折叠全部") {
                        withAnimation { manager.collapseAll() }
                    }.buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("大数据量树")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateLargeTree()
        }
    }

    private func generateLargeTree() {
        let start = Date()
        var roots: [TreeNode] = []
        var count = 0

        for i in 0..<10 {
            let root = TreeNode(id: "r\(i)", title: "部门 \(i + 1)", icon: "building.2")
            for j in 0..<10 {
                let team = TreeNode(id: "r\(i)-t\(j)", title: "团队 \(j + 1)", icon: "person.3")
                for k in 0..<10 {
                    let member = TreeNode(id: "r\(i)-t\(j)-m\(k)", title: "成员 \(k + 1)", icon: "person")
                    for l in 0..<5 {
                        let task = TreeNode(id: "r\(i)-t\(j)-m\(k)-task\(l)", title: "任务 \(l + 1)", icon: "checklist")
                        member.addChild(task)
                        count += 1
                    }
                    team.addChild(member)
                    count += 1
                }
                root.addChild(team)
                count += 1
            }
            roots.append(root)
            count += 1
        }

        generationTime = Date().timeIntervalSince(start)
        totalNodes = count
        manager.roots = roots
        manager.rebuildFlatList()
    }
}

// MARK: - JSON Parse Demo

struct JSONParseDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    @State private var jsonText = """
    [
      {
        "id": "org",
        "title": "公司组织",
        "icon": "building.2",
        "children": [
          {
            "id": "tech",
            "title": "技术部",
            "icon": "desktopcomputer",
            "children": [
              {"id": "ios", "title": "iOS团队", "icon": "iphone"},
              {"id": "android", "title": "Android团队", "icon": "phone"},
              {"id": "backend", "title": "后端团队", "icon": "server.rack"}
            ]
          },
          {
            "id": "design",
            "title": "设计部",
            "icon": "paintpalette",
            "children": [
              {"id": "ui", "title": "UI设计", "icon": "paintbrush"},
              {"id": "ux", "title": "UX设计", "icon": "person.crop.circle"}
            ]
          },
          {
            "id": "pm",
            "title": "产品部",
            "icon": "lightbulb",
            "children": [
              {"id": "pm1", "title": "产品经理A", "icon": "person"},
              {"id": "pm2", "title": "产品经理B", "icon": "person"}
            ]
          }
        ]
      }
    ]
    """
    @State private var parseSuccess = false
    @State private var parseError = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("输入 JSON 数据构建树结构")
                    .font(.subheadline.bold())
                TextEditor(text: $jsonText)
                    .font(.system(.caption, design: .monospaced))
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3))
                    )
                HStack {
                    Button("解析 JSON") {
                        parseJSON()
                    }
                    .buttonStyle(.borderedProminent)
                    if parseSuccess {
                        Text("解析成功")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    if !parseError.isEmpty {
                        Text(parseError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("JSON 解析构建")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            parseJSON()
        }
    }

    private func parseJSON() {
        parseError = ""
        parseSuccess = false
        manager.loadFromJSONString(jsonText)
        if manager.roots.isEmpty {
            parseError = "解析失败，请检查JSON格式"
        } else {
            parseSuccess = true
            manager.expandAll()
        }
    }
}

// MARK: - Custom Node View Demo

struct CustomNodeViewDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        config.nodeHeight = 56
        return TreeViewManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 0) {
            Text("使用自定义视图渲染每个节点，展示头像、副标题、徽章等")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager) { node, _ in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Self.colorForNode(node))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(String(node.title.prefix(1)))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(node.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(node.isHighlighted ? .blue : .primary)
                            Text(node.isLeaf ? "叶子节点" : "\(node.children.count) 个子项")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if !node.isLeaf {
                            Text("\(node.children.count)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.blue.opacity(0.7)))
                        }

                        if node.isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                        }
                    }
                    .padding(.trailing, 12)
                }
                .padding()
            }
        }
        .navigationTitle("自定义节点视图")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.config.showCheckboxes = false
            manager.roots = TreeViewManager.sampleData()
            manager.expandToLevel(2)
        }
    }

    private static func colorForNode(_ node: TreeNode) -> Color {
        if node.isLeaf {
            return .orange
        }
        switch node.depth {
        case 0: return .blue
        case 1: return .purple
        case 2: return .green
        default: return .gray
        }
    }
}

// MARK: - Scroll To Node Demo

struct ScrollToNodeDemo: View {
    @StateObject private var manager: TreeViewManager = {
        var config = TreeViewConfig()
        config.showConnectorLines = true
        return TreeViewManager(config: config)
    }()

    @State private var targetNodeIDs = [
        ("1-1-4-2", "Endpoints.swift"),
        ("1-3-2-1", "LoginUITests.swift"),
        ("1-1-2-3", "SettingsView.swift"),
        ("1-1-1-2", "SceneDelegate.swift"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("点击按钮自动展开路径并滚动到目标节点")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(targetNodeIDs, id: \.0) { id, name in
                            Button(name) {
                                if let node = manager.findNode(id: id) {
                                    node.isHighlighted = true
                                    manager.scrollToNode(node)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        node.isHighlighted = false
                                        manager.objectWillChange.send()
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ScrollView {
                TreeView(manager: manager)
                    .padding()
            }
        }
        .navigationTitle("滚动到指定节点")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.roots = TreeViewManager.sampleData()
            manager.rebuildFlatList()
        }
    }
}
