import SwiftUI
import UIKit
import PhotosUI

struct ImagePickerDemoView: View {
    var body: some View {
        List {
            Section("选择功能") {
                NavigationLink("相册多选") { MultiSelectDemoView() }
                NavigationLink("原图选项") { OriginalImageDemoView() }
                NavigationLink("视频选择") { VideoSelectDemoView() }
            }
            Section("编辑功能") {
                NavigationLink("图片裁剪") { ImageCropDemoView() }
            }
            Section("综合演示") {
                NavigationLink("完整图片选择器") { FullPickerDemoView() }
            }
        }
        .navigationTitle("ImagePicker")
    }
}

// MARK: - Multi Select Demo

struct MultiSelectDemoView: View {
    @StateObject private var manager = ImagePickerManager()
    @State private var pickerItems: [PhotosPickerItem] = []

    var body: some View {
        VStack(spacing: 16) {
            if manager.selectedItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("最多选择\(manager.config.maxSelectionCount)张图片")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("已选择 \(manager.selectedItems.count)/\(manager.config.maxSelectionCount) 张")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        SelectedMediaGrid(manager: manager)
                    }
                    .padding()
                }
            }

            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: manager.config.maxSelectionCount,
                matching: .images
            ) {
                Label("选择图片", systemImage: "photo.badge.plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .onChange(of: pickerItems) { _, newItems in
                manager.clearAll()
                manager.addItems(from: newItems)
            }
        }
        .navigationTitle("相册多选")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Original Image Demo

struct OriginalImageDemoView: View {
    @StateObject private var manager = ImagePickerManager()
    @State private var pickerItems: [PhotosPickerItem] = []

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 16) {
                    if !manager.selectedItems.isEmpty {
                        SelectedMediaGrid(manager: manager)
                            .padding(.horizontal)
                    }

                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("原图", isOn: $manager.isOriginal)
                            if manager.isOriginal {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                    Text("将以原始分辨率保存，文件较大")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                                        .foregroundColor(.orange)
                                    Text("将自动压缩图片以节省空间")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    if let firstImage = manager.selectedItems.first?.image {
                        GroupBox("图片信息") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("尺寸: \(Int(firstImage.size.width)) × \(Int(firstImage.size.height))")
                                    .font(.caption)
                                if manager.isOriginal {
                                    Text("模式: 原图 (无损)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("模式: 压缩 (推荐)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: 3,
                matching: .images
            ) {
                Label("选择图片", systemImage: "photo.badge.plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .onChange(of: pickerItems) { _, newItems in
                manager.clearAll()
                manager.addItems(from: newItems)
            }
        }
        .navigationTitle("原图选项")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Video Select Demo

struct VideoSelectDemoView: View {
    @StateObject private var manager = ImagePickerManager()
    @State private var pickerItems: [PhotosPickerItem] = []

    var body: some View {
        VStack(spacing: 16) {
            if manager.selectedItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "video.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("支持选择视频文件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("最长时长: \(Int(manager.config.videoMaxDuration))秒")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    SelectedMediaGrid(manager: manager)
                        .padding()
                }
            }

            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: 3,
                matching: .any(of: [.videos, .images])
            ) {
                Label("选择视频/图片", systemImage: "video.badge.plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .onChange(of: pickerItems) { _, newItems in
                manager.clearAll()
                manager.addItems(from: newItems)
            }
        }
        .navigationTitle("视频选择")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Image Crop Demo

struct ImageCropDemoView: View {
    @StateObject private var manager = ImagePickerManager()
    @State private var pickerItem: PhotosPickerItem?
    @State private var sourceImage: UIImage?

    var body: some View {
        VStack(spacing: 16) {
            if manager.showCropper, let image = manager.cropImage {
                ImageCropView(
                    image: image,
                    aspectRatio: 1.0,
                    onCrop: { cropped in
                        manager.finishCrop(cropped)
                    },
                    onCancel: {
                        manager.showCropper = false
                    }
                )
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        if let source = sourceImage {
                            GroupBox("原图") {
                                Image(uiImage: source)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                            }

                            Button("裁剪此图片") {
                                manager.startCrop(source)
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        if let cropped = manager.croppedImage {
                            GroupBox("裁剪结果") {
                                Image(uiImage: cropped)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                            }
                        }

                        if sourceImage == nil {
                            VStack(spacing: 12) {
                                Image(systemName: "crop")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("选择图片后可进行裁剪")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        }
                    }
                    .padding()
                }

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("选择图片", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .onChange(of: pickerItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            sourceImage = image
                        }
                    }
                }
            }
        }
        .navigationTitle("图片裁剪")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Full Picker Demo

struct FullPickerDemoView: View {
    @StateObject private var manager = ImagePickerManager()
    @State private var pickerItems: [PhotosPickerItem] = []

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    GroupBox("设置") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("最多选择")
                                Spacer()
                                Stepper("\(manager.config.maxSelectionCount)张", value: $manager.config.maxSelectionCount, in: 1...20)
                            }
                            Toggle("允许原图", isOn: $manager.config.allowsOriginal)
                            Toggle("允许视频", isOn: $manager.config.allowsVideo)
                            Toggle("允许裁剪", isOn: $manager.config.allowsCropping)
                        }
                    }
                    .padding(.horizontal)

                    if !manager.selectedItems.isEmpty {
                        GroupBox("已选择 (\(manager.selectedItems.count))") {
                            SelectedMediaGrid(manager: manager)
                        }
                        .padding(.horizontal)

                        if manager.config.allowsOriginal {
                            Toggle("发送原图", isOn: $manager.isOriginal)
                                .padding(.horizontal, 32)
                        }

                        Button("清空选择") {
                            manager.clearAll()
                            pickerItems.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding(.vertical)
            }

            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: manager.config.maxSelectionCount,
                matching: manager.config.allowsVideo ? .any(of: [.images, .videos]) : .images
            ) {
                Label("打开相册", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
            .onChange(of: pickerItems) { _, newItems in
                manager.clearAll()
                manager.addItems(from: newItems)
            }
        }
        .navigationTitle("完整图片选择器")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ImagePickerDemoView()
    }
}
