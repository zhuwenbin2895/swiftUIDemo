import SwiftUI

// MARK: - Tag Model

struct TagItem: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

// MARK: - Selection Mode

enum TagSelectionMode {
    case single
    case multiple(maxCount: Int?)

    var isSingle: Bool {
        if case .single = self { return true }
        return false
    }

    var maxCount: Int? {
        if case .multiple(let max) = self { return max }
        return nil
    }
}

// MARK: - Tag Style

struct TagStyleConfig {
    var font: Font = .subheadline
    var cornerRadius: CGFloat = 16
    var horizontalPadding: CGFloat = 14
    var verticalPadding: CGFloat = 8
    var borderWidth: CGFloat = 1.5

    var selectedBackground: Color = .blue
    var selectedForeground: Color = .white
    var selectedBorderColor: Color = .blue

    var unselectedBackground: Color = Color(.systemGray6)
    var unselectedForeground: Color = .primary
    var unselectedBorderColor: Color = Color(.systemGray4)
}

// MARK: - Configuration

struct TagSelectorConfig {
    var selectionMode: TagSelectionMode = .multiple(maxCount: nil)
    var style: TagStyleConfig = TagStyleConfig()
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 10
    var collapsedMaxLines: Int = 2
    var allowsAddition: Bool = true
    var allowsDeletion: Bool = true
    var showsExpandCollapse: Bool = true
    var searchPlaceholder: String = "搜索或添加标签"
}

// MARK: - Default Data

extension TagItem {
    static let sampleTags: [TagItem] = [
        TagItem(title: "Swift"),
        TagItem(title: "SwiftUI"),
        TagItem(title: "UIKit"),
        TagItem(title: "Combine"),
        TagItem(title: "iOS"),
        TagItem(title: "macOS"),
        TagItem(title: "watchOS"),
        TagItem(title: "tvOS"),
        TagItem(title: "Xcode"),
        TagItem(title: "Core Data"),
        TagItem(title: "CloudKit"),
        TagItem(title: "ARKit"),
        TagItem(title: "Metal"),
        TagItem(title: "Vapor"),
        TagItem(title: "SPM"),
        TagItem(title: "CocoaPods"),
        TagItem(title: "测试"),
        TagItem(title: "性能优化"),
        TagItem(title: "动画"),
        TagItem(title: "网络"),
    ]
}
