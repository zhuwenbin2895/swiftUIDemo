import SwiftUI

struct SlideMenuDemoView: View {
    var body: some View {
        List {
            Section("核心功能") {
                NavigationLink("基础侧滑菜单") {
                    BasicSlideMenuDemo()
                }
                NavigationLink("左右双侧菜单") {
                    DualSlideMenuDemo()
                }
                NavigationLink("导航控制器集成") {
                    NavigationIntegrationDemo()
                }
            }

            Section("手势交互") {
                NavigationLink("边缘滑动触发") {
                    EdgeGestureDemo()
                }
                NavigationLink("拖拽跟随 & 反弹效果") {
                    DragFollowDemo()
                }
                NavigationLink("点击主视图关闭") {
                    TapToCloseDemo()
                }
            }

            Section("动画效果") {
                NavigationLink("弹簧动画") {
                    SpringAnimationDemo()
                }
                NavigationLink("缩放平移组合动画") {
                    ScaleTranslateDemo()
                }
                NavigationLink("阴影效果配置") {
                    ShadowConfigDemo()
                }
            }

            Section("菜单状态") {
                NavigationLink("多档位部分打开") {
                    PartialOpenDemo()
                }
                NavigationLink("独立左右控制") {
                    SlideMenuIndependentControlDemo()
                }
            }

            Section("配置选项") {
                NavigationLink("自定义菜单宽度") {
                    CustomWidthDemo()
                }
                NavigationLink("自定义缩放比例") {
                    CustomScaleDemo()
                }
            }

            Section("事件回调") {
                NavigationLink("回调事件监听") {
                    SlideMenuCallbackDemo()
                }
            }
        }
        .navigationTitle("SlideMenu")
    }
}

// MARK: - Basic Slide Menu Demo

struct BasicSlideMenuDemo: View {
    @StateObject private var manager = SlideMenuManager()

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("主内容视图")
                    .font(.title)
                Text("从左边缘向右滑动打开菜单")
                    .foregroundColor(.secondary)
                Button("打开左侧菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("基础侧滑菜单")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Dual Slide Menu Demo

struct DualSlideMenuDemo: View {
    @StateObject private var manager: SlideMenuManager = {
        var config = SlideMenuConfig()
        config.enableRightMenu = true
        config.rightMenuWidth = 240
        return SlideMenuManager(config: config)
    }()

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("左右双侧菜单")
                    .font(.title)
                Text("左边缘右滑 / 右边缘左滑")
                    .foregroundColor(.secondary)
                HStack(spacing: 16) {
                    Button("打开左侧") {
                        manager.openLeft()
                    }
                    .buttonStyle(.borderedProminent)
                    Button("打开右侧") {
                        manager.openRight()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        } rightMenu: {
            RightMenuContent()
        }
        .navigationTitle("双侧菜单")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Navigation Integration Demo

struct NavigationIntegrationDemo: View {
    var body: some View {
        SlideMenuNavigationView {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("导航控制器集成")
                    .font(.title)
                Text("自动添加汉堡菜单按钮")
                    .foregroundColor(.secondary)
                Text("点击左上角按钮或边缘滑动")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("首页")
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Edge Gesture Demo

struct EdgeGestureDemo: View {
    @StateObject private var manager: SlideMenuManager = {
        var config = SlideMenuConfig()
        config.edgeTriggerWidth = 40
        return SlideMenuManager(config: config)
    }()

    @State private var triggerWidth: CGFloat = 40

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("边缘滑动触发")
                    .font(.title)

                VStack(alignment: .leading, spacing: 8) {
                    Text("触发区域宽度: \(Int(triggerWidth))pt")
                    Slider(value: $triggerWidth, in: 10...100, step: 5)
                        .onChange(of: triggerWidth) { _, newValue in
                            manager.config.edgeTriggerWidth = newValue
                        }
                }
                .padding(.horizontal, 40)

                Text("只有在左侧 \(Int(triggerWidth))pt 区域内滑动才触发")
                    .font(.caption)
                    .foregroundColor(.secondary)

                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: triggerWidth)
                        .overlay(
                            Text("触发区")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 60)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("边缘滑动")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Drag Follow Demo

struct DragFollowDemo: View {
    @StateObject private var manager: SlideMenuManager = {
        var config = SlideMenuConfig()
        config.enableBounceEffect = true
        config.bounceDistance = 30
        config.edgeTriggerWidth = 60
        return SlideMenuManager(config: config)
    }()

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("拖拽跟随 & 反弹")
                    .font(.title)
                Text("主视图跟随手指移动")
                    .foregroundColor(.secondary)
                Text("滑动超出菜单宽度时有反弹效果")
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("当前偏移: \(String(format: "%.1f", manager.dragOffset))")
                    Text("缩放比例: \(String(format: "%.3f", manager.mainViewScale))")
                    Text("正在拖拽: \(manager.isDragging ? "是" : "否")")
                }
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(8)

                Button("打开菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("拖拽跟随")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tap To Close Demo

struct TapToCloseDemo: View {
    @StateObject private var manager = SlideMenuManager()

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("点击关闭")
                    .font(.title)
                Text("菜单打开时,点击主视图区域关闭菜单")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("打开菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)

                Text("菜单状态: \(manager.isMenuOpen ? "打开" : "关闭")")
                    .foregroundColor(manager.isMenuOpen ? .green : .red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("点击关闭")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Spring Animation Demo

struct SpringAnimationDemo: View {
    @StateObject private var manager = SlideMenuManager()
    @State private var damping: CGFloat = 0.75
    @State private var response: CGFloat = 0.4

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("弹簧动画")
                    .font(.title)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("阻尼系数: \(String(format: "%.2f", damping))")
                        Slider(value: $damping, in: 0.3...1.0, step: 0.05)
                            .onChange(of: damping) { _, newValue in
                                manager.config.springDamping = newValue
                            }
                    }
                    VStack(alignment: .leading) {
                        Text("响应速度: \(String(format: "%.2f", response))")
                        Slider(value: $response, in: 0.1...1.0, step: 0.05)
                            .onChange(of: response) { _, newValue in
                                manager.config.springResponse = newValue
                            }
                    }
                }
                .padding(.horizontal, 30)

                Text("调整参数后点击按钮查看效果")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button("打开菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("弹簧动画")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Scale Translate Demo

struct ScaleTranslateDemo: View {
    @StateObject private var manager = SlideMenuManager()
    @State private var scale: CGFloat = 0.88
    @State private var translateRatio: CGFloat = 1.0

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("缩放平移组合")
                    .font(.title)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("缩放比例: \(String(format: "%.2f", scale))")
                        Slider(value: $scale, in: 0.5...1.0, step: 0.02)
                            .onChange(of: scale) { _, newValue in
                                manager.config.mainViewScale = newValue
                            }
                    }
                    VStack(alignment: .leading) {
                        Text("平移比例: \(String(format: "%.2f", translateRatio))")
                        Slider(value: $translateRatio, in: 0.3...1.5, step: 0.05)
                            .onChange(of: translateRatio) { _, newValue in
                                manager.config.mainViewTranslateRatio = newValue
                            }
                    }
                }
                .padding(.horizontal, 30)

                Button("打开菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("缩放平移")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Shadow Config Demo

struct ShadowConfigDemo: View {
    @StateObject private var manager = SlideMenuManager()
    @State private var shadowRadius: CGFloat = 10
    @State private var shadowOpacity: CGFloat = 0.3
    @State private var cornerRadius: CGFloat = 12

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("阴影效果配置")
                    .font(.title)

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("阴影半径: \(Int(shadowRadius))")
                        Slider(value: $shadowRadius, in: 0...30, step: 1)
                            .onChange(of: shadowRadius) { _, newValue in
                                manager.config.mainViewShadowRadius = newValue
                            }
                    }
                    VStack(alignment: .leading) {
                        Text("阴影透明度: \(String(format: "%.2f", shadowOpacity))")
                        Slider(value: $shadowOpacity, in: 0...1.0, step: 0.05)
                            .onChange(of: shadowOpacity) { _, newValue in
                                manager.config.mainViewShadowOpacity = newValue
                            }
                    }
                    VStack(alignment: .leading) {
                        Text("圆角: \(Int(cornerRadius))")
                        Slider(value: $cornerRadius, in: 0...30, step: 1)
                            .onChange(of: cornerRadius) { _, newValue in
                                manager.config.mainViewCornerRadius = newValue
                            }
                    }
                }
                .padding(.horizontal, 30)

                Button("打开菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("阴影配置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Partial Open Demo

struct PartialOpenDemo: View {
    @StateObject private var manager: SlideMenuManager = {
        var config = SlideMenuConfig()
        config.partialStops = [0.3, 0.6, 1.0]
        return SlideMenuManager(config: config)
    }()

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("多档位部分打开")
                    .font(.title)
                Text("支持 30%、60%、100% 三档")
                    .foregroundColor(.secondary)

                VStack(spacing: 12) {
                    Button("打开 30%") {
                        manager.openLeftPartial(stop: 0.3)
                    }
                    .buttonStyle(.bordered)

                    Button("打开 60%") {
                        manager.openLeftPartial(stop: 0.6)
                    }
                    .buttonStyle(.bordered)

                    Button("完全打开") {
                        manager.openLeft()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("关闭") {
                        manager.close()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }

                Text("当前进度: \(String(format: "%.0f%%", manager.currentProgress * 100))")
                    .font(.system(.body, design: .monospaced))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("多档位")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Independent Control Demo

struct SlideMenuIndependentControlDemo: View {
    @StateObject private var manager: SlideMenuManager = {
        var config = SlideMenuConfig()
        config.enableRightMenu = true
        config.leftMenuWidth = 260
        config.rightMenuWidth = 220
        return SlideMenuManager(config: config)
    }()

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("独立左右控制")
                    .font(.title)
                Text("左右菜单宽度和状态独立")
                    .foregroundColor(.secondary)

                HStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("左侧 260pt")
                            .font(.caption)
                        Button("打开左侧") {
                            manager.openLeft()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    VStack(spacing: 8) {
                        Text("右侧 220pt")
                            .font(.caption)
                        Button("打开右侧") {
                            manager.openRight()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Text(stateDescription)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        } rightMenu: {
            RightMenuContent()
        }
        .navigationTitle("独立控制")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var stateDescription: String {
        switch manager.menuState {
        case .closed: return "状态: 关闭"
        case .leftOpen: return "状态: 左侧打开"
        case .rightOpen: return "状态: 右侧打开"
        case .leftPartial(let p): return "状态: 左侧 \(Int(p * 100))%"
        case .rightPartial(let p): return "状态: 右侧 \(Int(p * 100))%"
        }
    }
}

// MARK: - Custom Width Demo

struct CustomWidthDemo: View {
    @StateObject private var manager = SlideMenuManager()
    @State private var menuWidth: CGFloat = 280

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("自定义菜单宽度")
                    .font(.title)

                VStack(alignment: .leading) {
                    Text("菜单宽度: \(Int(menuWidth))pt")
                    Slider(value: $menuWidth, in: 150...350, step: 10)
                        .onChange(of: menuWidth) { _, newValue in
                            manager.config.leftMenuWidth = newValue
                        }
                }
                .padding(.horizontal, 30)

                Button("打开菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("自定义宽度")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Custom Scale Demo

struct CustomScaleDemo: View {
    @StateObject private var manager = SlideMenuManager()
    @State private var scale: CGFloat = 0.88

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 20) {
                Text("自定义缩放比例")
                    .font(.title)

                VStack(alignment: .leading) {
                    Text("缩放: \(String(format: "%.2f", scale))")
                    Slider(value: $scale, in: 0.5...1.0, step: 0.02)
                        .onChange(of: scale) { _, newValue in
                            manager.config.mainViewScale = newValue
                        }

                    Text("1.0 = 无缩放, 0.5 = 缩小到50%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)

                Button("打开菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("自定义缩放")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Callback Demo

struct SlideMenuCallbackDemo: View {
    @State private var logs: [String] = []
    @StateObject private var manager = SlideMenuManager()

    var body: some View {
        SlideMenuContainerView(manager: manager) {
            LeftMenuContent()
        } mainContent: {
            VStack(spacing: 16) {
                Text("事件回调")
                    .font(.title)

                Button("打开菜单") {
                    manager.openLeft()
                }
                .buttonStyle(.borderedProminent)

                Button("清除日志") {
                    logs.removeAll()
                }
                .buttonStyle(.bordered)
                .tint(.red)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(logs.enumerated()), id: \.offset) { _, log in
                            Text(log)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 300)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("事件回调")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupCallbacks()
        }
    }

    private func setupCallbacks() {
        manager.callbacks = SlideMenuCallbacks(
            onMenuWillOpen: { side in
                logs.append("[\(timestamp)] willOpen: \(side == .left ? "左侧" : "右侧")")
            },
            onMenuDidOpen: { side in
                logs.append("[\(timestamp)] didOpen: \(side == .left ? "左侧" : "右侧")")
            },
            onMenuWillClose: { side in
                logs.append("[\(timestamp)] willClose: \(side == .left ? "左侧" : "右侧")")
            },
            onMenuDidClose: { side in
                logs.append("[\(timestamp)] didClose: \(side == .left ? "左侧" : "右侧")")
            },
            onGesturePhaseChanged: { phase in
                switch phase {
                case .began:
                    logs.append("[\(timestamp)] gesture: began")
                case .changed(let progress):
                    if logs.count % 5 == 0 {
                        logs.append("[\(timestamp)] gesture: \(String(format: "%.1f%%", progress * 100))")
                    }
                case .ended(let velocity):
                    logs.append("[\(timestamp)] gesture: ended (v=\(String(format: "%.0f", velocity)))")
                }
            }
        )
    }

    private var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

// MARK: - Reusable Menu Content Views

struct LeftMenuContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                Text("用户名")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("user@example.com")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            Divider()
                .background(Color.white.opacity(0.3))

            VStack(spacing: 0) {
                MenuRow(icon: "house", title: "首页")
                MenuRow(icon: "person", title: "个人中心")
                MenuRow(icon: "gear", title: "设置")
                MenuRow(icon: "bell", title: "通知")
                MenuRow(icon: "bookmark", title: "收藏")
                MenuRow(icon: "clock", title: "历史记录")
            }
            .padding(.top, 12)

            Spacer()

            Divider()
                .background(Color.white.opacity(0.3))
            MenuRow(icon: "arrow.right.square", title: "退出登录")
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.1, green: 0.15, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct RightMenuContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("快捷操作")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 60)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            Divider()
                .background(Color.white.opacity(0.3))

            VStack(spacing: 0) {
                MenuRow(icon: "magnifyingglass", title: "搜索")
                MenuRow(icon: "plus.circle", title: "新建")
                MenuRow(icon: "square.and.arrow.up", title: "分享")
                MenuRow(icon: "trash", title: "删除")
            }
            .padding(.top, 12)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.3, green: 0.2, blue: 0.4), Color(red: 0.15, green: 0.1, blue: 0.25)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        )
    }
}

struct MenuRow: View {
    let icon: String
    let title: String

    var body: some View {
        Button {
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 16))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    NavigationStack {
        SlideMenuDemoView()
    }
}
