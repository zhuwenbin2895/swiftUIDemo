import SwiftUI

// MARK: - Item Model

struct DraggableGridItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var iconName: String
    var colorHex: String

    nonisolated var color: Color { Color(hex: colorHex) }

    nonisolated init(id: UUID = UUID(), title: String, iconName: String, colorHex: String) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.colorHex = colorHex
    }

    enum CodingKeys: String, CodingKey {
        case id, title, iconName, colorHex
    }
}

// MARK: - Haptic Style

enum DraggableGridHapticStyle: Sendable {
    case light, medium, heavy
}

// MARK: - Configuration

struct DraggableGridConfig: Sendable {
    var columns: Int = 3
    var spacing: CGFloat = 16
    var itemCornerRadius: CGFloat = 16
    var itemSize: CGFloat = 90
    var wobbleAngle: Double = 2.5
    var wobbleDuration: Double = 0.12
    var dragScaleFactor: CGFloat = 1.1
    var neighborShrinkFactor: CGFloat = 0.95
    var neighborBlurRadius: CGFloat = 1.0
    var trashZoneHeight: CGFloat = 80
    var addZoneHeight: CGFloat = 100
    var longPressDuration: CGFloat = 0.5
    var hapticStyle: DraggableGridHapticStyle = .medium
    var persistenceKey: String = "draggable_grid_items"
    var availableItemsKey: String = "draggable_grid_available_items"

    nonisolated init(
        columns: Int = 3,
        spacing: CGFloat = 16,
        itemCornerRadius: CGFloat = 16,
        itemSize: CGFloat = 90,
        wobbleAngle: Double = 2.5,
        wobbleDuration: Double = 0.12,
        dragScaleFactor: CGFloat = 1.1,
        neighborShrinkFactor: CGFloat = 0.95,
        neighborBlurRadius: CGFloat = 1.0,
        trashZoneHeight: CGFloat = 80,
        addZoneHeight: CGFloat = 100,
        longPressDuration: CGFloat = 0.5,
        hapticStyle: DraggableGridHapticStyle = .medium,
        persistenceKey: String = "draggable_grid_items",
        availableItemsKey: String = "draggable_grid_available_items"
    ) {
        self.columns = columns
        self.spacing = spacing
        self.itemCornerRadius = itemCornerRadius
        self.itemSize = itemSize
        self.wobbleAngle = wobbleAngle
        self.wobbleDuration = wobbleDuration
        self.dragScaleFactor = dragScaleFactor
        self.neighborShrinkFactor = neighborShrinkFactor
        self.neighborBlurRadius = neighborBlurRadius
        self.trashZoneHeight = trashZoneHeight
        self.addZoneHeight = addZoneHeight
        self.longPressDuration = longPressDuration
        self.hapticStyle = hapticStyle
        self.persistenceKey = persistenceKey
        self.availableItemsKey = availableItemsKey
    }
}

// MARK: - Default Data

extension DraggableGridItem {
    nonisolated static let defaultItems: [DraggableGridItem] = [
        DraggableGridItem(title: "天气", iconName: "cloud.sun.fill", colorHex: "007AFF"),
        DraggableGridItem(title: "相机", iconName: "camera.fill", colorHex: "FF9500"),
        DraggableGridItem(title: "照片", iconName: "photo.fill", colorHex: "FF2D55"),
        DraggableGridItem(title: "音乐", iconName: "music.note", colorHex: "AF52DE"),
        DraggableGridItem(title: "地图", iconName: "map.fill", colorHex: "34C759"),
        DraggableGridItem(title: "邮件", iconName: "envelope.fill", colorHex: "5856D6"),
        DraggableGridItem(title: "日历", iconName: "calendar", colorHex: "FF3B30"),
        DraggableGridItem(title: "备忘录", iconName: "note.text", colorHex: "FFCC00"),
        DraggableGridItem(title: "设置", iconName: "gearshape.fill", colorHex: "8E8E93"),
    ]

    nonisolated static let extraItems: [DraggableGridItem] = [
        DraggableGridItem(title: "时钟", iconName: "clock.fill", colorHex: "FF9500"),
        DraggableGridItem(title: "计算器", iconName: "plus.forwardslash.minus", colorHex: "636366"),
        DraggableGridItem(title: "指南针", iconName: "location.north.fill", colorHex: "007AFF"),
        DraggableGridItem(title: "健康", iconName: "heart.fill", colorHex: "FF2D55"),
    ]
}

// MARK: - Color+Hex

extension Color {
    nonisolated init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
