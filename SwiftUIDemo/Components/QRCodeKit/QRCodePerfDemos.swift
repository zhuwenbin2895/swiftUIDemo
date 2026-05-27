import SwiftUI

// MARK: - Async Performance Demo

struct QRAsyncPerfDemo: View {
    let params: [String: String]
    @State private var images: [UIImage] = []
    @State private var elapsed: TimeInterval = 0
    @State private var isGenerating = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("异步生成避免阻塞主线程")
                    .font(.headline)

                if elapsed > 0 {
                    HStack {
                        Image(systemName: "clock")
                        Text("生成耗时: \(String(format: "%.2f", elapsed))秒")
                    }
                    .foregroundColor(.green)
                }

                Button(isGenerating ? "生成中..." : "异步生成\(params["count"] ?? "10")个二维码") {
                    generateAsync()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)

                if isGenerating {
                    ProgressView()
                        .scaleEffect(1.5)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("异步生成")
    }

    private func generateAsync() {
        isGenerating = true
        images = []
        let count = Int(params["count"] ?? "10") ?? 10
        let start = Date()

        Task {
            var generated: [UIImage] = []
            for i in 0..<count {
                var config = QRGenerationConfig()
                config.content = "Async Item #\(i + 1) - \(UUID().uuidString.prefix(8))"
                config.size = 200
                if let img = await QRCodeGenerator.shared.generateAsync(config: config) {
                    generated.append(img)
                }
            }
            await MainActor.run {
                images = generated
                elapsed = Date().timeIntervalSince(start)
                isGenerating = false
            }
        }
    }
}

// MARK: - Cache Performance Demo

struct QRCachePerfDemo: View {
    let params: [String: String]
    @State private var firstRunTime: TimeInterval = 0
    @State private var cachedRunTime: TimeInterval = 0
    @State private var generatedImage: UIImage?
    @State private var hasRun = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("缓存机制演示")
                    .font(.headline)
                Text("相同内容二次生成时命中缓存")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let image = generatedImage {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(8)
                }

                Button("运行缓存测试") { runCacheTest() }
                    .buttonStyle(.borderedProminent)

                if hasRun {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.orange)
                            Text("首次生成:")
                            Spacer()
                            Text("\(String(format: "%.4f", firstRunTime))秒")
                                .fontWeight(.bold)
                        }
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.green)
                            Text("缓存命中:")
                            Spacer()
                            Text("\(String(format: "%.4f", cachedRunTime))秒")
                                .fontWeight(.bold)
                        }
                        if firstRunTime > 0 {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.blue)
                                Text("加速比:")
                                Spacer()
                                Text("\(String(format: "%.1f", firstRunTime / max(cachedRunTime, 0.0001)))x")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("缓存机制")
    }

    private func runCacheTest() {
        QRCodeGenerator.shared.clearCache()
        let content = params["content"] ?? "Cache Demo"
        let iterations = Int(params["iterations"] ?? "5") ?? 5

        var config = QRGenerationConfig()
        config.content = content
        config.size = 300

        let start1 = Date()
        for _ in 0..<iterations {
            QRCodeGenerator.shared.clearCache()
            _ = QRCodeGenerator.shared.generate(config: config)
        }
        firstRunTime = Date().timeIntervalSince(start1)

        _ = QRCodeGenerator.shared.generate(config: config)

        let start2 = Date()
        for _ in 0..<iterations {
            generatedImage = QRCodeGenerator.shared.generate(config: config)
        }
        cachedRunTime = Date().timeIntervalSince(start2)
        hasRun = true
    }
}

// MARK: - Batch Performance Demo

struct QRBatchPerfDemo: View {
    let params: [String: String]
    @State private var progress: Double = 0
    @State private var isGenerating = false
    @State private var elapsed: TimeInterval = 0
    @State private var memoryBefore: UInt64 = 0
    @State private var memoryAfter: UInt64 = 0
    @State private var sampleImages: [UIImage] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("大规模生成时的内存控制")
                    .font(.headline)

                if isGenerating {
                    VStack {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                    }
                    .padding(.horizontal)
                }

                Button(isGenerating ? "生成中..." : "批量生成\(params["count"] ?? "20")个") {
                    batchGenerate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)

                if elapsed > 0 {
                    VStack(spacing: 8) {
                        HStack {
                            Text("总耗时:")
                            Spacer()
                            Text("\(String(format: "%.2f", elapsed))秒")
                                .fontWeight(.bold)
                        }
                        HStack {
                            Text("内存增长:")
                            Spacer()
                            Text("\(formatBytes(memoryAfter - memoryBefore))")
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                if !sampleImages.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 4) {
                        ForEach(Array(sampleImages.enumerated()), id: \.offset) { _, img in
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("批量生成")
    }

    private func batchGenerate() {
        isGenerating = true
        progress = 0
        sampleImages = []
        let count = Int(params["count"] ?? "20") ?? 20
        let prefix = params["prefix"] ?? "Batch Item #"

        memoryBefore = reportMemory()
        let start = Date()

        Task {
            var samples: [UIImage] = []
            for i in 0..<count {
                var config = QRGenerationConfig()
                config.content = "\(prefix)\(i + 1)"
                config.size = 200

                if let img = await QRCodeGenerator.shared.generateAsync(config: config) {
                    if i < 12 {
                        samples.append(img)
                    }
                }

                await MainActor.run {
                    progress = Double(i + 1) / Double(count)
                }
            }

            await MainActor.run {
                sampleImages = samples
                elapsed = Date().timeIntervalSince(start)
                memoryAfter = reportMemory()
                isGenerating = false
            }
        }
    }

    private func reportMemory() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return result == KERN_SUCCESS ? info.resident_size : 0
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb)
    }
}
