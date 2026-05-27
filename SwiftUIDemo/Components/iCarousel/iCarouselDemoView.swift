import SwiftUI
import Combine

struct iCarouselDemoView: View {
    var body: some View {
        List {
            Section("3D 效果类型") {
                NavigationLink("线性排列") {
                    LinearCarouselDemoPage()
                }
                NavigationLink("圆形环绕") {
                    CylindricalCarouselDemoPage()
                }
                NavigationLink("覆盖流") {
                    CoverFlowCarouselDemoPage()
                }
                NavigationLink("时间线轮播") {
                    TimeMachineCarouselDemoPage()
                }
                NavigationLink("旋转木马") {
                    RotaryCarouselDemoPage()
                }
                NavigationLink("倒转覆盖流") {
                    InvertedCoverFlowDemoPage()
                }
                NavigationLink("自定义变换矩阵") {
                    CustomTransformDemoPage()
                }
            }
            Section("基础滑动") {
                NavigationLink("无限循环滚动") {
                    InfiniteScrollDemoPage()
                }
                NavigationLink("自动轮播") {
                    AutoScrollDemoPage()
                }
                NavigationLink("滑动惯性阻尼") {
                    DampingDemoPage()
                }
            }
            Section("内容管理") {
                NavigationLink("动态添加删除卡片") {
                    DynamicContentDemoPage()
                }
                NavigationLink("异步加载远程图片") {
                    AsyncImageDemoPage()
                }
            }
            Section("视图复用") {
                NavigationLink("视图复用与预加载") {
                    ReusePoolDemoPage()
                }
            }
            Section("交互控制") {
                NavigationLink("点击卡片回调") {
                    TapCallbackDemoPage()
                }
                NavigationLink("滑动到指定索引") {
                    ScrollToIndexDemoPage()
                }
                NavigationLink("禁用用户滑动") {
                    DisableScrollDemoPage()
                }
            }
            Section("自定义变换") {
                NavigationLink("透视投影深度") {
                    PerspectiveDemoPage()
                }
                NavigationLink("卡片间距配置") {
                    SpacingDemoPage()
                }
                NavigationLink("视差滚动效果") {
                    ParallaxDemoPage()
                }
            }
        }
        .navigationTitle("iCarousel")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 线性排列

struct LinearCarouselDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .linear
        config.itemSpacing = 180
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("线性排列")
                .font(.headline)
            Text("卡片沿水平方向线性排列，中心卡片突出显示")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)
        }
        .padding()
        .navigationTitle("线性排列")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 圆形环绕

struct CylindricalCarouselDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .cylindrical
        config.itemSpacing = 200
        config.visibleItems = 9
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("圆形环绕")
                .font(.headline)
            Text("卡片沿圆柱面排列，形成3D环绕效果")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)
        }
        .padding()
        .navigationTitle("圆形环绕")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 覆盖流

struct CoverFlowCarouselDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        config.itemSpacing = 200
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("覆盖流")
                .font(.headline)
            Text("模拟 iTunes Cover Flow 效果，侧边卡片带透视旋转")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)
        }
        .padding()
        .navigationTitle("覆盖流")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 时间线轮播

struct TimeMachineCarouselDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .timeMachine
        config.itemSpacing = 200
        config.tilt = 0.7
        config.itemSize = CGSize(width: 240, height: 160)
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("时间线轮播")
                .font(.headline)
            Text("卡片沿纵深方向排列，形成时间线效果（上下滑动）")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)
                .frame(height: 350)

            indexIndicator(manager: manager)
        }
        .padding()
        .navigationTitle("时间线轮播")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 旋转木马

struct RotaryCarouselDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .rotary
        config.itemSpacing = 200
        config.visibleItems = 9
        config.itemSize = CGSize(width: 160, height: 220)
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("旋转木马")
                .font(.headline)
            Text("卡片围绕中心旋转，带弧形轨迹效果")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)
        }
        .padding()
        .navigationTitle("旋转木马")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 倒转覆盖流

struct InvertedCoverFlowDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .invertedCoverFlow
        config.itemSpacing = 200
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("倒转覆盖流")
                .font(.headline)
            Text("覆盖流的镜像版本，旋转方向反转")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)
        }
        .padding()
        .navigationTitle("倒转覆盖流")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 自定义变换矩阵

struct CustomTransformDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .custom
        config.itemSpacing = 200
        config.customTransform = { offset, size in
            var t = iCarouselTransform()
            let absOffset = abs(offset)
            let sign: CGFloat = offset < 0 ? -1 : (offset > 0 ? 1 : 0)

            t.offset = CGSize(
                width: offset * 120,
                height: absOffset * 30
            )
            t.scale = max(0.6, 1.0 - absOffset * 0.15)
            t.rotation3D = (Double(offset * 15), (0, 0, 1))
            t.opacity = max(0.2, 1.0 - Double(absOffset) * 0.25)
            t.zIndex = -Double(absOffset)
            return t
        }
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("自定义变换矩阵")
                .font(.headline)
            Text("通过闭包自定义每张卡片的变换效果（扇形展开+旋转）")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)

            Text("自定义: 偏移=120*offset, 下沉=|offset|*30, 旋转=offset*15°")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("自定义变换")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 无限循环滚动

struct InfiniteScrollDemoPage: View {
    @StateObject private var infiniteManager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        config.isInfinite = true
        return iCarouselManager(config: config)
    }()
    @StateObject private var finiteManager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        config.isInfinite = false
        return iCarouselManager(config: config)
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                GroupBox("无限循环") {
                    VStack(spacing: 8) {
                        iCarouselView(manager: infiniteManager)
                        Text("当前索引: \(infiniteManager.currentIndex) · 偏移: \(String(format: "%.1f", infiniteManager.currentOffset))")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }

                GroupBox("有限滚动（到边界停止）") {
                    VStack(spacing: 8) {
                        iCarouselView(manager: finiteManager)
                        Text("当前索引: \(finiteManager.currentIndex) · 偏移: \(String(format: "%.1f", finiteManager.currentOffset))")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("无限循环")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            infiniteManager.loadItems(CarouselSampleData.items)
            finiteManager.loadItems(CarouselSampleData.items)
        }
    }
}

// MARK: - 自动轮播

struct AutoScrollDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        config.autoScrollEnabled = true
        config.autoScrollInterval = 2.5
        return iCarouselManager(config: config)
    }()
    @State private var interval: Double = 2.5
    @State private var isAutoPlaying: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            Text("自动轮播")
                .font(.headline)
            Text("手动滑动时暂停，松手后恢复")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)

            GroupBox("自动轮播设置") {
                VStack(spacing: 12) {
                    HStack {
                        Text("间隔: \(String(format: "%.1f", interval))s")
                        Slider(value: $interval, in: 0.5...5.0, step: 0.5)
                    }
                    .font(.caption)

                    Toggle("自动轮播", isOn: $isAutoPlaying)
                        .font(.caption)
                }
            }
            .onChange(of: interval) { _, newValue in
                manager.config.autoScrollInterval = newValue
                if isAutoPlaying {
                    manager.startAutoScrollIfNeeded()
                }
            }
            .onChange(of: isAutoPlaying) { _, newValue in
                manager.config.autoScrollEnabled = newValue
                if newValue {
                    manager.startAutoScrollIfNeeded()
                } else {
                    manager.stopAutoScroll()
                }
            }
        }
        .padding()
        .navigationTitle("自动轮播")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
        .onDisappear { manager.stopAutoScroll() }
    }
}

// MARK: - 滑动惯性阻尼

struct DampingDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .linear
        config.itemSpacing = 180
        config.decelerationRate = 0.92
        return iCarouselManager(config: config)
    }()
    @State private var damping: Double = 0.92

    var body: some View {
        VStack(spacing: 20) {
            Text("滑动惯性阻尼")
                .font(.headline)
            Text("快速滑动后松手，观察不同阻尼下的滑行距离")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            VStack(spacing: 4) {
                Text("当前索引: \(manager.currentIndex)")
                    .font(.caption.monospacedDigit())
                Text("偏移量: \(String(format: "%.2f", manager.currentOffset))")
                    .font(.caption.monospacedDigit())
                Text(manager.isDragging ? "状态: 拖拽中" : "状态: 静止/减速")
                    .font(.caption)
                    .foregroundStyle(manager.isDragging ? .orange : .green)
            }
            .foregroundStyle(.secondary)

            GroupBox("阻尼系数 (decelerationRate)") {
                VStack(spacing: 10) {
                    HStack {
                        Text("\(String(format: "%.2f", damping))")
                            .font(.body.monospacedDigit().bold())
                            .frame(width: 50)
                        Slider(value: $damping, in: 0.80...0.99, step: 0.01)
                    }

                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("← 0.80")
                                .font(.caption2)
                            Text("快速停止")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("0.99 →")
                                .font(.caption2)
                            Text("长距离滑行")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                        }
                    }

                    Text("每帧速度 = 上一帧速度 × \(String(format: "%.2f", damping))，直到速度趋近于0后吸附")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .onChange(of: damping) { _, newValue in
                manager.config.decelerationRate = CGFloat(newValue)
            }

            Button("重置到中间") {
                manager.scrollToIndex(manager.items.count / 2)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("惯性阻尼")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.manyItems) }
    }
}

// MARK: - 动态添加删除

struct DynamicContentDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        return iCarouselManager(config: config)
    }()
    @State private var addCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("动态添加删除卡片")
                .font(.headline)
            Text("运行时增删卡片内容")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            Text("总数: \(manager.items.count) · 当前: \(manager.currentIndex)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("添加卡片") {
                    addCount += 1
                    let colors: [Color] = [.purple, .pink, .cyan, .mint, .teal]
                    let icons = ["plus.circle.fill", "star.circle.fill", "heart.circle.fill"]
                    let newItem = iCarouselItem(
                        id: "new_\(addCount)",
                        title: "新卡片 #\(addCount)",
                        subtitle: "动态添加",
                        color: colors[addCount % colors.count],
                        imageName: icons[addCount % icons.count]
                    )
                    withAnimation {
                        manager.addItem(newItem, at: manager.currentIndex + 1)
                    }
                }
                .buttonStyle(.bordered)

                Button("删除当前") {
                    withAnimation {
                        manager.removeItem(at: manager.currentIndex)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(manager.items.isEmpty)
            }
        }
        .padding()
        .navigationTitle("动态内容")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(Array(CarouselSampleData.items.prefix(4))) }
    }
}

// MARK: - 异步加载远程图片

struct AsyncImageDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        config.itemSize = CGSize(width: 220, height: 300)
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("异步加载远程图片")
                .font(.headline)
            Text("带占位图的渐显过渡效果")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager) { item, _ in
                AnyView(AsyncImageCarouselItemView(item: item))
            }

            indexIndicator(manager: manager)
        }
        .padding()
        .navigationTitle("异步图片")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.imageItems) }
    }
}

// MARK: - 视图复用与预加载

struct ReusePoolDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        config.visibleItems = 5
        return iCarouselManager(config: config)
    }()

    var body: some View {
        VStack(spacing: 16) {
            Text("视图复用与预加载")
                .font(.headline)
            Text("滑动卡片观察视图的创建、回收和复用过程")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            GroupBox("复用池实时状态") {
                VStack(spacing: 8) {
                    HStack {
                        StatBadge(label: "已创建", value: manager.reuseStats.totalCreated, color: .blue)
                        StatBadge(label: "已复用", value: manager.reuseStats.totalReused, color: .green)
                        StatBadge(label: "已回收", value: manager.reuseStats.recycledCount, color: .orange)
                    }

                    HStack {
                        StatBadge(label: "活跃视图", value: manager.reuseStats.activeCount, color: .purple)
                        StatBadge(label: "池中待用", value: manager.reuseStats.poolSize, color: .gray)
                    }

                    if manager.reuseStats.totalReused > 0 {
                        let reuseRate = Double(manager.reuseStats.totalReused) / Double(manager.reuseStats.totalCreated + manager.reuseStats.totalReused) * 100
                        Text("复用率: \(String(format: "%.0f", reuseRate))%")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }
                }
            }

            GroupBox("可见卡片") {
                VStack(spacing: 6) {
                    let visible = manager.visibleItemIndices()
                    Text("可见索引: [\(visible.map { String($0) }.joined(separator: ", "))]")
                        .font(.caption.monospacedDigit())
                    Text("当前渲染: \(visible.count) 张 / 总数: \(manager.items.count) 张")
                        .font(.caption.monospacedDigit())
                    Text("预加载范围: 中心 ± \(manager.config.visibleItems / 2)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            GroupBox("预加载数量") {
                HStack {
                    Text("可见数: \(manager.config.visibleItems)")
                        .font(.caption)
                    Slider(value: Binding(
                        get: { Double(manager.config.visibleItems) },
                        set: {
                            manager.config.visibleItems = Int($0)
                            manager.objectWillChange.send()
                        }
                    ), in: 3...11, step: 2)
                }
            }

            Button("重置统计") {
                manager.resetReuseStats()
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }
        .padding()
        .navigationTitle("视图复用")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.resetReuseStats()
            manager.loadItems(CarouselSampleData.manyItems)
        }
    }
}

struct StatBadge: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title3.monospacedDigit().bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - 点击卡片回调

struct TapCallbackDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        return iCarouselManager(config: config)
    }()
    @StateObject private var handler = CarouselCallbackHandler()

    var body: some View {
        VStack(spacing: 20) {
            Text("点击卡片回调")
                .font(.headline)
            Text("点击任意卡片查看回调信息")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            if let last = handler.lastTapped {
                Text("点击了: \(manager.items[last].title) (索引 \(last))")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .transition(.scale)
            }

            GroupBox("事件日志") {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(handler.logs.suffix(10), id: \.self) { log in
                            Text(log)
                                .font(.system(.caption2, design: .monospaced))
                        }
                    }
                }
                .frame(height: 100)
            }
        }
        .padding()
        .navigationTitle("点击回调")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manager.loadItems(CarouselSampleData.items)
            manager.delegate = handler
        }
    }
}

class CarouselCallbackHandler: ObservableObject, iCarouselDelegate {
    @Published var logs: [String] = []
    @Published var lastTapped: Int?

    func carouselDidSelectItem(at index: Int) {
        lastTapped = index
        logs.append("👆 点击卡片 #\(index)")
    }

    func carouselCurrentIndexChanged(to index: Int) {
        logs.append("📍 切换到 #\(index)")
    }

    func carouselWillBeginDragging() {
        logs.append("✋ 开始拖拽")
    }

    func carouselDidEndDragging() {
        logs.append("🖐 结束拖拽")
    }
}

// MARK: - 滑动到指定索引

struct ScrollToIndexDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        return iCarouselManager(config: config)
    }()
    @State private var targetIndex: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("滑动到指定索引")
                .font(.headline)
            Text("程序化跳转到指定卡片，带弹性动画")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)

            GroupBox("目标索引") {
                VStack(spacing: 8) {
                    HStack {
                        Text("索引: \(Int(targetIndex))")
                        Slider(value: $targetIndex, in: 0...Double(max(0, manager.items.count - 1)), step: 1)
                    }
                    .font(.caption)

                    HStack(spacing: 12) {
                        Button("跳转(带动画)") {
                            manager.scrollToIndex(Int(targetIndex), animated: true)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("跳转(无动画)") {
                            manager.scrollToIndex(Int(targetIndex), animated: false)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            HStack(spacing: 12) {
                Button("首张") { manager.scrollToIndex(0) }
                    .buttonStyle(.bordered)
                Button("末张") { manager.scrollToIndex(manager.items.count - 1) }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("指定索引")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 禁用用户滑动

struct DisableScrollDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        config.isUserScrollEnabled = true
        return iCarouselManager(config: config)
    }()
    @State private var scrollEnabled = true

    var body: some View {
        VStack(spacing: 20) {
            Text("禁用用户滑动")
                .font(.headline)
            Text("禁用后仅可通过按钮控制")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)

            Toggle("允许用户滑动", isOn: $scrollEnabled)
                .font(.subheadline)
                .padding(.horizontal)
                .onChange(of: scrollEnabled) { _, newValue in
                    manager.config.isUserScrollEnabled = newValue
                }

            HStack(spacing: 20) {
                Button("← 上一张") { manager.scrollToIndex(manager.currentIndex - 1) }
                    .buttonStyle(.bordered)
                Button("下一张 →") { manager.scrollToIndex(manager.currentIndex + 1) }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("禁用滑动")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 透视投影深度

struct PerspectiveDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        return iCarouselManager(config: config)
    }()
    @State private var depth: Double = 500

    var body: some View {
        VStack(spacing: 20) {
            Text("透视投影深度")
                .font(.headline)
            Text("调节透视参数控制3D纵深感")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)

            GroupBox("透视深度") {
                VStack(spacing: 8) {
                    HStack {
                        Text("深度: \(Int(depth))")
                        Slider(value: $depth, in: 100...2000)
                    }
                    .font(.caption)
                    Text("值越小透视效果越强，值越大越平坦")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: depth) { _, newValue in
                manager.config.perspectiveDepth = CGFloat(newValue)
                manager.objectWillChange.send()
            }
        }
        .padding()
        .navigationTitle("透视深度")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 卡片间距配置

struct SpacingDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .coverFlow
        return iCarouselManager(config: config)
    }()
    @State private var spacing: Double = 200

    var body: some View {
        VStack(spacing: 20) {
            Text("卡片间距配置")
                .font(.headline)
            Text("调节卡片之间的间距")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager)

            indexIndicator(manager: manager)

            GroupBox("间距参数") {
                VStack(spacing: 8) {
                    HStack {
                        Text("间距: \(Int(spacing))")
                        Slider(value: $spacing, in: 80...400)
                    }
                    .font(.caption)
                }
            }
            .onChange(of: spacing) { _, newValue in
                manager.config.itemSpacing = CGFloat(newValue)
                manager.objectWillChange.send()
            }
        }
        .padding()
        .navigationTitle("卡片间距")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

// MARK: - 视差滚动效果

struct ParallaxDemoPage: View {
    @StateObject private var manager: iCarouselManager = {
        var config = iCarouselConfig()
        config.carouselType = .linear
        config.itemSpacing = 220
        config.parallaxFactor = 0.3
        config.itemSize = CGSize(width: 240, height: 300)
        return iCarouselManager(config: config)
    }()
    @State private var parallax: Double = 0.3

    var body: some View {
        VStack(spacing: 20) {
            Text("视差滚动效果")
                .font(.headline)
            Text("卡片内容相对卡片有视差偏移")
                .font(.caption)
                .foregroundStyle(.secondary)

            iCarouselView(manager: manager) { item, index in
                AnyView(ParallaxCardView(item: item, parallaxOffset: manager.itemOffset(for: index, from: Int(round(manager.currentOffset))) * CGFloat(parallax) * 30))
            }

            indexIndicator(manager: manager)

            GroupBox("视差系数") {
                VStack(spacing: 8) {
                    HStack {
                        Text("系数: \(String(format: "%.2f", parallax))")
                        Slider(value: $parallax, in: 0...1.0)
                    }
                    .font(.caption)
                    Text("值越大内容偏移越明显")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .navigationTitle("视差滚动")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.loadItems(CarouselSampleData.items) }
    }
}

struct ParallaxCardView: View {
    let item: iCarouselItem
    let parallaxOffset: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(item.color.gradient)

            VStack(spacing: 12) {
                Image(systemName: item.imageName)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .offset(x: parallaxOffset)

                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .offset(x: parallaxOffset * 0.6)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .offset(x: parallaxOffset * 0.3)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

// MARK: - Shared Components

func indexIndicator(manager: iCarouselManager) -> some View {
    HStack(spacing: 6) {
        ForEach(0..<min(manager.items.count, 10), id: \.self) { i in
            Circle()
                .fill(i == manager.currentIndex ? Color.primary : Color.secondary.opacity(0.3))
                .frame(width: i == manager.currentIndex ? 8 : 6,
                       height: i == manager.currentIndex ? 8 : 6)
                .animation(.easeInOut(duration: 0.2), value: manager.currentIndex)
        }
        if manager.items.count > 10 {
            Text("...")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Sample Data

enum CarouselSampleData {
    static var items: [iCarouselItem] {
        [
            iCarouselItem(id: "c1", title: "探索世界", subtitle: "开始旅程", color: .blue, imageName: "globe"),
            iCarouselItem(id: "c2", title: "音乐律动", subtitle: "感受节奏", color: .purple, imageName: "music.note"),
            iCarouselItem(id: "c3", title: "星辰大海", subtitle: "仰望星空", color: .indigo, imageName: "star.fill"),
            iCarouselItem(id: "c4", title: "自然之美", subtitle: "拥抱自然", color: .green, imageName: "leaf.fill"),
            iCarouselItem(id: "c5", title: "知识海洋", subtitle: "永不停歇", color: .orange, imageName: "book.fill"),
            iCarouselItem(id: "c6", title: "创意无限", subtitle: "释放想象", color: .pink, imageName: "paintbrush.fill"),
            iCarouselItem(id: "c7", title: "运动健康", subtitle: "活力每天", color: .red, imageName: "figure.run"),
            iCarouselItem(id: "c8", title: "科技前沿", subtitle: "探索未来", color: .cyan, imageName: "cpu"),
        ]
    }

    static var imageItems: [iCarouselItem] {
        [
            iCarouselItem(id: "img1", title: "风景", subtitle: "山水画卷", color: .blue, imageName: "photo", imageURL: "https://picsum.photos/400/560?random=1"),
            iCarouselItem(id: "img2", title: "城市", subtitle: "都市夜景", color: .purple, imageName: "building.2", imageURL: "https://picsum.photos/400/560?random=2"),
            iCarouselItem(id: "img3", title: "海洋", subtitle: "碧波万顷", color: .cyan, imageName: "water.waves", imageURL: "https://picsum.photos/400/560?random=3"),
            iCarouselItem(id: "img4", title: "森林", subtitle: "绿意盎然", color: .green, imageName: "tree", imageURL: "https://picsum.photos/400/560?random=4"),
            iCarouselItem(id: "img5", title: "沙漠", subtitle: "黄沙万里", color: .orange, imageName: "sun.max", imageURL: "https://picsum.photos/400/560?random=5"),
        ]
    }

    static var manyItems: [iCarouselItem] {
        let colors: [Color] = [.blue, .purple, .green, .orange, .pink, .red, .cyan, .indigo, .mint, .teal]
        let icons = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "drop.fill", "leaf.fill", "moon.fill", "sun.max.fill"]
        return (0..<20).map { i in
            iCarouselItem(
                id: "many_\(i)",
                title: "卡片 #\(i + 1)",
                subtitle: "第 \(i + 1) 项",
                color: colors[i % colors.count],
                imageName: icons[i % icons.count]
            )
        }
    }
}
