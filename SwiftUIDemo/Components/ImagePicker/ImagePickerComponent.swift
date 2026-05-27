import SwiftUI
import UIKit
import PhotosUI
import Combine

// MARK: - Configuration

struct ImagePickerConfig {
    var maxSelectionCount: Int = 9
    var allowsOriginal: Bool = true
    var allowsCropping: Bool = true
    var allowsVideo: Bool = true
    var cropAspectRatio: CGFloat? = nil
    var videoMaxDuration: TimeInterval = 60
}

// MARK: - Media Item

struct MediaItem: Identifiable, Equatable {
    let id = UUID()
    var image: UIImage?
    var isVideo: Bool = false
    var duration: TimeInterval = 0

    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Image Picker Manager

@MainActor
class ImagePickerManager: ObservableObject {
    @Published var selectedItems: [MediaItem] = []
    @Published var isOriginal: Bool = false
    @Published var showPicker: Bool = false
    @Published var showCropper: Bool = false
    @Published var cropImage: UIImage?
    @Published var croppedImage: UIImage?
    @Published var config = ImagePickerConfig()

    func addItems(from results: [PhotosPickerItem]) {
        Task {
            for result in results {
                if let data = try? await result.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    let item = MediaItem(image: image, isVideo: false)
                    selectedItems.append(item)
                }
            }
        }
    }

    func removeItem(_ item: MediaItem) {
        selectedItems.removeAll { $0.id == item.id }
    }

    func clearAll() {
        selectedItems.removeAll()
    }

    func startCrop(_ image: UIImage) {
        cropImage = image
        showCropper = true
    }

    func finishCrop(_ result: UIImage) {
        croppedImage = result
        showCropper = false
    }
}

// MARK: - Image Crop View

struct ImageCropView: View {
    let image: UIImage
    let aspectRatio: CGFloat?
    let onCrop: (UIImage) -> Void
    let onCancel: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var cropRect: CGRect = .zero

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("取消") { onCancel() }
                Spacer()
                Text("裁剪图片")
                    .font(.headline)
                Spacer()
                Button("完成") { performCrop() }
                    .fontWeight(.semibold)
            }
            .padding()

            GeometryReader { geo in
                let size = geo.size
                ZStack {
                    Color.black

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in lastOffset = offset }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    scale = max(1.0, scale)
                                    lastScale = scale
                                }
                        )

                    CropOverlay(size: size, aspectRatio: aspectRatio)
                }
            }
        }
        .background(Color.black)
    }

    private func performCrop() {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        let cropped = renderer.image { ctx in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        onCrop(cropped)
    }
}

struct CropOverlay: View {
    let size: CGSize
    let aspectRatio: CGFloat?

    var body: some View {
        let cropSize: CGSize = {
            let ratio = aspectRatio ?? 1.0
            let w = min(size.width - 40, size.height - 40)
            return CGSize(width: w, height: w / ratio)
        }()

        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .mask(
                    HoleShape(cropSize: cropSize)
                        .fill(style: FillStyle(eoFill: true))
                )

            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.white, lineWidth: 1)
                .frame(width: cropSize.width, height: cropSize.height)

            GridLines()
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                .frame(width: cropSize.width, height: cropSize.height)
        }
    }
}

struct HoleShape: Shape {
    let cropSize: CGSize

    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        let holeRect = CGRect(
            x: rect.midX - cropSize.width / 2,
            y: rect.midY - cropSize.height / 2,
            width: cropSize.width,
            height: cropSize.height
        )
        path.addRect(holeRect)
        return path
    }
}

struct GridLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let thirdW = rect.width / 3
        let thirdH = rect.height / 3
        for i in 1...2 {
            path.move(to: CGPoint(x: thirdW * CGFloat(i), y: 0))
            path.addLine(to: CGPoint(x: thirdW * CGFloat(i), y: rect.height))
            path.move(to: CGPoint(x: 0, y: thirdH * CGFloat(i)))
            path.addLine(to: CGPoint(x: rect.width, y: thirdH * CGFloat(i)))
        }
        return path
    }
}

// MARK: - Selected Media Grid

struct SelectedMediaGrid: View {
    @ObservedObject var manager: ImagePickerManager
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(manager.selectedItems) { item in
                ZStack(alignment: .topTrailing) {
                    if let image = item.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipped()
                            .cornerRadius(8)
                    }

                    if item.isVideo {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "video.fill")
                                    .font(.caption2)
                                Text(formatDuration(item.duration))
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                            .padding(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        manager.removeItem(item)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .padding(4)
                }
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
