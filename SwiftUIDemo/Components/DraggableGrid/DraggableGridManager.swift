import SwiftUI
import Combine
import UIKit

final class DraggableGridManager: ObservableObject {
    // MARK: - Configuration
    let config: DraggableGridConfig

    // MARK: - Grid State
    @Published var items: [DraggableGridItem] = []
    @Published var availableItems: [DraggableGridItem] = []
    @Published var isEditMode: Bool = false

    // MARK: - Drag State
    @Published var draggedItem: DraggableGridItem? = nil
    @Published var draggedFromSource: DraggableGridItem? = nil
    @Published var dragPosition: CGPoint = .zero
    @Published var isDragging: Bool = false
    @Published var isOverTrash: Bool = false
    @Published var dragStartPosition: CGPoint = .zero

    // MARK: - Init

    init(config: DraggableGridConfig = DraggableGridConfig()) {
        self.config = config
    }

    private func triggerHaptic(intensity: CGFloat = 1.0) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        switch config.hapticStyle {
        case .light: style = .light
        case .medium: style = .medium
        case .heavy: style = .heavy
        }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred(intensity: intensity)
    }

    // MARK: - Persistence

    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: config.persistenceKey),
           let decoded = try? JSONDecoder().decode([DraggableGridItem].self, from: data) {
            items = decoded
        } else {
            items = DraggableGridItem.defaultItems
            saveItems()
        }

        if let data = UserDefaults.standard.data(forKey: config.availableItemsKey),
           let decoded = try? JSONDecoder().decode([DraggableGridItem].self, from: data) {
            availableItems = decoded
        } else {
            availableItems = DraggableGridItem.extraItems
            saveAvailableItems()
        }
    }

    func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: config.persistenceKey)
        }
    }

    func saveAvailableItems() {
        if let data = try? JSONEncoder().encode(availableItems) {
            UserDefaults.standard.set(data, forKey: config.availableItemsKey)
        }
    }

    // MARK: - Edit Mode

    func enterEditMode() {
        guard !isEditMode else { return }
        isEditMode = true
        triggerHaptic()
    }

    func exitEditMode() {
        isEditMode = false
        cancelDrag()
    }

    // MARK: - Drag Operations

    func startDrag(item: DraggableGridItem, position: CGPoint) {
        draggedItem = item
        draggedFromSource = nil
        dragPosition = position
        dragStartPosition = position
        isDragging = true
        triggerHaptic(intensity: 0.6)
    }

    func startDragFromSource(item: DraggableGridItem, position: CGPoint) {
        draggedFromSource = item
        draggedItem = nil
        dragPosition = position
        dragStartPosition = position
        isDragging = true
        triggerHaptic(intensity: 0.6)
    }

    func updateDrag(position: CGPoint, containerHeight: CGFloat, gridFrame: CGRect) {
        dragPosition = position

        let trashThreshold = containerHeight - config.trashZoneHeight - config.addZoneHeight
        let wasOverTrash = isOverTrash
        isOverTrash = draggedItem != nil && position.y > trashThreshold

        if isOverTrash && !wasOverTrash {
            triggerHaptic(intensity: 0.4)
        }

        if let draggedItem = draggedItem, !isOverTrash {
            let targetIdx = targetIndex(for: position, in: gridFrame)
            if let target = targetIdx,
               let currentIdx = items.firstIndex(where: { $0.id == draggedItem.id }),
               target != currentIdx {
                withAnimation(.easeInOut(duration: 0.2)) {
                    items.move(fromOffsets: IndexSet(integer: currentIdx), toOffset: target > currentIdx ? target + 1 : target)
                }
                triggerHaptic(intensity: 0.3)
            }
        }
    }

    func endDrag() {
        defer {
            cancelDrag()
            saveItems()
            saveAvailableItems()
        }

        if let item = draggedItem, isOverTrash {
            withAnimation(.easeInOut(duration: 0.3)) {
                deleteItem(item)
            }
            triggerHaptic(intensity: 0.8)
            return
        }

        if let sourceItem = draggedFromSource {
            if !isOverTrash {
                withAnimation(.easeInOut(duration: 0.3)) {
                    addItemFromSource(sourceItem)
                }
                triggerHaptic(intensity: 0.6)
            }
        }
    }

    func cancelDrag() {
        draggedItem = nil
        draggedFromSource = nil
        isDragging = false
        isOverTrash = false
        dragPosition = .zero
    }

    // MARK: - Reordering

    func targetIndex(for position: CGPoint, in gridFrame: CGRect) -> Int? {
        guard !items.isEmpty else { return nil }

        let totalWidth = gridFrame.width
        let cols = CGFloat(config.columns)
        let columnWidth = (totalWidth - (cols - 1) * config.spacing) / cols

        let relativeX = position.x - gridFrame.minX
        let relativeY = position.y - gridFrame.minY

        guard relativeX >= 0, relativeY >= 0 else { return nil }

        let col = min(Int(relativeX / (columnWidth + config.spacing)), config.columns - 1)
        let row = Int(relativeY / (config.itemSize + config.spacing))

        let index = row * config.columns + col
        guard index >= 0, index < items.count else { return nil }
        return index
    }

    // MARK: - Delete & Add

    func deleteItem(_ item: DraggableGridItem) {
        items.removeAll { $0.id == item.id }
        availableItems.append(item)
    }

    func addItemFromSource(_ item: DraggableGridItem) {
        availableItems.removeAll { $0.id == item.id }
        items.append(item)
    }
}
