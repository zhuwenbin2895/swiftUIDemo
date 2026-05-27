import SwiftUI
import UIKit
import Combine

// MARK: - Demo View

struct AsyncRenderDemoView: View {
    var body: some View {
        List {
            Section("线程模型") {
                NavigationLink("预排版后台线程") { ThreadModelLayoutDemo() }
                NavigationLink("预渲染后台线程") { ThreadModelRenderDemo() }
                NavigationLink("异步圆角图片处理") { AsyncCornerRadiusDemo() }
                NavigationLink("主线程职责演示") { MainThreadDemo() }
            }
            Section("布局缓存") {
                NavigationLink("缓存排版结果") { LayoutCacheDemo() }
                NavigationLink("智能失效缓存") { CacheInvalidationDemo() }
                NavigationLink("渲染上下文对象") { RenderContextDemo() }
            }
            Section("绘制引擎") {
                NavigationLink("自定义CALayer绘制") { CustomLayerDemo() }
                NavigationLink("文本异步绘制") { AsyncTextDrawDemo() }
                NavigationLink("图片异步解码") { AsyncImageDecodeDemo() }
                NavigationLink("复合图层合并") { CompositeLayerDemo() }
            }
            Section("滚动优化") {
                NavigationLink("滑动优先级调整") { ScrollPriorityDemo() }
                NavigationLink("预加载区域计算") { PreloadAreaDemo() }
                NavigationLink("RunLoop空闲执行") { RunLoopIdleDemo() }
                NavigationLink("滑动暂停渲染") { ScrollPauseDemo() }
            }
            Section("监控工具") {
                NavigationLink("渲染耗时监控") { RenderTimingDemo() }
                NavigationLink("帧率实时显示") { FPSMonitorDemo() }
                NavigationLink("耗时任务日志") { RenderLogDemo() }
            }
        }
        .navigationTitle("AsyncRender")
    }
}

// MARK: - Thread Model Demos

struct ThreadModelLayoutDemo: View {
    @State private var layoutResults: [(String, CGRect)] = []
    @State private var isCalculating = false
    @State private var duration: String = ""

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "预排版后台线程", description: "布局计算在后台线程执行，计算完成后回到主线程更新UI。避免布局计算阻塞主线程造成卡顿。")

            Button("开始后台布局计算") {
                isCalculating = true
                let start = CACurrentMediaTime()
                AsyncRenderScheduler.shared.performLayout {
                    var results: [(String, CGRect)] = []
                    for i in 0..<20 {
                        let y = CGFloat(i) * 50
                        let frame = CGRect(x: 16, y: y, width: 300, height: 44)
                        results.append(("Cell \(i)", frame))
                    }
                    Thread.sleep(forTimeInterval: 0.05)
                } completion: {
                    duration = String(format: "%.2fms", (CACurrentMediaTime() - start) * 1000)
                    layoutResults = (0..<20).map { ("Cell \($0)", CGRect(x: 16, y: CGFloat($0) * 50, width: 300, height: 44)) }
                    isCalculating = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCalculating)

            if isCalculating {
                ProgressView("后台计算中...")
            }

            if !duration.isEmpty {
                Text("布局计算耗时: \(duration)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(layoutResults, id: \.0) { item in
                        HStack {
                            Text(item.0)
                            Spacer()
                            Text("frame: \(item.1.debugDescription)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("预排版")
    }
}

struct ThreadModelRenderDemo: View {
    @State private var renderedImage: UIImage?
    @State private var isRendering = false
    @State private var duration: String = ""

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "预渲染后台线程", description: "图文绘制在后台线程完成，生成位图后主线程直接显示，无需实时绘制。")

            Button("后台绘制图文") {
                isRendering = true
                let start = CACurrentMediaTime()
                let commands: [AsyncDrawCommand] = [
                    .roundedRect(CGRect(x: 0, y: 0, width: 300, height: 200), 12, .systemBlue),
                    .gradient([.systemPurple, .systemPink], CGRect(x: 10, y: 10, width: 280, height: 60), CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5)),
                    .text(NSAttributedString(string: "异步渲染的文本内容", attributes: [
                        .font: UIFont.boldSystemFont(ofSize: 18),
                        .foregroundColor: UIColor.white
                    ]), CGRect(x: 20, y: 80, width: 260, height: 30)),
                    .line(CGPoint(x: 20, y: 120), CGPoint(x: 280, y: 120), .white.withAlphaComponent(0.5), 1)
                ]

                AsyncRenderScheduler.shared.performRender {
                    AsyncDrawEngine.render(commands: commands, size: CGSize(width: 300, height: 200), scale: UIScreen.main.scale)
                } completion: { image in
                    duration = String(format: "%.2fms", (CACurrentMediaTime() - start) * 1000)
                    if let cgImage = image {
                        renderedImage = UIImage(cgImage: cgImage)
                    }
                    isRendering = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRendering)

            if isRendering {
                ProgressView("后台绘制中...")
            }

            if !duration.isEmpty {
                Text("绘制耗时: \(duration)").font(.caption).foregroundColor(.secondary)
            }

            if let image = renderedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("预渲染")
    }
}

struct AsyncCornerRadiusDemo: View {
    @State private var originalImage: UIImage?
    @State private var processedImages: [(CGFloat, UIImage)] = []
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "异步圆角图片处理", description: "圆角绘制在后台线程完成，避免使用 layer.cornerRadius + clipsToBounds 导致的离屏渲染。")

            Button("生成圆角图片") {
                isProcessing = true
                processedImages.removeAll()

                let size = CGSize(width: 100, height: 100)
                let renderer = UIGraphicsImageRenderer(size: size)
                let img = renderer.image { ctx in
                    UIColor.systemOrange.setFill()
                    ctx.fill(CGRect(origin: .zero, size: size))
                    let text = "P" as NSString
                    text.draw(at: CGPoint(x: 35, y: 25), withAttributes: [
                        .font: UIFont.boldSystemFont(ofSize: 50),
                        .foregroundColor: UIColor.white
                    ])
                }
                originalImage = img

                let radii: [CGFloat] = [0, 10, 25, 50]
                let group = DispatchGroup()

                for radius in radii {
                    group.enter()
                    AsyncCornerRadiusProcessor.processImage(img, cornerRadius: radius, size: size) { result in
                        if let result = result {
                            processedImages.append((radius, result))
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    processedImages.sort { $0.0 < $1.0 }
                    isProcessing = false
                }
            }
            .buttonStyle(.borderedProminent)

            if isProcessing {
                ProgressView("处理中...")
            }

            if !processedImages.isEmpty {
                HStack(spacing: 16) {
                    ForEach(processedImages, id: \.0) { item in
                        VStack {
                            Image(uiImage: item.1)
                                .resizable()
                                .frame(width: 70, height: 70)
                            Text("r=\(Int(item.0))")
                                .font(.caption)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("异步圆角")
    }
}

struct MainThreadDemo: View {
    @State private var tapCount = 0
    @State private var backgroundTaskRunning = false
    @State private var taskCount = 0

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "主线程职责", description: "主线程仅负责视图组装和手势响应。后台任务不会阻塞手势交互。")

            Text("点击次数: \(tapCount)")
                .font(.title2)

            Button("点击测试手势响应") {
                tapCount += 1
            }
            .buttonStyle(.borderedProminent)

            Divider()

            Button(backgroundTaskRunning ? "后台任务运行中(\(taskCount)个)" : "启动多个后台任务") {
                backgroundTaskRunning = true
                taskCount = 0
                for i in 0..<10 {
                    AsyncRenderScheduler.shared.performLayout {
                        Thread.sleep(forTimeInterval: 0.1)
                    } completion: {
                        taskCount += 1
                        if taskCount == 10 { backgroundTaskRunning = false }
                    }
                    _ = i
                }
            }
            .buttonStyle(.bordered)
            .disabled(backgroundTaskRunning)

            Text("后台任务运行时，点击按钮依然流畅响应")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("主线程职责")
    }
}

// MARK: - Layout Cache Demos

struct LayoutCacheDemo: View {
    @State private var cacheHits = 0
    @State private var cacheMisses = 0
    @State private var cacheCount = 0

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "缓存排版结果", description: "相同参数的布局计算只执行一次，后续直接从缓存读取，大幅减少重复计算。")

            HStack(spacing: 24) {
                VStack {
                    Text("\(cacheHits)").font(.title).foregroundColor(.green)
                    Text("缓存命中").font(.caption)
                }
                VStack {
                    Text("\(cacheMisses)").font(.title).foregroundColor(.orange)
                    Text("缓存未命中").font(.caption)
                }
                VStack {
                    Text("\(cacheCount)").font(.title).foregroundColor(.blue)
                    Text("缓存条目").font(.caption)
                }
            }

            Button("执行布局(首次)") {
                let key = "demo_cell_\(Int.random(in: 0..<5))"
                let context = AsyncRenderContext()
                if AsyncLayoutCache.shared.get(key: key, contextVersion: context.version) != nil {
                    cacheHits += 1
                } else {
                    cacheMisses += 1
                    let result = AsyncLayoutResult(
                        frames: ["title": CGRect(x: 16, y: 12, width: 200, height: 22)],
                        contentSize: CGSize(width: 320, height: 80),
                        textLayouts: [:],
                        timestamp: CACurrentMediaTime()
                    )
                    AsyncLayoutCache.shared.set(key: key, result: result, contextVersion: context.version)
                }
                cacheCount = AsyncLayoutCache.shared.count
            }
            .buttonStyle(.borderedProminent)

            Button("连续查询缓存 x10") {
                for i in 0..<10 {
                    let key = "demo_cell_\(i % 5)"
                    let context = AsyncRenderContext()
                    if AsyncLayoutCache.shared.get(key: key, contextVersion: context.version) != nil {
                        cacheHits += 1
                    } else {
                        cacheMisses += 1
                        let result = AsyncLayoutResult(
                            frames: ["title": CGRect(x: 16, y: 12, width: 200, height: 22)],
                            contentSize: CGSize(width: 320, height: 80),
                            textLayouts: [:],
                            timestamp: CACurrentMediaTime()
                        )
                        AsyncLayoutCache.shared.set(key: key, result: result, contextVersion: context.version)
                    }
                }
                cacheCount = AsyncLayoutCache.shared.count
            }
            .buttonStyle(.bordered)

            Button("清空缓存") {
                AsyncLayoutCache.shared.invalidateAll()
                cacheCount = 0
                cacheHits = 0
                cacheMisses = 0
            }
            .foregroundColor(.red)

            Spacer()
        }
        .padding()
        .navigationTitle("布局缓存")
    }
}

struct CacheInvalidationDemo: View {
    @State private var contextVersion = 0
    @State private var fontSize: CGFloat = 15
    @State private var cacheValid = true
    @State private var logs: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "智能失效缓存", description: "当依赖的属性发生变化时（如字体大小、宽度），缓存自动失效，下次布局将重新计算。")

            VStack(alignment: .leading, spacing: 8) {
                Text("字体大小: \(Int(fontSize))pt")
                Slider(value: $fontSize, in: 12...24, step: 1) { editing in
                    if !editing {
                        contextVersion += 1
                        cacheValid = false
                        logs.insert("属性变更 → 缓存失效 (version: \(contextVersion))", at: 0)
                    }
                }
            }

            HStack {
                Circle()
                    .fill(cacheValid ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(cacheValid ? "缓存有效" : "缓存已失效")
            }

            Button("重新计算布局") {
                cacheValid = true
                logs.insert("重新计算完成 → 缓存更新 (version: \(contextVersion))", at: 0)
            }
            .buttonStyle(.borderedProminent)
            .disabled(cacheValid)

            List {
                ForEach(logs.prefix(10), id: \.self) { log in
                    Text(log).font(.caption).foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("缓存失效")
    }
}

struct RenderContextDemo: View {
    @State private var context = AsyncRenderContext()
    @State private var width: CGFloat = UIScreen.main.bounds.width
    @State private var fontSize: CGFloat = 15
    @State private var spacing: CGFloat = 8

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "渲染上下文对象", description: "RenderContext 管理所有渲染参数，参数变更自动触发版本递增，关联缓存失效。")

            Group {
                VStack(alignment: .leading) {
                    Text("宽度: \(Int(width))")
                    Slider(value: $width, in: 200...400)
                }
                VStack(alignment: .leading) {
                    Text("字体: \(Int(fontSize))pt")
                    Slider(value: $fontSize, in: 10...24)
                }
                VStack(alignment: .leading) {
                    Text("间距: \(Int(spacing))")
                    Slider(value: $spacing, in: 4...20)
                }
            }

            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 1)
                .frame(width: width, height: 100)
                .overlay(
                    VStack(spacing: spacing) {
                        Text("标题文本")
                            .font(.system(size: fontSize, weight: .bold))
                        Text("副标题内容区域")
                            .font(.system(size: fontSize - 2))
                    }
                )

            Text("Context Version: \(context.version)")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("渲染上下文")
        .onChange(of: width) { _ in context.invalidate() }
        .onChange(of: fontSize) { _ in context.invalidate() }
        .onChange(of: spacing) { _ in context.invalidate() }
    }
}

// MARK: - Draw Engine Demos

struct CustomLayerDemo: View {
    @State private var renderedImage: UIImage?
    @State private var layerStatus: String = "未创建"
    @State private var steps: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "自定义CALayer绘制", description: "AsyncDrawLayer 接管 CALayer 的 display() 方法，设置绘制命令后调用 renderAsync()，在后台线程完成全部绘制，主线程仅接收最终位图。")

            VStack(alignment: .leading, spacing: 4) {
                ForEach(steps, id: \.self) { step in
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(step).font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Button("使用 AsyncDrawLayer 绘制") {
                steps.removeAll()
                renderedImage = nil

                steps.append("1. 创建 AsyncDrawLayer 实例")
                let layer = AsyncDrawLayer()
                layer.bounds = CGRect(x: 0, y: 0, width: 300, height: 180)
                layer.contentsScale = UIScreen.main.scale

                steps.append("2. 设置绘制命令 (drawCommands)")
                layer.drawCommands = [
                    .gradient([.systemIndigo, .systemTeal], CGRect(x: 0, y: 0, width: 300, height: 180), .zero, CGPoint(x: 1, y: 1)),
                    .roundedRect(CGRect(x: 20, y: 20, width: 260, height: 60), 8, UIColor.white.withAlphaComponent(0.2)),
                    .text(NSAttributedString(string: "AsyncDrawLayer", attributes: [
                        .font: UIFont.systemFont(ofSize: 22, weight: .heavy),
                        .foregroundColor: UIColor.white
                    ]), CGRect(x: 40, y: 35, width: 220, height: 30)),
                    .text(NSAttributedString(string: "后台线程绘制完成", attributes: [
                        .font: UIFont.systemFont(ofSize: 14),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                    ]), CGRect(x: 40, y: 62, width: 220, height: 20)),
                    .line(CGPoint(x: 20, y: 100), CGPoint(x: 280, y: 100), .white, 0.5),
                    .roundedRect(CGRect(x: 20, y: 110, width: 80, height: 50), 6, UIColor.white.withAlphaComponent(0.15)),
                    .roundedRect(CGRect(x: 110, y: 110, width: 80, height: 50), 6, UIColor.white.withAlphaComponent(0.15)),
                    .roundedRect(CGRect(x: 200, y: 110, width: 80, height: 50), 6, UIColor.white.withAlphaComponent(0.15)),
                ]

                steps.append("3. 调用 renderAsync() 触发后台绘制")
                layerStatus = "后台渲染中..."

                let commands = layer.drawCommands
                let size = layer.bounds.size
                let scale = layer.contentsScale

                AsyncRenderScheduler.shared.performRender {
                    AsyncDrawEngine.render(commands: commands, size: size, scale: scale)
                } completion: { [self] image in
                    steps.append("4. 后台绘制完成，回调主线程")
                    steps.append("5. 设置 layer.contents = CGImage")

                    if let cgImage = image {
                        layer.asyncRenderedImage = cgImage
                        layer.contents = cgImage
                        renderedImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
                        layerStatus = "渲染完成 ✓"
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Text(layerStatus)
                .font(.caption)
                .foregroundColor(layerStatus.contains("✓") ? .green : .secondary)

            if let image = renderedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }

            Button("invalidateRender 重新绘制") {
                steps.removeAll()
                renderedImage = nil
                layerStatus = "已失效，等待重新绘制"
                steps.append("调用 invalidateRender() → asyncRenderedImage = nil")
            }
            .buttonStyle(.bordered)
            .disabled(renderedImage == nil)

            Spacer()
        }
        .padding()
        .navigationTitle("自定义绘制")
    }
}

struct AsyncTextDrawDemo: View {
    @State private var renderedImage: UIImage?
    @State private var duration: String = ""

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "文本异步绘制", description: "使用 CoreText 在后台线程进行文本排版和绘制，避免 UILabel 在主线程的排版开销。")

            Button("异步绘制多段文本") {
                let start = CACurrentMediaTime()
                var commands: [AsyncDrawCommand] = [
                    .roundedRect(CGRect(x: 0, y: 0, width: 320, height: 280), 0, .systemBackground)
                ]

                let paragraphs = [
                    ("Panda异步渲染引擎", UIFont.boldSystemFont(ofSize: 20), UIColor.label),
                    ("高性能文本排版方案，基于CoreText实现后台线程文本绘制。", UIFont.systemFont(ofSize: 15), UIColor.secondaryLabel),
                    ("支持富文本属性：粗体、颜色、字间距、行间距等。", UIFont.systemFont(ofSize: 15), UIColor.secondaryLabel),
                    ("多行文本自动换行计算，异步完成不阻塞主线程。", UIFont.systemFont(ofSize: 14), UIColor.tertiaryLabel),
                ]

                var y: CGFloat = 16
                for (text, font, color) in paragraphs {
                    let attrStr = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
                    commands.append(.text(attrStr, CGRect(x: 16, y: y, width: 288, height: font.lineHeight + 8)))
                    y += font.lineHeight + 16
                }

                AsyncRenderScheduler.shared.performRender {
                    AsyncDrawEngine.render(commands: commands, size: CGSize(width: 320, height: 280), scale: UIScreen.main.scale)
                } completion: { image in
                    duration = String(format: "%.2fms", (CACurrentMediaTime() - start) * 1000)
                    if let cgImage = image {
                        renderedImage = UIImage(cgImage: cgImage)
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if !duration.isEmpty {
                Text("文本绘制耗时: \(duration)").font(.caption).foregroundColor(.secondary)
            }

            if let image = renderedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 280)
                    .border(Color.gray.opacity(0.3))
            }

            Spacer()
        }
        .padding()
        .navigationTitle("文本绘制")
    }
}

struct AsyncImageDecodeDemo: View {
    @State private var decodedImage: UIImage?
    @State private var decodeTime: String = ""
    @State private var isDecoding = false

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "图片异步解码", description: "图片解码(解压缩)在后台线程完成，避免首次显示时在主线程触发解码导致卡顿。")

            Button("生成并异步解码图片") {
                isDecoding = true
                let size = CGSize(width: 400, height: 400)
                let renderer = UIGraphicsImageRenderer(size: size)
                let image = renderer.image { ctx in
                    for i in 0..<20 {
                        for j in 0..<20 {
                            let color = UIColor(
                                hue: CGFloat(i * 20 + j) / 400.0,
                                saturation: 0.8,
                                brightness: 0.9,
                                alpha: 1.0
                            )
                            color.setFill()
                            ctx.fill(CGRect(x: i * 20, y: j * 20, width: 20, height: 20))
                        }
                    }
                }

                let start = CACurrentMediaTime()
                AsyncImageDecoder.decode(image: image) { decoded in
                    decodeTime = String(format: "%.2fms", (CACurrentMediaTime() - start) * 1000)
                    decodedImage = decoded
                    isDecoding = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isDecoding)

            if isDecoding {
                ProgressView("解码中...")
            }

            if !decodeTime.isEmpty {
                Text("解码耗时: \(decodeTime)").font(.caption).foregroundColor(.secondary)
            }

            if let image = decodedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("图片解码")
    }
}

struct CompositeLayerDemo: View {
    @State private var composedImage: UIImage?
    @State private var duration: String = ""

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "复合图层合并", description: "将多个图层内容合并为一张位图，减少 GPU 图层混合的开销。")

            Button("合并3个图层") {
                let start = CACurrentMediaTime()
                let size = CGSize(width: 300, height: 200)
                let scale = UIScreen.main.scale

                let colors: [UIColor] = [.systemRed, .systemGreen, .systemBlue]
                var layerContents: [CompositeLayerRenderer.LayerContent] = []

                let group = DispatchGroup()
                for (i, color) in colors.enumerated() {
                    group.enter()
                    let commands: [AsyncDrawCommand] = [
                        .roundedRect(CGRect(x: 0, y: 0, width: 200, height: 120), 12, color)
                    ]
                    AsyncRenderScheduler.shared.performRender {
                        AsyncDrawEngine.render(commands: commands, size: CGSize(width: 200, height: 120), scale: scale)
                    } completion: { image in
                        let offset = CGFloat(i) * 40
                        layerContents.append(CompositeLayerRenderer.LayerContent(
                            image: image,
                            frame: CGRect(x: offset, y: offset, width: 200, height: 120),
                            opacity: 0.7
                        ))
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    CompositeLayerRenderer.composeLayers(layerContents, size: size, scale: scale) { composed in
                        duration = String(format: "%.2fms", (CACurrentMediaTime() - start) * 1000)
                        if let cgImage = composed {
                            composedImage = UIImage(cgImage: cgImage)
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if !duration.isEmpty {
                Text("合成耗时: \(duration)").font(.caption).foregroundColor(.secondary)
            }

            if let image = composedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("图层合并")
    }
}

// MARK: - Scroll Optimization Demos

struct ScrollPriorityDemo: View {
    @State private var executedTasks: [String] = []
    @State private var skippedTasks: [String] = []
    @State private var scrollState: ScrollState = .idle
    @State private var pendingCount: Int = 0
    @State private var manager = ScrollPriorityManager()

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "滑动优先级调整", description: "根据滚动状态动态筛选任务：空闲时执行所有任务；拖动时仅执行关键任务；减速时执行关键+高优任务。")

            HStack {
                stateIndicator("空闲", isActive: scrollState == .idle, color: .green)
                stateIndicator("拖动", isActive: scrollState == .dragging, color: .orange)
                stateIndicator("减速", isActive: scrollState == .decelerating, color: .yellow)
            }

            Text("待处理任务: \(pendingCount)")
                .font(.caption)
                .foregroundColor(.secondary)

            Button("1. 提交任务到队列") {
                manager = ScrollPriorityManager()
                manager.autoProcess = false
                executedTasks.removeAll()
                skippedTasks.removeAll()

                manager.enqueue(priority: .critical, name: "当前可见Cell绘制") { [self] in
                    executedTasks.append("[关键] 当前可见Cell绘制 ✓")
                }
                manager.enqueue(priority: .high, name: "即将可见Cell准备") { [self] in
                    executedTasks.append("[高优] 即将可见Cell准备 ✓")
                }
                manager.enqueue(priority: .normal, name: "图片解码") { [self] in
                    executedTasks.append("[普通] 图片解码 ✓")
                }
                manager.enqueue(priority: .low, name: "预加载远处内容") { [self] in
                    executedTasks.append("[低优] 预加载远处内容 ✓")
                }

                pendingCount = manager.pendingCount
            }
            .buttonStyle(.borderedProminent)

            HStack(spacing: 12) {
                Button("空闲") { scrollState = .idle }.buttonStyle(.bordered)
                Button("拖动") { scrollState = .dragging }.buttonStyle(.bordered)
                Button("减速") { scrollState = .decelerating }.buttonStyle(.bordered)
            }

            Button("2. 按当前状态筛选执行") {
                executedTasks.removeAll()
                skippedTasks = manager.processForScrollState(scrollState)
                pendingCount = manager.pendingCount
            }
            .buttonStyle(.borderedProminent)
            .disabled(pendingCount == 0)

            if !executedTasks.isEmpty || !skippedTasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    if !executedTasks.isEmpty {
                        Text("已执行:").font(.caption.bold()).foregroundColor(.green)
                        ForEach(executedTasks, id: \.self) { task in
                            Text(task).font(.caption).foregroundColor(.primary)
                        }
                    }
                    if !skippedTasks.isEmpty {
                        Text("被跳过(优先级不够):").font(.caption.bold()).foregroundColor(.red)
                        ForEach(skippedTasks, id: \.self) { task in
                            Text(task).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("优先级调整")
    }

    func stateIndicator(_ title: String, isActive: Bool, color: Color) -> some View {
        VStack {
            Circle().fill(isActive ? color : Color.gray.opacity(0.3)).frame(width: 16, height: 16)
            Text(title).font(.caption2)
        }
    }
}

struct PreloadAreaDemo: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var items: [PreloadItem] = []

    struct PreloadItem: Identifiable {
        let id: Int
        let frame: CGRect
        var shouldPreload: Bool
        var isVisible: Bool
    }

    var body: some View {
        VStack(spacing: 12) {
            infoCard(title: "预加载区域计算", description: "根据滚动方向和速度智能计算预加载区域，提前准备即将出现的内容。")

            VStack(alignment: .leading) {
                Text("滚动偏移: \(Int(scrollOffset))").font(.caption)
                Slider(value: $scrollOffset, in: 0...2000)
                Text("滚动速度: \(Int(velocity))").font(.caption)
                Slider(value: $velocity, in: -2000...2000)
            }

            Button("计算预加载区域") {
                let calculator = PreloadAreaCalculator()
                items = (0..<30).map { i in
                    let frame = CGRect(x: 0, y: CGFloat(i) * 80, width: 320, height: 70)
                    let shouldPreload = calculator.shouldPreload(itemFrame: frame, scrollOffset: scrollOffset, velocity: velocity)
                    let visibleRange = calculator.visibleRange(offset: scrollOffset)
                    let isVisible = frame.maxY >= visibleRange.lowerBound && frame.minY <= visibleRange.upperBound
                    return PreloadItem(id: i, frame: frame, shouldPreload: shouldPreload, isVisible: isVisible)
                }
            }
            .buttonStyle(.borderedProminent)

            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(items) { item in
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(item.isVisible ? Color.green : (item.shouldPreload ? Color.orange : Color.gray))
                                .frame(width: 8, height: 30)
                            Text("Item \(item.id)")
                                .font(.caption)
                            Spacer()
                            Text(item.isVisible ? "可见" : (item.shouldPreload ? "预加载" : "忽略"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("预加载区域")
    }
}

struct RunLoopIdleDemo: View {
    @State private var completedTasks: [String] = []
    @State private var taskCount = 0

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "RunLoop空闲执行", description: "利用 RunLoop 的 BeforeWaiting 回调，在主线程空闲时执行低优先级任务，不影响交互流畅度。")

            Text("已完成任务: \(completedTasks.count)")
                .font(.headline)

            Button("添加10个空闲任务") {
                for i in 0..<10 {
                    let taskId = taskCount + i
                    RunLoopIdleExecutor.shared.addTask { [self] in
                        completedTasks.append("任务 #\(taskId) 在RunLoop空闲时完成")
                    }
                }
                taskCount += 10
            }
            .buttonStyle(.borderedProminent)

            Button("清空记录") {
                completedTasks.removeAll()
            }
            .foregroundColor(.red)

            List {
                ForEach(completedTasks.suffix(15), id: \.self) { task in
                    Text(task).font(.caption).foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("RunLoop空闲")
    }
}

struct ScrollPauseDemo: View {
    @State private var scrollState: ScrollState = .idle
    @State private var pausedTasks: Int = 0
    @State private var completedTasks: Int = 0
    @State private var logs: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "滑动暂停渲染", description: "检测到快速滑动时暂停非必要的渲染任务，停止滑动后自动恢复执行。")

            HStack(spacing: 24) {
                VStack {
                    Image(systemName: scrollState == .idle ? "hand.raised.fill" : "hand.raised.slash.fill")
                        .font(.title)
                        .foregroundColor(scrollState == .idle ? .green : .red)
                    Text(scrollState == .idle ? "渲染中" : "已暂停")
                        .font(.caption)
                }
                VStack {
                    Text("\(pausedTasks)").font(.title2).foregroundColor(.orange)
                    Text("等待中").font(.caption)
                }
                VStack {
                    Text("\(completedTasks)").font(.title2).foregroundColor(.green)
                    Text("已完成").font(.caption)
                }
            }

            HStack(spacing: 12) {
                Button("模拟滑动开始") {
                    scrollState = .dragging
                    AsyncRenderScheduler.shared.pause()
                    logs.insert("滑动开始 → 暂停渲染", at: 0)
                }
                .buttonStyle(.bordered)

                Button("模拟滑动结束") {
                    scrollState = .idle
                    AsyncRenderScheduler.shared.resume()
                    logs.insert("滑动结束 → 恢复渲染", at: 0)
                }
                .buttonStyle(.bordered)
            }

            Button("提交渲染任务") {
                pausedTasks += 1
                AsyncRenderScheduler.shared.performRender {
                    Thread.sleep(forTimeInterval: 0.02)
                    return nil
                } completion: { _ in
                    pausedTasks -= 1
                    completedTasks += 1
                    logs.insert("渲染任务完成", at: 0)
                }
            }
            .buttonStyle(.borderedProminent)

            List {
                ForEach(logs.prefix(10), id: \.self) { log in
                    Text(log).font(.caption).foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("滑动暂停")
    }
}

// MARK: - Monitor Demos

struct RenderTimingDemo: View {
    @StateObject private var monitor = AsyncRenderMonitor.shared

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "渲染耗时监控", description: "精确测量每个渲染任务的执行时间，识别性能瓶颈。")

            Button("执行带监控的渲染") {
                monitor.measureAsync(name: "文本绘制") { done in
                    AsyncRenderScheduler.shared.performRender {
                        Thread.sleep(forTimeInterval: Double.random(in: 0.005...0.025))
                        return nil
                    } completion: { _ in done() }
                }

                monitor.measureAsync(name: "图片解码") { done in
                    AsyncRenderScheduler.shared.performImageProcess {
                        Thread.sleep(forTimeInterval: Double.random(in: 0.01...0.05))
                        return nil
                    } completion: { _ in done() }
                }

                monitor.measureAsync(name: "布局计算") { done in
                    AsyncRenderScheduler.shared.performLayout {
                        Thread.sleep(forTimeInterval: Double.random(in: 0.002...0.015))
                    } completion: { done() }
                }
            }
            .buttonStyle(.borderedProminent)

            List {
                ForEach(monitor.renderLogs.prefix(15)) { log in
                    HStack {
                        Circle()
                            .fill(log.isWarning ? Color.red : Color.green)
                            .frame(width: 8, height: 8)
                        Text(log.taskName)
                            .font(.caption)
                        Spacer()
                        Text(log.formattedDuration)
                            .font(.caption.monospacedDigit())
                            .foregroundColor(log.isWarning ? .red : .secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("耗时监控")
    }
}

struct FPSMonitorDemo: View {
    @StateObject private var monitor = AsyncRenderMonitor.shared
    @State private var fpsHistory: [Int] = []
    @State private var isStressing = false

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "帧率实时显示", description: "通过 CADisplayLink 实时计算帧率，识别掉帧情况。")

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black)
                    .frame(height: 80)
                VStack {
                    Text("\(monitor.currentFPS)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(monitor.currentFPS >= 55 ? .green : (monitor.currentFPS >= 30 ? .yellow : .red))
                    Text("FPS")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            HStack(spacing: 12) {
                Button(monitor.isMonitoring ? "停止监控" : "开始监控") {
                    if monitor.isMonitoring {
                        monitor.stopMonitoring()
                    } else {
                        monitor.startMonitoring()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("模拟卡顿") {
                    isStressing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        Thread.sleep(forTimeInterval: 0.1)
                        isStressing = false
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isStressing)
            }

            if !fpsHistory.isEmpty {
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(fpsHistory.suffix(30), id: \.self) { fps in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(fps >= 55 ? Color.green : (fps >= 30 ? Color.yellow : Color.red))
                            .frame(width: 8, height: CGFloat(fps))
                    }
                }
                .frame(height: 60)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("帧率监控")
        .onAppear { monitor.startMonitoring() }
        .onDisappear { monitor.stopMonitoring() }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if monitor.isMonitoring {
                fpsHistory.append(monitor.currentFPS)
                if fpsHistory.count > 30 { fpsHistory.removeFirst() }
            }
        }
    }
}

struct RenderLogDemo: View {
    @StateObject private var monitor = AsyncRenderMonitor.shared

    var body: some View {
        VStack(spacing: 16) {
            infoCard(title: "耗时任务日志", description: "记录所有渲染任务的详细日志，包含任务名、耗时和执行线程。超过16ms的任务标红告警。")

            HStack {
                Button("生成测试任务") {
                    let tasks = ["Cell布局", "头像解码", "文本排版", "列表Diff", "图层合成"]
                    for name in tasks {
                        monitor.measureAsync(name: name) { done in
                            DispatchQueue.global().async {
                                Thread.sleep(forTimeInterval: Double.random(in: 0.003...0.03))
                                DispatchQueue.main.async { done() }
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("清空") {
                    monitor.clearLogs()
                }
                .foregroundColor(.red)
            }

            List {
                ForEach(monitor.renderLogs) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: log.isWarning ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .foregroundColor(log.isWarning ? .red : .green)
                                .font(.caption)
                            Text(log.taskName)
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text(log.formattedDuration)
                                .font(.caption.monospacedDigit())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(log.isWarning ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                        Text("线程: \(log.thread)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("任务日志")
    }
}

// MARK: - Helper

private func infoCard(title: String, description: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title).font(.headline)
        Text(description).font(.caption).foregroundColor(.secondary)
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.blue.opacity(0.05))
    .cornerRadius(10)
}

#Preview {
    NavigationStack {
        AsyncRenderDemoView()
    }
}
