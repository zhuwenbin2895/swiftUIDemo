import SwiftUI
import Combine

struct KolodaDemoView: View {
    var body: some View {
        List {
            Section("核心机制") {
                NavigationLink("卡片堆栈管理") {
                    KolodaStackDemoPage()
                }
                NavigationLink("无限卡片加载") {
                    KolodaInfiniteDemoPage()
                }
                NavigationLink("空状态回调") {
                    KolodaEmptyStateDemoPage()
                }
            }
            Section("滑动交互") {
                NavigationLink("四方向滑动") {
                    KolodaSwipeDirectionDemoPage()
                }
                NavigationLink("拖拽旋转") {
                    KolodaDragRotationDemoPage()
                }
                NavigationLink("速度/距离判断") {
                    KolodaVelocityDemoPage()
                }
            }
            Section("卡片动画") {
                NavigationLink("抖动提示") {
                    KolodaShakeDemoPage()
                }
                NavigationLink("飞出/淡入动画") {
                    KolodaAnimationDemoPage()
                }
                NavigationLink("插入/删除动画") {
                    KolodaInsertDeleteDemoPage()
                }
            }
            Section("自定义样式") {
                NavigationLink("样式配置") {
                    KolodaStyleConfigDemoPage()
                }
            }
            Section("代理回调") {
                NavigationLink("回调事件监听") {
                    KolodaCallbackDemoPage()
                }
            }
            Section("手势联动") {
                NavigationLink("拖拽禁止底层滚动") {
                    KolodaGestureLinkDemoPage()
                }
                NavigationLink("自定义飞出终点") {
                    KolodaFlyOutDestinationDemoPage()
                }
            }
        }
        .navigationTitle("KolodaCards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 卡片堆栈管理

struct KolodaStackDemoPage: View {
    @StateObject private var manager = KolodaManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("卡片堆栈管理")
                .font(.headline)
            Text("显示多张卡片堆叠，支持索引动态更新")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            HStack(spacing: 16) {
                Text("当前索引: \(manager.currentIndex)")
                    .font(.subheadline.monospacedDigit())
                Text("总数: \(manager.cardItems.count)")
                    .font(.subheadline.monospacedDigit())
            }
            .padding(.top, 8)

            HStack(spacing: 20) {
                Button("← 左滑") { manager.swipeProgrammatically(direction: .left) }
                    .buttonStyle(.bordered)
                Button("右滑 →") { manager.swipeProgrammatically(direction: .right) }
                    .buttonStyle(.bordered)
            }

            Button("重置") { manager.reset() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("卡片堆栈")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
    }
}

// MARK: - 无限卡片加载

struct KolodaInfiniteDemoPage: View {
    @StateObject private var manager = KolodaManager()
    @State private var loadedBatch = 1

    var body: some View {
        VStack(spacing: 20) {
            Text("无限卡片加载")
                .font(.headline)
            Text("当卡片即将用完时自动加载更多")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            Text("已加载 \(manager.cardItems.count) 张 · 第 \(loadedBatch) 批")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                Button("← 左滑") { swipeAndCheck(.left) }
                    .buttonStyle(.bordered)
                Button("右滑 →") { swipeAndCheck(.right) }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("无限加载")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.generateBatch(batch: 1)) }
    }

    private func swipeAndCheck(_ direction: KolodaSwipeDirection) {
        manager.swipeProgrammatically(direction: direction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if manager.currentIndex >= manager.cardItems.count - 2 {
                loadedBatch += 1
                let newCards = SampleData.generateBatch(batch: loadedBatch)
                for card in newCards {
                    manager.insertCard(card, at: manager.cardItems.count)
                }
            }
        }
    }
}

// MARK: - 空状态回调

struct KolodaEmptyStateDemoPage: View {
    @StateObject private var manager = KolodaManager()
    @State private var showEmptyAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("空状态回调")
                .font(.headline)
            Text("卡片全部滑完后显示空状态")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager) {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)
                    Text("全部浏览完毕!")
                        .font(.headline)
                    Button("重新开始") { manager.reset() }
                        .buttonStyle(.borderedProminent)
                }
            }

            HStack(spacing: 20) {
                Button("← 左滑") { manager.swipeProgrammatically(direction: .left) }
                    .buttonStyle(.bordered)
                Button("右滑 →") { manager.swipeProgrammatically(direction: .right) }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("空状态")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(Array(SampleData.basicCards.prefix(3))) }
        .onChange(of: manager.isEmpty) { _, newValue in
            if newValue { showEmptyAlert = true }
        }
        .alert("卡片已全部浏览", isPresented: $showEmptyAlert) {
            Button("确定") {}
        }
    }
}

// MARK: - 四方向滑动

struct KolodaSwipeDirectionDemoPage: View {
    @StateObject private var manager = KolodaManager()
    @State private var lastDirection: KolodaSwipeDirection?
    @State private var swipeLog: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("四方向滑动")
                .font(.headline)
            Text("支持上下左右四个方向滑动")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            if let dir = lastDirection {
                Label("最近滑动: \(dir.rawValue)", systemImage: directionIcon(dir))
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .transition(.scale.combined(with: .opacity))
            }

            HStack(spacing: 12) {
                Button("←") { swipe(.left) }.buttonStyle(.bordered)
                VStack(spacing: 8) {
                    Button("↑") { swipe(.up) }.buttonStyle(.bordered)
                    Button("↓") { swipe(.down) }.buttonStyle(.bordered)
                }
                Button("→") { swipe(.right) }.buttonStyle(.bordered)
            }

            if !swipeLog.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(swipeLog.suffix(10), id: \.self) { log in
                            Text(log)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1), in: Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .navigationTitle("四方向滑动")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
    }

    private func swipe(_ direction: KolodaSwipeDirection) {
        manager.swipeProgrammatically(direction: direction)
        withAnimation { lastDirection = direction }
        swipeLog.append(direction.rawValue)
    }

    private func directionIcon(_ dir: KolodaSwipeDirection) -> String {
        switch dir {
        case .left: return "arrow.left.circle.fill"
        case .right: return "arrow.right.circle.fill"
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        }
    }
}

// MARK: - 拖拽旋转

struct KolodaDragRotationDemoPage: View {
    @StateObject private var manager: KolodaManager = {
        var config = KolodaConfig()
        config.maxRotationAngle = 25
        return KolodaManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("拖拽旋转")
                .font(.headline)
            Text("拖拽卡片时跟随手指旋转")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            VStack(spacing: 4) {
                Text("偏移: (\(Int(manager.dragState.offset.width)), \(Int(manager.dragState.offset.height)))")
                Text("旋转角度上限: \(Int(manager.config.maxRotationAngle))°")
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)

            Button("重置") { manager.reset() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("拖拽旋转")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
    }
}

// MARK: - 速度/距离判断

struct KolodaVelocityDemoPage: View {
    @StateObject private var manager: KolodaManager = {
        var config = KolodaConfig()
        config.swipeThreshold = 120
        config.velocityThreshold = 600
        return KolodaManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("速度/距离判断")
                .font(.headline)
            Text("松手后根据速度和距离判断是否完成滑动")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            VStack(alignment: .leading, spacing: 6) {
                Label("距离阈值: \(Int(manager.config.swipeThreshold))pt", systemImage: "ruler")
                Label("速度阈值: \(Int(manager.config.velocityThreshold))pt/s", systemImage: "speedometer")
                Label("未达阈值将自动回正", systemImage: "info.circle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Button("重置") { manager.reset() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("速度/距离判断")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
    }
}

// MARK: - 抖动提示

struct KolodaShakeDemoPage: View {
    @StateObject private var manager: KolodaManager = {
        var config = KolodaConfig()
        config.swipeThreshold = 80
        return KolodaManager(config: config)
    }()
    @State private var shakeCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("抖动提示")
                .font(.headline)
            Text("拖拽超过阈值时卡片抖动+震动反馈")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            Text("触发抖动次数: \(shakeCount)")
                .font(.subheadline.monospacedDigit())

            Text("拖拽距离超过 \(Int(manager.config.swipeThreshold))pt 触发")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("重置") {
                manager.reset()
                shakeCount = 0
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("抖动提示")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
        .onChange(of: manager.isShaking) { _, newValue in
            if newValue { shakeCount += 1 }
        }
    }
}

// MARK: - 飞出/淡入动画

struct KolodaAnimationDemoPage: View {
    @StateObject private var manager = KolodaManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("飞出/淡入动画")
                .font(.headline)
            Text("卡片移除时渐隐飞出，下一张从底部淡入")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            HStack(spacing: 20) {
                Button("← 飞出左") { manager.swipeProgrammatically(direction: .left) }
                    .buttonStyle(.bordered)
                Button("↑ 飞出上") { manager.swipeProgrammatically(direction: .up) }
                    .buttonStyle(.bordered)
                Button("飞出右 →") { manager.swipeProgrammatically(direction: .right) }
                    .buttonStyle(.bordered)
            }

            Button("回退") { manager.rewind() }
                .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("飞出/淡入")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
    }
}

// MARK: - 插入/删除动画

struct KolodaInsertDeleteDemoPage: View {
    @StateObject private var manager = KolodaManager()
    @State private var insertCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("插入/删除动画")
                .font(.headline)
            Text("动态插入和删除卡片带动画效果")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            Text("总数: \(manager.cardItems.count) · 当前: \(manager.currentIndex)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("插入卡片") {
                    insertCount += 1
                    let newCard = KolodaCardItem(
                        id: "insert_\(insertCount)",
                        title: "新卡片 #\(insertCount)",
                        subtitle: "动态插入",
                        color: [.purple, .pink, .cyan, .mint].randomElement()!,
                        imageName: "plus.circle.fill"
                    )
                    manager.insertCard(newCard, at: manager.currentIndex + 1)
                }
                .buttonStyle(.bordered)

                Button("删除当前") {
                    manager.removeCard(at: manager.currentIndex)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }

            Button("重置") { manager.reset() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("插入/删除")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
    }
}

// MARK: - 样式配置

struct KolodaStyleConfigDemoPage: View {
    @State private var cardWidth: CGFloat = 300
    @State private var cardHeight: CGFloat = 400
    @State private var cornerRadius: CGFloat = 16
    @State private var visibleCount: Double = 3
    @State private var spacing: CGFloat = 10
    @StateObject private var manager = KolodaManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("样式配置")
                    .font(.headline)

                KolodaStackView(manager: manager)
                    .padding(.vertical, 10)

                GroupBox("卡片尺寸") {
                    VStack(spacing: 8) {
                        HStack {
                            Text("宽度: \(Int(cardWidth))")
                            Slider(value: $cardWidth, in: 200...350)
                        }
                        HStack {
                            Text("高度: \(Int(cardHeight))")
                            Slider(value: $cardHeight, in: 250...500)
                        }
                    }
                    .font(.caption)
                }

                GroupBox("圆角与间距") {
                    VStack(spacing: 8) {
                        HStack {
                            Text("圆角: \(Int(cornerRadius))")
                            Slider(value: $cornerRadius, in: 0...40)
                        }
                        HStack {
                            Text("间距: \(Int(spacing))")
                            Slider(value: $spacing, in: 0...30)
                        }
                    }
                    .font(.caption)
                }

                GroupBox("显示数量") {
                    HStack {
                        Text("可见卡片: \(Int(visibleCount))")
                        Slider(value: $visibleCount, in: 1...5, step: 1)
                    }
                    .font(.caption)
                }

                Button("应用配置") { applyConfig() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("样式配置")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            applyConfig()
            manager.loadCards(SampleData.basicCards)
        }
    }

    private func applyConfig() {
        manager.config.cardSize = CGSize(width: cardWidth, height: cardHeight)
        manager.config.cornerRadius = cornerRadius
        manager.config.cardSpacing = spacing
        manager.config.visibleCardCount = Int(visibleCount)
        manager.objectWillChange.send()
    }
}

// MARK: - 回调事件监听

struct KolodaCallbackDemoPage: View {
    @StateObject private var manager = KolodaManager()
    @StateObject private var callbackHandler = CallbackHandler()

    var body: some View {
        VStack(spacing: 16) {
            Text("回调事件监听")
                .font(.headline)
            Text("拖拽和滑动时查看回调事件日志")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            HStack(spacing: 20) {
                Button("← 左滑") { manager.swipeProgrammatically(direction: .left) }
                    .buttonStyle(.bordered)
                Button("右滑 →") { manager.swipeProgrammatically(direction: .right) }
                    .buttonStyle(.bordered)
            }

            GroupBox("事件日志") {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(callbackHandler.logs.suffix(15), id: \.self) { log in
                            Text(log)
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.primary.opacity(0.8))
                        }
                    }
                }
                .frame(height: 120)
            }
        }
        .padding()
        .navigationTitle("回调事件")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.loadCards(SampleData.basicCards)
            manager.delegate = callbackHandler
        }
    }
}

class CallbackHandler: ObservableObject, KolodaDelegate {
    @Published var logs: [String] = []

    func kolodaDidSwipeStart(index: Int) {
        logs.append("⏳ 开始滑动 #\(index)")
    }

    func kolodaDidSwipe(index: Int, direction: KolodaSwipeDirection) {
        logs.append("✅ 滑动完成 #\(index) → \(direction.rawValue)")
    }

    func kolodaDragProgress(index: Int, offset: CGSize, progress: CGFloat) {
        if Int(progress) % 20 == 0 {
            logs.append("📍 拖拽中 offset:(\(Int(offset.width)),\(Int(offset.height)))")
        }
    }

    func kolodaDidTap(index: Int) {
        logs.append("👆 点击卡片 #\(index)")
    }

    func kolodaDidRunOutOfCards() {
        logs.append("🏁 卡片已全部浏览完")
    }
}

// MARK: - 手势联动

struct KolodaGestureLinkDemoPage: View {
    @StateObject private var manager = KolodaManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("手势联动")
                    .font(.headline)
                Text("拖拽卡片时禁止底层ScrollView滚动")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                KolodaStackView(manager: manager)

                Text("正在拖拽: \(manager.isDraggingCard ? "是" : "否")")
                    .font(.caption)
                    .foregroundStyle(manager.isDraggingCard ? .red : .secondary)

                ForEach(0..<10, id: \.self) { i in
                    HStack {
                        Image(systemName: "doc.text")
                        Text("列表项 #\(i + 1)")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
        }
        .scrollDisabled(manager.isDraggingCard)
        .navigationTitle("手势联动")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
    }
}

// MARK: - 自定义飞出终点

struct KolodaFlyOutDestinationDemoPage: View {
    @StateObject private var manager: KolodaManager = {
        var config = KolodaConfig()
        config.customFlyOutDestination = { direction in
            switch direction {
            case .left: return CGSize(width: -250, height: 150)
            case .right: return CGSize(width: 250, height: -100)
            case .up: return CGSize(width: 50, height: -300)
            case .down: return CGSize(width: -50, height: 300)
            }
        }
        return KolodaManager(config: config)
    }()

    @State private var targetX: CGFloat = 300
    @State private var targetY: CGFloat = -200

    var body: some View {
        VStack(spacing: 16) {
            Text("自定义飞出终点")
                .font(.headline)
            Text("指定卡片飞向特定坐标位置")
                .font(.caption)
                .foregroundStyle(.secondary)

            KolodaStackView(manager: manager)

            GroupBox("自定义终点坐标") {
                VStack(spacing: 8) {
                    HStack {
                        Text("X: \(Int(targetX))")
                            .frame(width: 60, alignment: .leading)
                        Slider(value: $targetX, in: -400...400)
                    }
                    HStack {
                        Text("Y: \(Int(targetY))")
                            .frame(width: 60, alignment: .leading)
                        Slider(value: $targetY, in: -400...400)
                    }
                }
                .font(.caption)
            }

            HStack(spacing: 12) {
                Button("飞向指定位置") {
                    manager.swipeToDestination(CGSize(width: targetX, height: targetY))
                }
                .buttonStyle(.borderedProminent)

                Button("使用方向预设") {
                    manager.swipeProgrammatically(direction: .left)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                Button("回退") { manager.rewind() }
                    .buttonStyle(.bordered)
                Button("重置") { manager.reset() }
                    .buttonStyle(.bordered)
            }

            Text("方向预设使用 customFlyOutDestination 闭包")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("自定义飞出终点")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadCards(SampleData.basicCards) }
    }
}

// MARK: - Sample Data

enum SampleData {
    static var basicCards: [KolodaCardItem] {
        [
            KolodaCardItem(id: "1", title: "探索世界", subtitle: "开始你的旅程", color: .blue, imageName: "globe"),
            KolodaCardItem(id: "2", title: "音乐律动", subtitle: "感受节奏的力量", color: .purple, imageName: "music.note"),
            KolodaCardItem(id: "3", title: "星辰大海", subtitle: "仰望星空", color: .indigo, imageName: "star.fill"),
            KolodaCardItem(id: "4", title: "自然之美", subtitle: "拥抱大自然", color: .green, imageName: "leaf.fill"),
            KolodaCardItem(id: "5", title: "知识海洋", subtitle: "永不停歇的学习", color: .orange, imageName: "book.fill"),
            KolodaCardItem(id: "6", title: "创意无限", subtitle: "释放你的想象力", color: .pink, imageName: "paintbrush.fill"),
            KolodaCardItem(id: "7", title: "运动健康", subtitle: "活力每一天", color: .red, imageName: "figure.run"),
            KolodaCardItem(id: "8", title: "科技前沿", subtitle: "探索未来技术", color: .cyan, imageName: "cpu"),
        ]
    }

    static func generateBatch(batch: Int) -> [KolodaCardItem] {
        let colors: [Color] = [.blue, .purple, .green, .orange, .pink, .red, .cyan, .indigo]
        let icons = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "drop.fill"]
        return (0..<5).map { i in
            let index = (batch - 1) * 5 + i
            return KolodaCardItem(
                id: "batch\(batch)_\(i)",
                title: "卡片 #\(index + 1)",
                subtitle: "第 \(batch) 批加载",
                color: colors[index % colors.count],
                imageName: icons[i % icons.count]
            )
        }
    }
}
