import SwiftUI

// MARK: - Rotation Demo

struct QRRotationDemo: View {
    let params: [String: String]
    @State private var generatedImage: UIImage?
    @State private var angle: Double = 45

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }

                VStack(alignment: .leading) {
                    Text("旋转角度: \(Int(angle))°")
                    Slider(value: $angle, in: 0...360, step: 5)
                }
                .padding(.horizontal)

                Button("重新生成") { generate() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("旋转二维码")
        .onAppear {
            angle = Double(params["angle"] ?? "45") ?? 45
            generate()
        }
        .onChange(of: angle) { _, _ in generate() }
    }

    private func generate() {
        var config = QRGenerationConfig()
        config.content = params["content"] ?? "Rotated QRCode"
        config.size = 300
        config.rotation = angle
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }
}

// MARK: - Watermark Demo

struct QRWatermarkDemo: View {
    let params: [String: String]
    @State private var generatedImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                }

                Text("水印叠加在二维码上方，降低可见度以保持可扫描性")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("水印叠加")
        .onAppear { generate() }
    }

    private func generate() {
        var config = QRGenerationConfig()
        config.content = params["content"] ?? "Watermark Demo"
        config.size = 300
        config.correctionLevel = .H
        config.watermarkImage = createWatermark()
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }

    private func createWatermark() -> UIImage {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 60),
                .foregroundColor: UIColor.systemRed.withAlphaComponent(0.5)
            ]
            let text = "DEMO" as NSString
            text.draw(at: CGPoint(x: 60, y: 120), withAttributes: attrs)
        }
    }
}

// MARK: - Blur Demo

struct QRBlurDemo: View {
    let params: [String: String]
    @State private var generatedImage: UIImage?
    @State private var blurRadius: CGFloat = 2

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .cornerRadius(8)
                }

                VStack(alignment: .leading) {
                    Text("模糊半径: \(String(format: "%.1f", blurRadius))")
                    Slider(value: $blurRadius, in: 0...10, step: 0.5)
                }
                .padding(.horizontal)

                Text("注意：过大的模糊半径会导致二维码无法识别")
                    .font(.caption)
                    .foregroundColor(.orange)

                Button("重新生成") { generate() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("高斯模糊")
        .onAppear {
            blurRadius = CGFloat(Double(params["radius"] ?? "2") ?? 2)
            generate()
        }
    }

    private func generate() {
        var config = QRGenerationConfig()
        config.content = params["content"] ?? "Blur Demo"
        config.size = 300
        config.applyBlur = blurRadius > 0
        config.blurRadius = blurRadius
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }
}

// MARK: - GIF Demo

struct QRGIFDemo: View {
    let params: [String: String]
    @State private var frames: [UIImage] = []
    @State private var currentFrame: Int = 0
    @State private var timer: Timer?
    @State private var isAnimating = false
    @State private var gifData: Data?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !frames.isEmpty {
                    Image(uiImage: frames[currentFrame])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                }

                HStack(spacing: 16) {
                    Button(isAnimating ? "停止" : "播放") {
                        toggleAnimation()
                    }
                    .buttonStyle(.borderedProminent)

                    if gifData != nil {
                        Text("GIF已生成 (\(frames.count)帧)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Text("动态二维码：内容在帧之间变化")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("GIF动图二维码")
        .onAppear { generateFrames() }
        .onDisappear { timer?.invalidate() }
    }

    private func generateFrames() {
        let contents = (params["contents"] ?? "Frame1,Frame2,Frame3,Frame4")
            .split(separator: ",")
            .map(String.init)
        let duration = TimeInterval(params["frameDuration"] ?? "0.5") ?? 0.5

        let configs: [QRGenerationConfig] = contents.enumerated().map { index, content in
            var config = QRGenerationConfig()
            config.content = content
            config.size = 300
            let hue = CGFloat(index) / CGFloat(contents.count)
            config.foregroundColor = Color(hue: Double(hue), saturation: 0.8, brightness: 0.4)
            return config
        }

        frames = configs.compactMap { QRCodeGenerator.shared.generate(config: $0) }
        gifData = QRCodeGenerator.shared.generateGIF(configs: configs, frameDuration: duration)

        if !frames.isEmpty {
            toggleAnimation()
        }
    }

    private func toggleAnimation() {
        if isAnimating {
            timer?.invalidate()
            timer = nil
            isAnimating = false
        } else {
            let duration = TimeInterval(params["frameDuration"] ?? "0.5") ?? 0.5
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in
                currentFrame = (currentFrame + 1) % frames.count
            }
            isAnimating = true
        }
    }
}
