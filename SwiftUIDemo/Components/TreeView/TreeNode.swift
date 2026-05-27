import SwiftUI
import Combine

// MARK: - TreeNode Model

class TreeNode: ObservableObject, Identifiable, Codable {
    let id: String
    @Published var title: String
    @Published var icon: String?
    @Published var children: [TreeNode]
    @Published var isExpanded: Bool
    @Published var isSelected: Bool
    @Published var isHighlighted: Bool
    @Published var isLoading: Bool

    var parentID: String?
    var depth: Int
    var hasAsyncChildren: Bool

    var isLeaf: Bool { children.isEmpty && !hasAsyncChildren }

    init(
        id: String = UUID().uuidString,
        title: String,
        icon: String? = nil,
        children: [TreeNode] = [],
        parentID: String? = nil,
        depth: Int = 0,
        isExpanded: Bool = false,
        isSelected: Bool = false,
        hasAsyncChildren: Bool = false
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.children = children
        self.parentID = parentID
        self.depth = depth
        self.isExpanded = isExpanded
        self.isSelected = isSelected
        self.isHighlighted = false
        self.isLoading = false
        self.hasAsyncChildren = hasAsyncChildren

        for child in children {
            child.parentID = id
            child.depth = depth + 1
        }
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, title, icon, children, parentID, depth, isExpanded, isSelected, hasAsyncChildren
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        children = try container.decodeIfPresent([TreeNode].self, forKey: .children) ?? []
        parentID = try container.decodeIfPresent(String.self, forKey: .parentID)
        depth = try container.decodeIfPresent(Int.self, forKey: .depth) ?? 0
        isExpanded = try container.decodeIfPresent(Bool.self, forKey: .isExpanded) ?? false
        isSelected = try container.decodeIfPresent(Bool.self, forKey: .isSelected) ?? false
        hasAsyncChildren = try container.decodeIfPresent(Bool.self, forKey: .hasAsyncChildren) ?? false
        isHighlighted = false
        isLoading = false

        for child in children {
            child.parentID = id
            child.depth = depth + 1
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encode(children, forKey: .children)
        try container.encodeIfPresent(parentID, forKey: .parentID)
        try container.encode(depth, forKey: .depth)
        try container.encode(isExpanded, forKey: .isExpanded)
        try container.encode(isSelected, forKey: .isSelected)
        try container.encode(hasAsyncChildren, forKey: .hasAsyncChildren)
    }

    // MARK: - Operations

    func addChild(_ node: TreeNode) {
        node.parentID = id
        node.depth = depth + 1
        node.updateChildDepths()
        children.append(node)
    }

    func removeChild(id: String) {
        children.removeAll { $0.id == id }
    }

    func updateChildDepths() {
        for child in children {
            child.depth = depth + 1
            child.updateChildDepths()
        }
    }

    func allDescendants() -> [TreeNode] {
        var result: [TreeNode] = []
        for child in children {
            result.append(child)
            result.append(contentsOf: child.allDescendants())
        }
        return result
    }
}

extension TreeNode: Equatable {
    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        lhs.id == rhs.id
    }
}

extension TreeNode: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
