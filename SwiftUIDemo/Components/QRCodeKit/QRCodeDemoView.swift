import SwiftUI

// MARK: - QRCode Demo Entry View

struct QRCodeDemoView: View {
    @State private var sections: [QRDemoSection] = []

    var body: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.items) { item in
                        NavigationLink {
                            destinationView(for: item)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Label(section.title, systemImage: section.icon)
                }
            }
        }
        .navigationTitle("QRCodeKit")
        .onAppear(perform: loadMockData)
    }

    private func loadMockData() {
        guard let url = Bundle.main.url(forResource: "QRCodeMockData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(QRDemoData.self, from: data) else {
            sections = defaultSections()
            return
        }
        sections = decoded.sections
    }

    @ViewBuilder
    private func destinationView(for item: QRDemoItem) -> some View {
        switch item.type {
        case "generate_basic":
            QRBasicGenerateDemo(params: item.params ?? [:])
        case "generate_size":
            QRSizeDemo(params: item.params ?? [:])
        case "generate_correction":
            QRCorrectionDemo(params: item.params ?? [:])
        case "generate_color":
            QRColorDemo(params: item.params ?? [:])
        case "style_logo":
            QRLogoDemo(params: item.params ?? [:])
        case "style_dot":
            QRDotStyleDemo(params: item.params ?? [:])
        case "style_gradient":
            QRGradientDemo(params: item.params ?? [:])
        case "style_background":
            QRBackgroundFusionDemo(params: item.params ?? [:])
        case "art_rotation":
            QRRotationDemo(params: item.params ?? [:])
        case "art_watermark":
            QRWatermarkDemo(params: item.params ?? [:])
        case "art_blur":
            QRBlurDemo(params: item.params ?? [:])
        case "art_gif":
            QRGIFDemo(params: item.params ?? [:])
        case "recognize_album":
            QRAlbumRecognizeDemo()
        case "recognize_camera":
            QRCameraRecognizeDemo()
        case "recognize_batch":
            QRBatchRecognizeDemo()
        case "recognize_region":
            QRRegionRecognizeDemo(params: item.params ?? [:])
        case "encode_text":
            QREncodeDemo(type: .text, params: item.params ?? [:])
        case "encode_url":
            QREncodeDemo(type: .url, params: item.params ?? [:])
        case "encode_vcard":
            QREncodeDemo(type: .vCard, params: item.params ?? [:])
        case "encode_wifi":
            QREncodeDemo(type: .wifi, params: item.params ?? [:])
        case "encode_geo":
            QREncodeDemo(type: .geo, params: item.params ?? [:])
        case "encode_email":
            QREncodeDemo(type: .email, params: item.params ?? [:])
        case "encode_phone":
            QREncodeDemo(type: .phone, params: item.params ?? [:])
        case "perf_async":
            QRAsyncPerfDemo(params: item.params ?? [:])
        case "perf_cache":
            QRCachePerfDemo(params: item.params ?? [:])
        case "perf_batch":
            QRBatchPerfDemo(params: item.params ?? [:])
        default:
            Text("未实现: \(item.type)")
        }
    }

    private func defaultSections() -> [QRDemoSection] {
        [
            QRDemoSection(title: "基础生成", icon: "qrcode", items: [
                QRDemoItem(title: "纯文本二维码", subtitle: "生成包含文本内容的基础二维码", type: "generate_basic", params: ["content": "Hello, QRCode!", "size": "300", "correctionLevel": "M"])
            ]),
            QRDemoSection(title: "高级样式", icon: "paintbrush.pointed", items: [
                QRDemoItem(title: "圆角矩形码点", subtitle: "使用圆角矩形替代方形码点", type: "style_dot", params: ["content": "RoundedRect", "dotStyle": "roundedRect"])
            ]),
            QRDemoSection(title: "识别功能", icon: "camera.viewfinder", items: [
                QRDemoItem(title: "相册识别", subtitle: "从相册选择图片识别", type: "recognize_album", params: nil)
            ])
        ]
    }
}
