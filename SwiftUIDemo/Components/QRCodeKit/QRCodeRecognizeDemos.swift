import SwiftUI
import PhotosUI

// MARK: - Album Recognition Demo

struct QRAlbumRecognizeDemo: View {
    @State private var selectedImage: UIImage?
    @State private var results: [QRRecognitionResult] = []
    @State private var showPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(8)

                        ForEach(results) { result in
                            Rectangle()
                                .stroke(Color.green, lineWidth: 2)
                                .frame(
                                    width: result.bounds.width * 300,
                                    height: result.bounds.height * 300
                                )
                        }
                    }
                }

                Button("从相册选择") {
                    showPicker = true
                }
                .buttonStyle(.borderedProminent)

                if !results.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("识别结果 (\(results.count)个)")
                            .font(.headline)
                        ForEach(results) { result in
                            HStack {
                                Image(systemName: "qrcode")
                                    .foregroundColor(.blue)
                                Text(result.content)
                                    .font(.body)
                                    .lineLimit(3)
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                } else if selectedImage != nil {
                    Text("未识别到二维码")
                        .foregroundColor(.orange)
                }
            }
            .padding()
        }
        .navigationTitle("相册识别")
        .sheet(isPresented: $showPicker) {
            QRImagePickerView(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newValue in
            if let image = newValue {
                results = QRCodeRecognizer.recognize(from: image)
            }
        }
    }
}

// MARK: - Camera Recognition Demo

struct QRCameraRecognizeDemo: View {
    @State private var showScanner = false
    @State private var lastResult: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("使用摄像头实时识别二维码")
                .font(.headline)

            if !lastResult.isEmpty {
                VStack {
                    Text("上次识别结果:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(lastResult)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }

            Button("打开摄像头") {
                showScanner = true
            }
            .buttonStyle(.borderedProminent)

            Text("需要摄像头权限")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("摄像头识别")
        .fullScreenCover(isPresented: $showScanner) {
            QRCameraScannerView()
        }
    }
}

// MARK: - Batch Recognition Demo

struct QRBatchRecognizeDemo: View {
    @State private var testImages: [UIImage] = []
    @State private var allResults: [[QRRecognitionResult]] = []
    @State private var isProcessing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("批量识别多张图片中的二维码")
                    .font(.headline)

                Button(isProcessing ? "处理中..." : "生成测试图片并识别") {
                    runBatchTest()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)

                if !allResults.isEmpty {
                    ForEach(Array(allResults.enumerated()), id: \.offset) { index, results in
                        VStack(alignment: .leading) {
                            HStack {
                                if index < testImages.count {
                                    Image(uiImage: testImages[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(4)
                                }
                                VStack(alignment: .leading) {
                                    Text("图片 #\(index + 1)")
                                        .font(.subheadline.bold())
                                    Text("发现 \(results.count) 个二维码")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    ForEach(results) { r in
                                        Text(r.content)
                                            .font(.caption2)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("批量识别")
    }

    private func runBatchTest() {
        isProcessing = true
        let contents = ["Batch Test 1", "Batch Test 2", "Batch Test 3"]

        testImages = contents.compactMap { content in
            var config = QRGenerationConfig()
            config.content = content
            config.size = 200
            return QRCodeGenerator.shared.generate(config: config)
        }

        Task {
            let results = await QRCodeRecognizer.batchRecognize(images: testImages)
            await MainActor.run {
                allResults = results
                isProcessing = false
            }
        }
    }
}

// MARK: - Region Recognition Demo

struct QRRegionRecognizeDemo: View {
    let params: [String: String]
    @State private var testImage: UIImage?
    @State private var results: [QRRecognitionResult] = []
    @State private var regionX: CGFloat = 0.2
    @State private var regionY: CGFloat = 0.2
    @State private var regionW: CGFloat = 0.6
    @State private var regionH: CGFloat = 0.6

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = testImage {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)

                        GeometryReader { geo in
                            Rectangle()
                                .stroke(Color.red, lineWidth: 2)
                                .frame(
                                    width: geo.size.width * regionW,
                                    height: geo.size.height * regionH
                                )
                                .offset(
                                    x: geo.size.width * regionX,
                                    y: geo.size.height * regionY
                                )
                        }
                        .frame(width: 280, height: 280)
                    }
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("识别区域设置 (红色框)")
                        .font(.caption.bold())
                    HStack {
                        Text("X: \(String(format: "%.1f", regionX))")
                        Slider(value: $regionX, in: 0...0.5)
                    }
                    HStack {
                        Text("Y: \(String(format: "%.1f", regionY))")
                        Slider(value: $regionY, in: 0...0.5)
                    }
                    HStack {
                        Text("W: \(String(format: "%.1f", regionW))")
                        Slider(value: $regionW, in: 0.2...1.0)
                    }
                    HStack {
                        Text("H: \(String(format: "%.1f", regionH))")
                        Slider(value: $regionH, in: 0.2...1.0)
                    }
                }
                .font(.caption)
                .padding(.horizontal)

                Button("在区域内识别") { recognizeInRegion() }
                    .buttonStyle(.borderedProminent)

                if !results.isEmpty {
                    ForEach(results) { r in
                        Text("识别到: \(r.content)")
                            .font(.caption)
                            .padding(8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                } else if testImage != nil {
                    Text("区域内未识别到二维码")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding()
        }
        .navigationTitle("自定义识别区域")
        .onAppear {
            regionX = CGFloat(Double(params["x"] ?? "0.2") ?? 0.2)
            regionY = CGFloat(Double(params["y"] ?? "0.2") ?? 0.2)
            regionW = CGFloat(Double(params["width"] ?? "0.6") ?? 0.6)
            regionH = CGFloat(Double(params["height"] ?? "0.6") ?? 0.6)
            generateTestImage()
        }
    }

    private func generateTestImage() {
        var config = QRGenerationConfig()
        config.content = "Region Test QRCode"
        config.size = 300
        testImage = QRCodeGenerator.shared.generate(config: config)
        recognizeInRegion()
    }

    private func recognizeInRegion() {
        guard let image = testImage else { return }
        let region = CGRect(x: regionX, y: regionY, width: regionW, height: regionH)
        results = QRCodeRecognizer.recognize(from: image, region: region)
    }
}
