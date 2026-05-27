import SwiftUI

// MARK: - Logo Demo

struct QRLogoDemo: View {
    let params: [String: String]
    @State private var generatedImage: UIImage?
    @State private var cornerRadius: CGFloat = 12
    @State private var sizeRatio: CGFloat = 0.2

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

                VStack(alignment: .leading) {
                    Text("Logo圆角: \(Int(cornerRadius))")
                    Slider(value: $cornerRadius, in: 0...30, step: 1)

                    Text("Logo比例: \(String(format: "%.0f%%", sizeRatio * 100))")
                    Slider(value: $sizeRatio, in: 0.1...0.35, step: 0.05)
                }
                .padding(.horizontal)

                Button("重新生成") { generate() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("嵌入Logo")
        .onAppear {
            cornerRadius = CGFloat(Double(params["logoCornerRadius"] ?? "12") ?? 12)
            sizeRatio = CGFloat(Double(params["logoSizeRatio"] ?? "0.2") ?? 0.2)
            generate()
        }
    }

    private func generate() {
        var config = QRGenerationConfig()
        config.content = params["content"] ?? "Logo QRCode"
        config.size = 300
        config.correctionLevel = .H
        config.logoImage = createSampleLogo()
        config.logoCornerRadius = cornerRadius
        config.logoSizeRatio = sizeRatio
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }

    private func createSampleLogo() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            UIColor.systemBlue.setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 20).fill()

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 40),
                .foregroundColor: UIColor.white
            ]
            let text = "Q" as NSString
            let textSize = text.size(withAttributes: attrs)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attrs)
        }
    }
}

// MARK: - Dot Style Demo

struct QRDotStyleDemo: View {
    let params: [String: String]
    @State private var generatedImage: UIImage?
    @State private var selectedStyle: QRDotStyle = .roundedRect

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

                Picker("码点样式", selection: $selectedStyle) {
                    ForEach(QRDotStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("码点样式")
        .onAppear {
            if let styleName = params["dotStyle"], let style = QRDotStyle(rawValue: styleName) {
                selectedStyle = style
            }
            generate()
        }
        .onChange(of: selectedStyle) { _, _ in generate() }
    }

    private func generate() {
        var config = QRGenerationConfig()
        config.content = params["content"] ?? "Dot Style Demo"
        config.size = 300
        config.dotStyle = selectedStyle
        config.correctionLevel = .H
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }
}

// MARK: - Gradient Demo

struct QRGradientDemo: View {
    let params: [String: String]
    @State private var generatedImage: UIImage?
    @State private var direction: QRGradientDirection = .topToBottom
    @State private var startColor: Color = .blue
    @State private var endColor: Color = .purple

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

                Picker("渐变方向", selection: $direction) {
                    ForEach(QRGradientDirection.allCases, id: \.self) { dir in
                        Text(dir.displayName).tag(dir)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                HStack {
                    VStack {
                        Text("起始色").font(.caption)
                        ColorPicker("", selection: $startColor).labelsHidden()
                    }
                    Spacer()
                    VStack {
                        Text("结束色").font(.caption)
                        ColorPicker("", selection: $endColor).labelsHidden()
                    }
                }
                .padding(.horizontal, 60)

                Button("重新生成") { generate() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("渐变前景色")
        .onAppear {
            if let dir = params["direction"], let d = QRGradientDirection(rawValue: dir) {
                direction = d
            }
            generate()
        }
        .onChange(of: direction) { _, _ in generate() }
    }

    private func generate() {
        var config = QRGenerationConfig()
        config.content = params["content"] ?? "Gradient QRCode"
        config.size = 300
        config.useGradient = true
        config.gradientStartColor = startColor
        config.gradientEndColor = endColor
        config.gradientDirection = direction
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }
}

// MARK: - Background Fusion Demo

struct QRBackgroundFusionDemo: View {
    let params: [String: String]
    @State private var generatedImage: UIImage?
    @State private var alpha: CGFloat = 0.3

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

                VStack(alignment: .leading) {
                    Text("融合透明度: \(String(format: "%.0f%%", alpha * 100))")
                    Slider(value: $alpha, in: 0.1...0.8, step: 0.05)
                }
                .padding(.horizontal)

                Button("重新生成") { generate() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("背景图融合")
        .onAppear {
            alpha = CGFloat(Double(params["alpha"] ?? "0.3") ?? 0.3)
            generate()
        }
    }

    private func generate() {
        var config = QRGenerationConfig()
        config.content = params["content"] ?? "Background Fusion"
        config.size = 300
        config.correctionLevel = .H
        config.backgroundImage = createSampleBackground()
        config.backgroundImageAlpha = alpha
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }

    private func createSampleBackground() -> UIImage {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let colors = [UIColor.systemOrange.cgColor, UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) {
                ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 300, y: 300), options: [])
            }
        }
    }
}
