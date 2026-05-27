import SwiftUI
import Combine

@MainActor
class TagSelectorManager: ObservableObject {
    @Published var tags: [TagItem]
    @Published var selectedIDs: Set<UUID> = []
    @Published var searchText: String = ""
    @Published var isExpanded: Bool = false
    @Published var showMaxAlert: Bool = false

    let config: TagSelectorConfig
    var onSelectionChanged: (([TagItem]) -> Void)?

    init(tags: [TagItem], config: TagSelectorConfig) {
        self.tags = tags
        self.config = config
    }

    var selectedTags: [TagItem] {
        tags.filter { selectedIDs.contains($0.id) }
    }

    var filteredTags: [TagItem] {
        if searchText.isEmpty { return tags }
        return tags.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var canAddSearchTextAsTag: Bool {
        guard config.allowsAddition, !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        return !tags.contains { $0.title.lowercased() == searchText.lowercased() }
    }

    func toggleSelection(_ tag: TagItem) {
        if config.selectionMode.isSingle {
            if selectedIDs.contains(tag.id) {
                selectedIDs.removeAll()
            } else {
                selectedIDs = [tag.id]
            }
        } else {
            if selectedIDs.contains(tag.id) {
                selectedIDs.remove(tag.id)
            } else {
                if let max = config.selectionMode.maxCount, selectedIDs.count >= max {
                    showMaxAlert = true
                    return
                }
                selectedIDs.insert(tag.id)
            }
        }
        onSelectionChanged?(selectedTags)
    }

    func addTag() {
        let title = searchText.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty, canAddSearchTextAsTag else { return }
        let newTag = TagItem(title: title)
        tags.append(newTag)
        searchText = ""
    }

    func deleteTag(_ tag: TagItem) {
        tags.removeAll { $0.id == tag.id }
        selectedIDs.remove(tag.id)
        onSelectionChanged?(selectedTags)
    }

    func resetExpandIfNeeded() {
        if filteredTags.count <= config.collapsedMaxLines * 4 {
            isExpanded = false
        }
    }

    func isSelected(_ tag: TagItem) -> Bool {
        selectedIDs.contains(tag.id)
    }
}
