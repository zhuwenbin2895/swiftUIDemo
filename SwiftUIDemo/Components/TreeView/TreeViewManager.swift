import SwiftUI
import Combine

// MARK: - TreeView Manager

class TreeViewManager: ObservableObject {
    @Published var roots: [TreeNode] = []
    @Published var flattenedNodes: [TreeNode] = []
    @Published var searchText: String = ""
    @Published var searchResults: [TreeNode] = []
    @Published var scrollTargetNodeID: String?

    var config: TreeViewConfig
    var asyncChildLoader: ((TreeNode) async -> [TreeNode])?
    var onNodeTap: ((TreeNode) -> Void)?
    var onNodeLongPress: ((TreeNode) -> Void)?
    var onNodeMove: ((TreeNode, TreeNode) -> Void)?

    private var allNodesMap: [String: TreeNode] = [:]
    private var cancellables = Set<AnyCancellable>()

    init(config: TreeViewConfig = TreeViewConfig()) {
        self.config = config
    }

    // MARK: - Build from JSON

    func loadFromJSON(_ data: Data) {
        do {
            let nodes = try JSONDecoder().decode([TreeNode].self, from: data)
            self.roots = nodes
            rebuildFlatList()
            rebuildNodeMap()
        } catch {
            print("TreeView JSON parse error: \(error)")
        }
    }

    func loadFromJSONString(_ json: String) {
        guard let data = json.data(using: .utf8) else { return }
        loadFromJSON(data)
    }

    // MARK: - Flatten

    func rebuildFlatList() {
        var result: [TreeNode] = []
        for root in roots {
            flattenNode(root, into: &result)
        }
        flattenedNodes = result
    }

    private func flattenNode(_ node: TreeNode, into list: inout [TreeNode]) {
        guard node.depth <= config.maxDepth else { return }
        list.append(node)
        if node.isExpanded {
            for child in node.children {
                flattenNode(child, into: &list)
            }
        }
    }

    private func rebuildNodeMap() {
        allNodesMap.removeAll()
        for root in roots {
            mapNode(root)
        }
    }

    private func mapNode(_ node: TreeNode) {
        allNodesMap[node.id] = node
        for child in node.children {
            mapNode(child)
        }
    }

    // MARK: - Node Operations

    func findNode(id: String) -> TreeNode? {
        allNodesMap[id]
    }

    func findParent(of node: TreeNode) -> TreeNode? {
        guard let parentID = node.parentID else { return nil }
        return allNodesMap[parentID]
    }

    func pathToNode(_ node: TreeNode) -> [TreeNode] {
        var path: [TreeNode] = [node]
        var current = node
        while let parent = findParent(of: current) {
            path.insert(parent, at: 0)
            current = parent
        }
        return path
    }

    // MARK: - Expand / Collapse

    func toggleExpand(_ node: TreeNode) {
        if node.isLeaf && !node.hasAsyncChildren { return }

        if !node.isExpanded && node.hasAsyncChildren && node.children.isEmpty {
            loadChildrenAsync(for: node)
            return
        }

        withAnimation(.easeInOut(duration: config.animationDuration)) {
            node.isExpanded.toggle()
            objectWillChange.send()
            rebuildFlatList()
        }
    }

    func expandAll() {
        setExpandState(true, for: roots)
        objectWillChange.send()
        rebuildFlatList()
    }

    func collapseAll() {
        setExpandState(false, for: roots)
        objectWillChange.send()
        rebuildFlatList()
    }

    func expandToLevel(_ level: Int) {
        expandToDepth(level, nodes: roots)
        objectWillChange.send()
        rebuildFlatList()
    }

    func expandPath(to node: TreeNode) {
        let path = pathToNode(node)
        for pathNode in path {
            if !pathNode.isLeaf {
                pathNode.isExpanded = true
            }
        }
        objectWillChange.send()
        rebuildFlatList()
    }

    func scrollToNode(_ node: TreeNode) {
        expandPath(to: node)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollTargetNodeID = node.id
        }
    }

    private func setExpandState(_ expanded: Bool, for nodes: [TreeNode]) {
        for node in nodes {
            if !node.isLeaf {
                node.isExpanded = expanded
            }
            setExpandState(expanded, for: node.children)
        }
    }

    private func expandToDepth(_ depth: Int, nodes: [TreeNode]) {
        for node in nodes {
            if node.depth < depth && !node.isLeaf {
                node.isExpanded = true
            } else {
                node.isExpanded = false
            }
            expandToDepth(depth, nodes: node.children)
        }
    }

    // MARK: - Selection

    func toggleSelection(_ node: TreeNode) {
        node.isSelected.toggle()
        objectWillChange.send()
    }

    func selectAll() {
        for root in roots {
            setSelectionState(true, for: root)
        }
        objectWillChange.send()
    }

    func deselectAll() {
        for root in roots {
            setSelectionState(false, for: root)
        }
        objectWillChange.send()
    }

    func getSelectedNodes() -> [TreeNode] {
        var selected: [TreeNode] = []
        for root in roots {
            collectSelected(root, into: &selected)
        }
        return selected
    }

    private func setSelectionState(_ selected: Bool, for node: TreeNode) {
        node.isSelected = selected
        for child in node.children {
            setSelectionState(selected, for: child)
        }
    }

    private func collectSelected(_ node: TreeNode, into list: inout [TreeNode]) {
        if node.isSelected { list.append(node) }
        for child in node.children {
            collectSelected(child, into: &list)
        }
    }

    // MARK: - Add / Remove

    func addNode(_ node: TreeNode, to parent: TreeNode? = nil) {
        if let parent = parent {
            parent.addChild(node)
        } else {
            node.depth = 0
            roots.append(node)
        }
        allNodesMap[node.id] = node
        objectWillChange.send()
        rebuildFlatList()
    }

    func removeNode(_ node: TreeNode) {
        if let parent = findParent(of: node) {
            parent.removeChild(id: node.id)
        } else {
            roots.removeAll { $0.id == node.id }
        }
        allNodesMap.removeValue(forKey: node.id)
        for descendant in node.allDescendants() {
            allNodesMap.removeValue(forKey: descendant.id)
        }
        objectWillChange.send()
        rebuildFlatList()
    }

    func moveNode(_ source: TreeNode, to target: TreeNode) {
        guard source.id != target.id else { return }
        // Prevent moving to own descendant
        let targetPath = pathToNode(target)
        if targetPath.contains(source) { return }

        removeNode(source)
        target.addChild(source)
        allNodesMap[source.id] = source
        for descendant in source.allDescendants() {
            allNodesMap[descendant.id] = descendant
        }
        objectWillChange.send()
        rebuildFlatList()
    }

    // MARK: - Async Loading

    func loadChildrenAsync(for node: TreeNode) {
        guard let loader = asyncChildLoader else { return }
        node.isLoading = true
        objectWillChange.send()

        Task { @MainActor in
            let children = await loader(node)
            node.isLoading = false
            node.hasAsyncChildren = false
            for child in children {
                child.parentID = node.id
                child.depth = node.depth + 1
                allNodesMap[child.id] = child
            }
            node.children = children
            node.isExpanded = true
            objectWillChange.send()
            rebuildFlatList()
        }
    }

    // MARK: - Search

    func search(_ text: String) {
        searchText = text
        if text.isEmpty {
            searchResults = []
            clearHighlights()
            scrollTargetNodeID = nil
            return
        }

        var results: [TreeNode] = []
        for root in roots {
            searchInNode(root, query: text, results: &results)
        }
        searchResults = results

        clearHighlights()
        for node in results {
            node.isHighlighted = true
            expandPath(to: node)
        }
        objectWillChange.send()
        rebuildFlatList()

        if let firstResult = results.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.scrollTargetNodeID = firstResult.id
            }
        }
    }

    private func searchInNode(_ node: TreeNode, query: String, results: inout [TreeNode]) {
        if node.title.localizedCaseInsensitiveContains(query) {
            results.append(node)
        }
        for child in node.children {
            searchInNode(child, query: query, results: &results)
        }
    }

    private func clearHighlights() {
        for root in roots {
            clearHighlight(root)
        }
    }

    private func clearHighlight(_ node: TreeNode) {
        node.isHighlighted = false
        for child in node.children {
            clearHighlight(child)
        }
    }

    // MARK: - Sample Data

    static func sampleData() -> [TreeNode] {
        let root1 = TreeNode(id: "1", title: "项目文件", icon: "folder.fill", children: [
            TreeNode(id: "1-1", title: "Sources", icon: "folder", children: [
                TreeNode(id: "1-1-1", title: "App", icon: "folder", children: [
                    TreeNode(id: "1-1-1-1", title: "AppDelegate.swift", icon: "swift"),
                    TreeNode(id: "1-1-1-2", title: "SceneDelegate.swift", icon: "swift"),
                ]),
                TreeNode(id: "1-1-2", title: "Views", icon: "folder", children: [
                    TreeNode(id: "1-1-2-1", title: "ContentView.swift", icon: "swift"),
                    TreeNode(id: "1-1-2-2", title: "DetailView.swift", icon: "swift"),
                    TreeNode(id: "1-1-2-3", title: "SettingsView.swift", icon: "swift"),
                ]),
                TreeNode(id: "1-1-3", title: "Models", icon: "folder", children: [
                    TreeNode(id: "1-1-3-1", title: "User.swift", icon: "swift"),
                    TreeNode(id: "1-1-3-2", title: "Post.swift", icon: "swift"),
                ]),
                TreeNode(id: "1-1-4", title: "Network", icon: "folder", children: [
                    TreeNode(id: "1-1-4-1", title: "APIClient.swift", icon: "swift"),
                    TreeNode(id: "1-1-4-2", title: "Endpoints.swift", icon: "swift"),
                ]),
            ]),
            TreeNode(id: "1-2", title: "Resources", icon: "folder", children: [
                TreeNode(id: "1-2-1", title: "Assets.xcassets", icon: "photo"),
                TreeNode(id: "1-2-2", title: "LaunchScreen.storyboard", icon: "rectangle.split.3x3"),
                TreeNode(id: "1-2-3", title: "Info.plist", icon: "doc.text"),
            ]),
            TreeNode(id: "1-3", title: "Tests", icon: "folder", children: [
                TreeNode(id: "1-3-1", title: "UnitTests", icon: "folder", children: [
                    TreeNode(id: "1-3-1-1", title: "UserTests.swift", icon: "swift"),
                    TreeNode(id: "1-3-1-2", title: "PostTests.swift", icon: "swift"),
                ]),
                TreeNode(id: "1-3-2", title: "UITests", icon: "folder", children: [
                    TreeNode(id: "1-3-2-1", title: "LoginUITests.swift", icon: "swift"),
                ]),
            ]),
        ])

        let root2 = TreeNode(id: "2", title: "依赖库", icon: "shippingbox", children: [
            TreeNode(id: "2-1", title: "Alamofire", icon: "network"),
            TreeNode(id: "2-2", title: "SnapKit", icon: "ruler"),
            TreeNode(id: "2-3", title: "Kingfisher", icon: "photo.artframe"),
        ])

        let root3 = TreeNode(id: "3", title: "异步加载节点", icon: "arrow.down.circle", hasAsyncChildren: true)

        return [root1, root2, root3]
    }
}
