import SwiftUI

// MARK: - Encode Demo

struct QREncodeDemo: View {
    let type: QRContentType
    let params: [String: String]
    @State private var generatedImage: UIImage?
    @State private var encodedContent: String = ""

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
                        .shadow(radius: 4)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label(type.displayName, systemImage: type.icon)
                        .font(.headline)

                    Divider()

                    Text("编码内容:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Text(encodedContent)
                        .font(.system(.caption, design: .monospaced))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                }
                .padding(.horizontal)

                paramsView
            }
            .padding()
        }
        .navigationTitle(type.displayName)
        .onAppear { generate() }
    }

    @ViewBuilder
    private var paramsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("参数:")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            ForEach(Array(params.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                HStack {
                    Text(key)
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(value)
                        .font(.caption)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private func generate() {
        encodedContent = QRContentEncoder.encode(type: type, params: params)

        var config = QRGenerationConfig()
        config.content = encodedContent
        config.size = 300
        config.correctionLevel = .M
        generatedImage = QRCodeGenerator.shared.generate(config: config)
    }
}
