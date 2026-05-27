import SwiftUI

// MARK: - Row Count Preference Key

struct RowCountPreferenceKey: PreferenceKey {
    static var defaultValue: RowCountData = RowCountData(totalRows: 0, visibleCount: 0, totalCount: 0)
    static func reduce(value: inout RowCountData, nextValue: () -> RowCountData) {
        value = nextValue()
    }
}

struct RowCountData: Equatable {
    var totalRows: Int
    var visibleCount: Int
    var totalCount: Int

    var hiddenCount: Int { totalCount - visibleCount }
    var hasOverflow: Bool { totalRows > 0 && visibleCount < totalCount }
}

// MARK: - Collapsible Flow Layout

struct CollapsibleFlowLayout: Layout {
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat
    var maxLines: Int
    var isExpanded: Bool

    struct CacheData {
        var size: CGSize
        var frames: [CGRect]
        var totalRowCount: Int
        var visibleCount: Int
        var totalCount: Int
    }

    func makeCache(subviews: Subviews) -> CacheData {
        CacheData(size: .zero, frames: [], totalRowCount: 0, visibleCount: 0, totalCount: 0)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) -> CGSize {
        cache = computeLayout(proposal: proposal, subviews: subviews)
        return cache.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) {
        for (index, subview) in subviews.enumerated() {
            if index < cache.frames.count {
                let frame = cache.frames[index]
                subview.place(
                    at: CGPoint(x: bounds.minX + frame.origin.x, y: bounds.minY + frame.origin.y),
                    proposal: ProposedViewSize(frame.size)
                )
            } else {
                subview.place(at: CGPoint(x: bounds.minX, y: bounds.minY), proposal: .zero)
            }
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> CacheData {
        let maxWidth = proposal.width ?? .infinity
        guard !subviews.isEmpty else {
            return CacheData(size: .zero, frames: [], totalRowCount: 0, visibleCount: 0, totalCount: 0)
        }

        var allFrames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalRowCount = 1

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
                totalRowCount += 1
            }
            allFrames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + horizontalSpacing
        }

        if isExpanded {
            let totalHeight = y + rowHeight
            return CacheData(
                size: CGSize(width: maxWidth, height: totalHeight),
                frames: allFrames,
                totalRowCount: totalRowCount,
                visibleCount: subviews.count,
                totalCount: subviews.count
            )
        }

        var visibleFrames: [CGRect] = []
        x = 0
        y = 0
        rowHeight = 0
        var currentRow = 1

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
                currentRow += 1
            }
            if currentRow > maxLines {
                break
            }
            visibleFrames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + horizontalSpacing
        }

        let collapsedHeight = y + rowHeight
        return CacheData(
            size: CGSize(width: maxWidth, height: collapsedHeight),
            frames: visibleFrames,
            totalRowCount: totalRowCount,
            visibleCount: visibleFrames.count,
            totalCount: subviews.count
        )
    }
}

// MARK: - Tag Chip View

struct TagChipView: View {
    let tag: TagItem
    let isSelected: Bool
    let style: TagStyleConfig
    let allowsDeletion: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.title)
                .font(style.font)

            if allowsDeletion {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(isSelected ? style.selectedForeground.opacity(0.7) : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
        .background(isSelected ? style.selectedBackground : style.unselectedBackground)
        .foregroundStyle(isSelected ? style.selectedForeground : style.unselectedForeground)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(isSelected ? style.selectedBorderColor : style.unselectedBorderColor, lineWidth: style.borderWidth)
        )
        .contentShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        .onTapGesture(perform: onTap)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Layout Reporter

struct LayoutReporterModifier: ViewModifier {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let maxLines: Int
    let isExpanded: Bool

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: RowCountPreferenceKey.self, value: readRowCount(width: geo.size.width))
                }
            )
    }

    private func readRowCount(width: CGFloat) -> RowCountData {
        RowCountData(totalRows: 0, visibleCount: 0, totalCount: 0)
    }
}

// MARK: - Tag Selector View

struct TagSelectorView: View {
    @ObservedObject var manager: TagSelectorManager
    @State private var rowCountData: RowCountData = RowCountData(totalRows: 0, visibleCount: 0, totalCount: 0)

    private var showExpandButton: Bool {
        manager.config.showsExpandCollapse && rowCountData.totalRows > manager.config.collapsedMaxLines
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if manager.config.allowsAddition {
                searchBar
            }

            tagContent

            if showExpandButton {
                expandCollapseButton
            }

            selectionInfo
        }
        .alert("选择数量已达上限", isPresented: $manager.showMaxAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            if let max = manager.config.selectionMode.maxCount {
                Text("最多只能选择 \(max) 个标签")
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(manager.config.searchPlaceholder, text: $manager.searchText)
                .textFieldStyle(.plain)
                .submitLabel(.done)
                .onSubmit {
                    if manager.canAddSearchTextAsTag {
                        manager.addTag()
                    }
                }
            if !manager.searchText.isEmpty {
                Button {
                    manager.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            if manager.canAddSearchTextAsTag {
                Button {
                    manager.addTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Tag Content

    private var tagContent: some View {
        CollapsibleFlowLayout(
            horizontalSpacing: manager.config.horizontalSpacing,
            verticalSpacing: manager.config.verticalSpacing,
            maxLines: manager.config.collapsedMaxLines,
            isExpanded: manager.isExpanded
        ) {
            ForEach(manager.filteredTags) { tag in
                TagChipView(
                    tag: tag,
                    isSelected: manager.isSelected(tag),
                    style: manager.config.style,
                    allowsDeletion: manager.config.allowsDeletion,
                    onTap: { manager.toggleSelection(tag) },
                    onDelete: { manager.deleteTag(tag) }
                )
            }
        }
        .clipped()
        .animation(.easeInOut(duration: 0.3), value: manager.isExpanded)
        .animation(.easeInOut(duration: 0.3), value: manager.filteredTags.map(\.id))
        .background(rowCountReader)
        .onChange(of: manager.filteredTags.count) {
            if !rowCountData.hasOverflow && manager.isExpanded {
                manager.isExpanded = false
            }
        }
    }

    private var rowCountReader: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { updateRowCount(width: geo.size.width) }
                .onChange(of: manager.filteredTags.count) { updateRowCount(width: geo.size.width) }
                .onChange(of: geo.size.width) { updateRowCount(width: geo.size.width) }
        }
    }

    private func updateRowCount(width: CGFloat) {
        let tags = manager.filteredTags
        guard !tags.isEmpty, width > 0 else {
            rowCountData = RowCountData(totalRows: 0, visibleCount: 0, totalCount: 0)
            return
        }

        let hPad = manager.config.style.horizontalPadding * 2
        let spacing = manager.config.horizontalSpacing
        let font = UIFont.preferredFont(forTextStyle: .subheadline)
        let deleteButtonWidth: CGFloat = manager.config.allowsDeletion ? 20 : 0
        let maxLines = manager.config.collapsedMaxLines

        var x: CGFloat = 0
        var totalRows = 1
        var visibleCount = tags.count

        for (index, tag) in tags.enumerated() {
            let textSize = (tag.title as NSString).size(withAttributes: [.font: font])
            let chipWidth = ceil(textSize.width) + hPad + deleteButtonWidth + (manager.config.allowsDeletion ? 4 : 0)

            if x + chipWidth > width, x > 0 {
                x = 0
                totalRows += 1
            }

            if visibleCount == tags.count && totalRows > maxLines {
                visibleCount = index
            }

            x += chipWidth + spacing
        }

        rowCountData = RowCountData(totalRows: totalRows, visibleCount: visibleCount, totalCount: tags.count)
    }

    // MARK: - Expand/Collapse Button

    private var expandCollapseButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                manager.isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                if manager.isExpanded {
                    Text("收起")
                        .font(.caption)
                    Image(systemName: "chevron.up")
                        .font(.caption2)
                } else {
                    let hidden = rowCountData.hiddenCount
                    Text("展开更多")
                        .font(.caption)
                    if hidden > 0 {
                        Text("+\(hidden)")
                            .font(.caption)
                    }
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
            }
            .foregroundStyle(.blue)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .transition(.opacity)
    }

    // MARK: - Selection Info

    private var selectionInfo: some View {
        Group {
            if !manager.selectedTags.isEmpty {
                HStack {
                    Text("已选: \(manager.selectedTags.map(\.title).joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Text("\(manager.selectedIDs.count)个")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}
