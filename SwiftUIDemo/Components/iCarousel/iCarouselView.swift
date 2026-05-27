import SwiftUI

struct iCarouselView: View {
    @ObservedObject var manager: iCarouselManager
    var itemBuilder: ((iCarouselItem, Int) -> AnyView)?

    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2

            ZStack {
                ForEach(sortedVisibleItems(), id: \.index) { entry in
                    let transform = manager.transformForItem(at: entry.offset)

                    itemView(for: entry.item, index: entry.index)
                        .frame(width: manager.config.itemSize.width,
                               height: manager.config.itemSize.height)
                        .scaleEffect(transform.scale)
                        .rotation3DEffect(
                            .degrees(transform.rotation3D.angle),
                            axis: transform.rotation3D.axis,
                            perspective: transform.perspective
                        )
                        .offset(transform.offset)
                        .opacity(transform.opacity)
                        .zIndex(transform.zIndex)
                        .onTapGesture {
                            manager.delegate?.carouselDidSelectItem(at: entry.index)
                            if entry.index != manager.currentIndex {
                                manager.scrollToIndex(entry.index)
                            }
                        }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .gesture(dragGesture)
        }
        .frame(height: manager.config.itemSize.height + 40)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                if !manager.isDragging {
                    manager.onDragBegan()
                }
                let translation: CGFloat
                if manager.config.carouselType == .timeMachine {
                    translation = value.translation.height
                } else {
                    translation = value.translation.width
                }
                manager.onDragChanged(translation: translation)
            }
            .onEnded { value in
                let predicted: CGFloat
                if manager.config.carouselType == .timeMachine {
                    predicted = value.predictedEndTranslation.height
                } else {
                    predicted = value.predictedEndTranslation.width
                }
                manager.onDragEnded(predictedTranslation: predicted)
            }
    }

    private func itemView(for item: iCarouselItem, index: Int) -> some View {
        Group {
            if let builder = itemBuilder {
                builder(item, index)
            } else {
                DefaultCarouselItemView(item: item)
            }
        }
    }

    private struct VisibleEntry: Identifiable {
        let index: Int
        let offset: CGFloat
        let item: iCarouselItem
        var id: String { item.id }
    }

    private func sortedVisibleItems() -> [VisibleEntry] {
        guard !manager.items.isEmpty else { return [] }
        let center = Int(round(manager.currentOffset))
        let half = manager.config.visibleItems / 2
        var entries: [VisibleEntry] = []

        for i in (center - half)...(center + half) {
            let wrappedIdx: Int
            if manager.config.isInfinite {
                wrappedIdx = manager.wrappedIndex(i)
            } else {
                if i < 0 || i >= manager.items.count { continue }
                wrappedIdx = i
            }

            let offset = manager.itemOffset(for: wrappedIdx, from: center)
            let item = manager.items[wrappedIdx]
            entries.append(VisibleEntry(index: wrappedIdx, offset: offset, item: item))
        }

        let visibleSet = Set(entries.map { $0.index })
        DispatchQueue.main.async {
            self.manager.updateVisibleSet(currentVisible: visibleSet)
        }

        return entries.sorted { abs($0.offset) > abs($1.offset) }
    }
}

// MARK: - Default Item View

struct DefaultCarouselItemView: View {
    let item: iCarouselItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(item.color.gradient)

            VStack(spacing: 12) {
                Image(systemName: item.imageName)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)

                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

// MARK: - Async Image Carousel Item

struct AsyncImageCarouselItemView: View {
    let item: iCarouselItem
    @State private var loadedImage: UIImage?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(item.color.gradient)

            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .transition(.opacity)
            } else if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: item.imageName)
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let urlString = item.imageURL,
              let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                withAnimation(.easeIn(duration: 0.3)) {
                    loadedImage = uiImage
                }
            }
        } catch {}
        isLoading = false
    }
}
