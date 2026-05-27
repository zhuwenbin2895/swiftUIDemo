import SwiftUI

// MARK: - Basic Generate Demo

struct QRBasicGenerateDemo: View {
    let params: [String: String]
    @State private var content: String = ""
    @State private var generatedImage: UIImage?
    @State private var size: CGFloat = 300

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = generatedImage {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                }

                TextField("输入内容", text: $content)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button("生成二维码") {
                    generateQR()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("纯文本二维码")
        .onAppear {
            content = params["content"] ?? "Hello, QRCode!"
            size = CGFloat(Double(params["size"] ?? "300") ?? 300)
            generateQR()
        }
    }

    private func generateQR() {
        var config = QRGenerationConfig()
        config.content = content
        config.size = size
        config.correctionLevel = QRCorrectionLevel(rawValue: params["correctionLevel"] ?? "M") ?? .M
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }
}

// MARK: - Size Demo

struct QRSizeDemo: View {
    let params: [String: String]
    @State private var images: [(CGFloat, UIImage)] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(images, id: \.0) { size, image in
                    VStack {
                        Text("\(Int(size)) × \(Int(size))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(uiImage: image)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.6, height: size * 0.6)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("自定义尺寸")
        .onAppear { generate() }
    }

    private func generate() {
        let content = params["content"] ?? "Size Demo"
        let sizes: [CGFloat] = (params["sizes"] ?? "200,300,500")
            .split(separator: ",")
            .compactMap { CGFloat(Double(String($0)) ?? 0) }

        images = sizes.compactMap { size in
            var config = QRGenerationConfig()
            config.content = content
            config.size = size
            guard let img = QRCodeGenerator.shared.generate(config: config) else { return nil }
            return (size, img)
        }
    }
}

// MARK: - Correction Level Demo

struct QRCorrectionDemo: View {
    let params: [String: String]
    @State private var images: [(QRCorrectionLevel, UIImage)] = []

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(images, id: \.0) { level, image in
                    VStack {
                        Image(uiImage: image)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        Text("纠错等级: \(level.rawValue)")
                            .font(.caption)
                        Text(level.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("纠错等级对比")
        .onAppear { generate() }
    }

    private func generate() {
        let content = params["content"] ?? "Error Correction Demo"
        images = QRCorrectionLevel.allCases.compactMap { level in
            var config = QRGenerationConfig()
            config.content = content
            config.size = 300
            config.correctionLevel = level
            guard let img = QRCodeGenerator.shared.generate(config: config) else { return nil }
            return (level, img)
        }
    }
}

// MARK: - Color Demo

struct QRColorDemo: View {
    let params: [String: String]
    @State private var foregroundColor: Color = .blue
    @State private var backgroundColor: Color = .yellow.opacity(0.2)
    @State private var generatedImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = generatedImage {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .cornerRadius(8)
                }

                HStack {
                    VStack {
                        Text("前景色")
                            .font(.caption)
                        ColorPicker("", selection: $foregroundColor)
                            .labelsHidden()
                    }
                    Spacer()
                    VStack {
                        Text("背景色")
                            .font(.caption)
                        ColorPicker("", selection: $backgroundColor)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal, 60)

                Button("重新生成") { generate() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("自定义颜色")
        .onAppear { generate() }
        .onChange(of: foregroundColor) { _, _ in generate() }
        .onChange(of: backgroundColor) { _, _ in generate() }
    }

    private func generate() {
        var config = QRGenerationConfig()
        config.content = params["content"] ?? "Color Demo"
        config.size = 300
        config.foregroundColor = foregroundColor
        config.backgroundColor = backgroundColor
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }
}
