import SwiftUI
import Combine

// MARK: - Main Grid View

struct DraggableGridView: View {
    @ObservedObject var manager: DraggableGridManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var gridFrame: CGRect = .zero
    @State private var containerSize: CGSize = .zero
    @State private var wobblePhase: Bool = false

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: manager.config.spacing), count: manager.config.columns)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: manager.config.spacing) {
                            ForEach(manager.items) { item in
                                gridItemView(item: item)
                            }
                        }
                        .padding(manager.config.spacing)
                        .background(
                            GeometryReader { gridGeo in
                                Color.clear.preference(
                                    key: GridFramePreferenceKey.self,
                                    value: gridGeo.frame(in: .named("gridContainer"))
                                )
                            }
                        )
                    }
                    .scrollDisabled(manager.isDragging)

                    if manager.isEditMode {
                        Divider()
                        trashZoneView
                        addSourceZoneView
                    }
                }

                if manager.isDragging, let item = manager.draggedItem ?? manager.draggedFromSource {
                    dragOverlayView(item: item)
                }
            }
            .background(Color(.systemGroupedBackground))
            .coordinateSpace(name: "gridContainer")
            .onPreferenceChange(GridFramePreferenceKey.self) { frame in
                gridFrame = frame
            }
            .onAppear {
                containerSize = geometry.size
            }
            .onChange(of: geometry.size) {
                containerSize = geometry.size
            }
        }
        .onChange(of: manager.isEditMode) {
            if manager.isEditMode {
                withAnimation(.easeInOut(duration: manager.config.wobbleDuration).repeatForever(autoreverses: true)) {
                    wobblePhase = true
                }
            } else {
                withAnimation(.default) {
                    wobblePhase = false
                }
            }
        }
    }

    // MARK: - Grid Item

    @ViewBuilder
    private func gridItemView(item: DraggableGridItem) -> some View {
        let isDraggedItem = manager.draggedItem?.id == item.id
        let config = manager.config

        GridItemContent(item: item, config: config)
            .opacity(isDraggedItem && manager.isDragging ? 0 : 1)
            .scaleEffect(
                manager.isDragging && !isDraggedItem ? config.neighborShrinkFactor : 1.0
            )
            .blur(radius: manager.isDragging && !isDraggedItem ? config.neighborBlurRadius : 0)
            .rotationEffect(
                manager.isEditMode && !isDraggedItem
                    ? .degrees(config.wobbleAngle * (wobblePhase ? 1 : -1))
                    : .degrees(0)
            )
            .animation(.easeInOut(duration: 0.2), value: manager.isDragging)
            .gesture(dragGesture(for: item))
    }

    // MARK: - Drag Gesture

    private func dragGesture(for item: DraggableGridItem) -> some Gesture {
        LongPressGesture(minimumDuration: manager.isEditMode ? 0.1 : manager.config.longPressDuration)
            .onEnded { _ in
                if !manager.isEditMode {
                    manager.enterEditMode()
                }
            }
            .sequenced(before: DragGesture(coordinateSpace: .named("gridContainer")))
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    guard let drag = drag else { return }
                    if !manager.isDragging {
                        manager.startDrag(item: item, position: drag.location)
                    }
                    manager.updateDrag(
                        position: drag.location,
                        containerHeight: containerSize.height,
                        gridFrame: gridFrame
                    )
                default:
                    break
                }
            }
            .onEnded { _ in
                manager.endDrag()
            }
    }

    // MARK: - Drag Overlay

    @ViewBuilder
    private func dragOverlayView(item: DraggableGridItem) -> some View {
        GridItemContent(item: item, config: manager.config)
            .scaleEffect(manager.config.dragScaleFactor)
            .shadow(
                color: colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.3),
                radius: colorScheme == .dark ? 12 : 10,
                x: 0,
                y: colorScheme == .dark ? 0 : 5
            )
            .position(manager.dragPosition)
            .allowsHitTesting(false)
    }

    // MARK: - Trash Zone

    private var trashZoneView: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: manager.isOverTrash ? "trash.fill" : "trash")
                    .font(.system(size: 24))
                Text("拖到此处删除")
                    .font(.caption)
            }
            .foregroundColor(manager.isOverTrash ? .white : .red)
            .scaleEffect(manager.isOverTrash ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: manager.isOverTrash)
            Spacer()
        }
        .frame(height: manager.config.trashZoneHeight)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    manager.isOverTrash
                        ? Color.red
                        : (colorScheme == .dark ? Color.red.opacity(0.2) : Color.red.opacity(0.08))
                )
                .padding(.horizontal, 16)
        )
        .animation(.easeInOut(duration: 0.2), value: manager.isOverTrash)
    }

    // MARK: - Add Source Zone

    private var addSourceZoneView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !manager.availableItems.isEmpty {
                Text("长按拖入添加")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(manager.availableItems) { item in
                            sourceItemView(item: item)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .frame(height: manager.config.addZoneHeight)
        .background(Color(.secondarySystemGroupedBackground))
    }

    @ViewBuilder
    private func sourceItemView(item: DraggableGridItem) -> some View {
        let isDraggedSource = manager.draggedFromSource?.id == item.id

        VStack(spacing: 4) {
            Image(systemName: item.iconName)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.color)
                        .shadow(
                            color: item.color.opacity(colorScheme == .dark ? 0.3 : 0.2),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                )
            Text(item.title)
                .font(.caption2)
                .foregroundColor(Color(.label))
        }
        .opacity(isDraggedSource && manager.isDragging ? 0.3 : 1)
        .gesture(sourceDragGesture(for: item))
    }

    private func sourceDragGesture(for item: DraggableGridItem) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(coordinateSpace: .named("gridContainer")))
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    guard let drag = drag else { return }
                    if !manager.isDragging {
                        manager.startDragFromSource(item: item, position: drag.location)
                    }
                    manager.dragPosition = drag.location
                default:
                    break
                }
            }
            .onEnded { _ in
                manager.endDrag()
            }
    }
}

// MARK: - Grid Item Content View

struct GridItemContent: View {
    let item: DraggableGridItem
    let config: DraggableGridConfig
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: item.iconName)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: config.itemSize - 20, height: config.itemSize - 40)
                .background(
                    RoundedRectangle(cornerRadius: config.itemCornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    item.color,
                                    colorScheme == .dark ? item.color.opacity(0.8) : item.color.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: item.color.opacity(colorScheme == .dark ? 0.4 : 0.3),
                            radius: colorScheme == .dark ? 4 : 3,
                            x: 0,
                            y: 2
                        )
                )
            Text(item.title)
                .font(.caption)
                .foregroundColor(Color(.label))
                .lineLimit(1)
        }
        .frame(width: config.itemSize, height: config.itemSize)
    }
}

// MARK: - Preference Key

struct GridFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
