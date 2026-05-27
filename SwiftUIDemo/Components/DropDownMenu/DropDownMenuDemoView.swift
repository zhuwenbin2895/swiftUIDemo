import SwiftUI
import Combine

struct DropDownMenuDemoView: View {
    var body: some View {
        List {
            Section("基础功能") {
                NavigationLink("基础下拉菜单") {
                    BasicDropDownDemo()
                }
                NavigationLink("带图标菜单") {
                    IconDropDownDemo()
                }
                NavigationLink("选中勾选标记") {
                    CheckmarkDropDownDemo()
                }
            }

            Section("附着位置") {
                NavigationLink("导航栏下拉") {
                    NavBarDropDownDemo()
                }
                NavigationLink("工具栏下拉") {
                    ToolbarDropDownDemo()
                }
            }

            Section("自定义样式") {
                NavigationLink("自定义宽度和高度") {
                    CustomSizeDemo()
                }
                NavigationLink("自定义背景色和字体") {
                    CustomStyleDemo()
                }
                NavigationLink("自定义分隔线和箭头") {
                    CustomSeparatorDemo()
                }
            }

            Section("多标题切换") {
                NavigationLink("多菜单标题切换") {
                    MultiTitleDemo()
                }
            }

            Section("扩展功能") {
                NavigationLink("菜单嵌套") {
                    NestedMenuDemo()
                }
                NavigationLink("嵌入自定义控件") {
                    CustomControlDemo()
                }
                NavigationLink("显示/隐藏回调") {
                    CallbackDemo()
                }
                NavigationLink("DataSource/Delegate") {
                    DataSourceDelegateDemo()
                }
            }
        }
        .navigationTitle("DropDownMenu")
    }
}

// MARK: - Basic Drop Down Demo

private struct BasicDropDownDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "请选择"

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Spacer()

            Text("已选择: \(selectedTitle)")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("基础下拉菜单")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            menuState.configure(
                items: [
                    DropDownMenuItem(title: "选项一"),
                    DropDownMenuItem(title: "选项二"),
                    DropDownMenuItem(title: "选项三"),
                    DropDownMenuItem(title: "选项四"),
                    DropDownMenuItem(title: "选项五"),
                ],
                onSelect: { _, item in
                    selectedTitle = item.title
                }
            )
        }
    }
}

// MARK: - Icon Drop Down Demo

private struct IconDropDownDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "选择操作"

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Spacer()

            Text("选中的操作: \(selectedTitle)")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("带图标菜单")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            menuState.configure(
                items: [
                    DropDownMenuItem(title: "编辑", icon: "pencil", iconColor: .blue),
                    DropDownMenuItem(title: "复制", icon: "doc.on.doc", iconColor: .green),
                    DropDownMenuItem(title: "分享", icon: "square.and.arrow.up", iconColor: .orange),
                    DropDownMenuItem(title: "收藏", icon: "star.fill", iconColor: .yellow),
                    DropDownMenuItem(title: "删除", icon: "trash", iconColor: .red),
                ],
                onSelect: { _, item in
                    selectedTitle = item.title
                }
            )
        }
    }
}

// MARK: - Checkmark Drop Down Demo

private struct CheckmarkDropDownDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "选择排序方式"

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.green)
                Text("当前排序: \(selectedTitle)")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("选中勾选标记")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            menuState.configure(
                items: [
                    DropDownMenuItem(title: "默认排序", icon: "arrow.up.arrow.down", isSelected: true),
                    DropDownMenuItem(title: "按时间升序", icon: "clock.arrow.circlepath"),
                    DropDownMenuItem(title: "按时间降序", icon: "clock.arrow.2.circlepath"),
                    DropDownMenuItem(title: "按名称排序", icon: "textformat.abc"),
                    DropDownMenuItem(title: "按大小排序", icon: "arrow.up.and.down.text.horizontal"),
                ],
                onSelect: { _, item in
                    selectedTitle = item.title
                }
            )
        }
    }
}

// MARK: - NavBar Drop Down Demo

private struct NavBarDropDownDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "全部"
    @State private var logMessages: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section("操作日志") {
                    if logMessages.isEmpty {
                        Text("点击导航栏标题打开菜单")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(logMessages, id: \.self) { msg in
                        Text(msg)
                            .font(.caption)
                    }
                }
            }
        }
        .dropDownMenu(state: menuState)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DropDownMenuTitleView(
                    title: selectedTitle,
                    isActive: menuState.isShowing,
                    config: menuState.config,
                    action: { menuState.toggle() }
                )
            }
        }
        .onAppear {
            menuState.configure(
                items: [
                    DropDownMenuItem(title: "全部", icon: "tray.full"),
                    DropDownMenuItem(title: "未读", icon: "envelope.badge"),
                    DropDownMenuItem(title: "已标记", icon: "flag.fill"),
                    DropDownMenuItem(title: "附件", icon: "paperclip"),
                ],
                onSelect: { index, item in
                    selectedTitle = item.title
                    logMessages.append("选中: \(item.title) (索引: \(index))")
                }
            )
        }
    }
}

// MARK: - Toolbar Drop Down Demo

private struct ToolbarDropDownDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedFilter = "全部任务"

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(0..<10) { i in
                    HStack {
                        Image(systemName: i % 2 == 0 ? "circle" : "checkmark.circle.fill")
                            .foregroundStyle(i % 2 == 0 ? .gray : .green)
                        Text("任务 \(i + 1)")
                    }
                }
            }

            HStack {
                Spacer()
                DropDownMenuTitleView(
                    title: selectedFilter,
                    isActive: menuState.isShowing,
                    config: menuState.config,
                    action: { menuState.toggle() }
                )
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(uiColor: .secondarySystemBackground))
        }
        .dropDownMenu(state: menuState, attachment: .toolbar)
        .navigationTitle("工具栏下拉")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            menuState.configure(
                items: [
                    DropDownMenuItem(title: "全部任务", icon: "list.bullet"),
                    DropDownMenuItem(title: "未完成", icon: "circle"),
                    DropDownMenuItem(title: "已完成", icon: "checkmark.circle.fill"),
                    DropDownMenuItem(title: "已过期", icon: "exclamationmark.circle"),
                ],
                onSelect: { _, item in
                    selectedFilter = item.title
                }
            )
        }
    }
}

// MARK: - Custom Size Demo

private struct CustomSizeDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "自定义尺寸"

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Spacer()

            VStack(spacing: 12) {
                Text("菜单宽度: 250pt")
                Text("行高: 56pt")
                Text("最大可见行数: 5")
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("自定义宽度和高度")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            var config = DropDownMenuConfig()
            config.menuWidth = 250
            config.rowHeight = 56
            config.maxVisibleRows = 5
            config.cornerRadius = 16

            menuState.configure(
                items: [
                    DropDownMenuItem(title: "大号选项一", icon: "1.circle"),
                    DropDownMenuItem(title: "大号选项二", icon: "2.circle"),
                    DropDownMenuItem(title: "大号选项三", icon: "3.circle"),
                    DropDownMenuItem(title: "大号选项四", icon: "4.circle"),
                    DropDownMenuItem(title: "大号选项五", icon: "5.circle"),
                    DropDownMenuItem(title: "大号选项六", icon: "6.circle"),
                    DropDownMenuItem(title: "大号选项七", icon: "7.circle"),
                ],
                config: config,
                onSelect: { _, item in
                    selectedTitle = item.title
                }
            )
        }
    }
}

// MARK: - Custom Style Demo

private struct CustomStyleDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "暗色主题"

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Spacer()

            VStack(spacing: 12) {
                Text("自定义背景: 深色")
                Text("自定义字体: 粗体")
                Text("自定义颜色: 橙色系")
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("自定义背景色和字体")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            var config = DropDownMenuConfig()
            config.backgroundColor = Color(red: 0.15, green: 0.15, blue: 0.2)
            config.titleFont = .system(size: 17, weight: .semibold)
            config.titleColor = .white
            config.selectedTitleColor = .orange
            config.checkmarkColor = .orange
            config.separatorColor = .white.opacity(0.1)
            config.arrowActiveColor = .orange
            config.titleViewActiveColor = .orange

            menuState.configure(
                items: [
                    DropDownMenuItem(title: "深色选项一", icon: "moon.fill", iconColor: .yellow),
                    DropDownMenuItem(title: "深色选项二", icon: "star.fill", iconColor: .orange),
                    DropDownMenuItem(title: "深色选项三", icon: "heart.fill", iconColor: .pink),
                    DropDownMenuItem(title: "深色选项四", icon: "bolt.fill", iconColor: .cyan),
                ],
                config: config,
                onSelect: { _, item in
                    selectedTitle = item.title
                }
            )
        }
    }
}

// MARK: - Custom Separator Demo

private struct CustomSeparatorDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "自定义分隔线"

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Spacer()

            VStack(spacing: 12) {
                Text("无分隔线样式")
                Text("自定义箭头图标: arrow.down.circle")
                Text("箭头颜色: 紫色")
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("自定义分隔线和箭头")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            var config = DropDownMenuConfig()
            config.showSeparator = false
            config.arrowIcon = "arrowtriangle.down.circle.fill"
            config.arrowActiveIcon = "arrowtriangle.up.circle.fill"
            config.arrowColor = .purple.opacity(0.6)
            config.arrowActiveColor = .purple
            config.arrowSize = 16
            config.cornerRadius = 20

            menuState.configure(
                items: [
                    DropDownMenuItem(title: "无分隔线一", icon: "paintpalette"),
                    DropDownMenuItem(title: "无分隔线二", icon: "paintbrush.pointed"),
                    DropDownMenuItem(title: "无分隔线三", icon: "eyedropper"),
                    DropDownMenuItem(title: "无分隔线四", icon: "photo.artframe"),
                ],
                config: config,
                onSelect: { _, item in
                    selectedTitle = item.title
                }
            )
        }
    }
}

// MARK: - Multi Title Demo

private struct MultiTitleDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var titles = ["分类", "排序", "筛选"]
    @State private var selectedValues = ["全部分类", "默认排序", "不限"]
    @State private var currentMenuIndex = 0

    private let menuData: [[DropDownMenuItem]] = [
        [
            DropDownMenuItem(title: "全部分类", icon: "square.grid.2x2"),
            DropDownMenuItem(title: "美食", icon: "fork.knife"),
            DropDownMenuItem(title: "购物", icon: "bag"),
            DropDownMenuItem(title: "休闲", icon: "gamecontroller"),
        ],
        [
            DropDownMenuItem(title: "默认排序", icon: "arrow.up.arrow.down"),
            DropDownMenuItem(title: "距离最近", icon: "location"),
            DropDownMenuItem(title: "好评优先", icon: "star"),
            DropDownMenuItem(title: "价格最低", icon: "dollarsign.circle"),
        ],
        [
            DropDownMenuItem(title: "不限", icon: "line.3.horizontal.decrease"),
            DropDownMenuItem(title: "营业中", icon: "clock"),
            DropDownMenuItem(title: "可配送", icon: "bicycle"),
            DropDownMenuItem(title: "有优惠", icon: "tag"),
        ],
    ]

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuMultiTitleView(
                titles: selectedValues,
                menuState: menuState,
                onTitleTap: { index in
                    if menuState.isShowing && currentMenuIndex == index {
                        menuState.hide()
                    } else {
                        currentMenuIndex = index
                        menuState.items = menuData[index]
                        menuState.activeMenuIndex = index
                        if !menuState.isShowing {
                            menuState.show()
                        }
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Divider()

            List {
                Section("当前筛选条件") {
                    ForEach(Array(zip(titles, selectedValues)), id: \.0) { title, value in
                        HStack {
                            Text(title)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(value)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("多菜单标题切换")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            menuState.configure(
                items: menuData[0],
                onSelect: { _, item in
                    selectedValues[currentMenuIndex] = item.title
                }
            )
        }
    }
}

// MARK: - Nested Menu Demo

private struct NestedMenuDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "选择地区"

    private static func makeMenuData() -> [DropDownMenuItem] {
        [
            DropDownMenuItem(title: "华东地区", icon: "map", children: [
                DropDownMenuItem(title: "上海", icon: "building.2"),
                DropDownMenuItem(title: "江苏", icon: "leaf"),
                DropDownMenuItem(title: "浙江", icon: "water.waves"),
            ]),
            DropDownMenuItem(title: "华南地区", icon: "map", children: [
                DropDownMenuItem(title: "广东", icon: "building.2"),
                DropDownMenuItem(title: "广西", icon: "mountain.2"),
                DropDownMenuItem(title: "海南", icon: "sun.max"),
            ]),
            DropDownMenuItem(title: "华北地区", icon: "map", children: [
                DropDownMenuItem(title: "北京", icon: "building.2"),
                DropDownMenuItem(title: "天津", icon: "ferry"),
                DropDownMenuItem(title: "河北", icon: "tree"),
            ]),
            DropDownMenuItem(title: "西南地区", icon: "map", children: [
                DropDownMenuItem(title: "四川", icon: "flame"),
                DropDownMenuItem(title: "重庆", icon: "building"),
                DropDownMenuItem(title: "云南", icon: "cloud"),
            ]),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                Text("已选地区: \(selectedTitle)")
                    .foregroundStyle(.secondary)
                Text("点击有子菜单的项进入下一级\n组件内置「返回上一级」按钮")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("菜单嵌套")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            menuState.configure(
                items: Self.makeMenuData(),
                onSelect: { _, item in
                    selectedTitle = item.title
                }
            )
        }
    }
}

// MARK: - Custom Control Demo

private struct CustomControlDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @StateObject private var controlState = ControlDemoState()
    @State private var selectedTitle = "快捷设置"

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            Spacer()

            VStack(spacing: 12) {
                Text("菜单中嵌入了:")
                    .fontWeight(.medium)
                Text("- Slider 控件 (可拖拽)")
                Text("- Toggle 开关 (可点击)")
                Divider().frame(width: 200)
                Text("亮度: \(Int(controlState.brightness * 100))%")
                Text("Wi-Fi: \(controlState.isWifiOn ? "开启" : "关闭")")
                Text("蓝牙: \(controlState.isBluetoothOn ? "开启" : "关闭")")
                Text("音量: \(Int(controlState.volume * 100))%")
            }
            .foregroundStyle(.secondary)

            Spacer()
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("嵌入自定义控件")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            var config = DropDownMenuConfig()
            config.rowHeight = 56

            menuState.configure(
                items: [
                    DropDownMenuItem(title: "亮度调节", customView: { [weak controlState] in
                        AnyView(
                            BrightnessSliderRow(state: controlState)
                        )
                    }),
                    DropDownMenuItem(title: "Wi-Fi", customView: { [weak controlState] in
                        AnyView(
                            WifiToggleRow(state: controlState)
                        )
                    }),
                    DropDownMenuItem(title: "蓝牙", customView: { [weak controlState] in
                        AnyView(
                            BluetoothToggleRow(state: controlState)
                        )
                    }),
                    DropDownMenuItem(title: "音量", customView: { [weak controlState] in
                        AnyView(
                            VolumeSliderRow(state: controlState)
                        )
                    }),
                ],
                config: config,
                onSelect: { _, item in
                    selectedTitle = item.title
                }
            )
        }
    }
}

private class ControlDemoState: ObservableObject {
    @Published var brightness: Double = 0.5
    @Published var isWifiOn: Bool = true
    @Published var isBluetoothOn: Bool = false
    @Published var volume: Double = 0.7
}

private struct BrightnessSliderRow: View {
    @ObservedObject var state: ControlDemoState

    init(state: ControlDemoState?) {
        self.state = state ?? ControlDemoState()
    }

    var body: some View {
        HStack {
            Image(systemName: "sun.min")
                .foregroundStyle(.orange)
            Slider(value: $state.brightness)
                .tint(.orange)
            Image(systemName: "sun.max.fill")
                .foregroundStyle(.orange)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }
}

private struct WifiToggleRow: View {
    @ObservedObject var state: ControlDemoState

    init(state: ControlDemoState?) {
        self.state = state ?? ControlDemoState()
    }

    var body: some View {
        HStack {
            Image(systemName: "wifi")
                .foregroundStyle(.blue)
            Text("Wi-Fi")
                .font(.system(size: 16))
            Spacer()
            Toggle("", isOn: $state.isWifiOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }
}

private struct BluetoothToggleRow: View {
    @ObservedObject var state: ControlDemoState

    init(state: ControlDemoState?) {
        self.state = state ?? ControlDemoState()
    }

    var body: some View {
        HStack {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .foregroundStyle(.blue)
            Text("蓝牙")
                .font(.system(size: 16))
            Spacer()
            Toggle("", isOn: $state.isBluetoothOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }
}

private struct VolumeSliderRow: View {
    @ObservedObject var state: ControlDemoState

    init(state: ControlDemoState?) {
        self.state = state ?? ControlDemoState()
    }

    var body: some View {
        HStack {
            Image(systemName: "speaker.fill")
                .foregroundStyle(.purple)
            Slider(value: $state.volume)
                .tint(.purple)
            Image(systemName: "speaker.wave.3.fill")
                .foregroundStyle(.purple)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }
}

// MARK: - Callback Demo

private struct CallbackDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "点击展开"
    @State private var logs: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            List {
                Section("回调日志") {
                    if logs.isEmpty {
                        Text("操作菜单查看回调日志")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(Array(logs.enumerated()), id: \.offset) { _, log in
                        Text(log)
                            .font(.system(size: 13, design: .monospaced))
                    }
                }
            }
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("显示/隐藏回调")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            menuState.configure(
                items: [
                    DropDownMenuItem(title: "菜单项一", icon: "1.circle"),
                    DropDownMenuItem(title: "菜单项二", icon: "2.circle"),
                    DropDownMenuItem(title: "菜单项三", icon: "3.circle"),
                ],
                onSelect: { index, item in
                    selectedTitle = item.title
                    logs.append("[\(timestamp)] didSelect: \(item.title) at \(index)")
                }
            )

            menuState.onShowHide(
                willShow: { logs.append("[\(timestamp)] willShow") },
                didShow: { logs.append("[\(timestamp)] didShow") },
                willHide: { logs.append("[\(timestamp)] willHide") },
                didHide: { logs.append("[\(timestamp)] didHide") }
            )
        }
    }

    private var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

// MARK: - DataSource & Delegate Demo

private class MenuDataProvider: DropDownMenuDataSource, DropDownMenuDelegate {
    let items: [DropDownMenuItem] = [
        DropDownMenuItem(title: "通过DataSource提供", icon: "doc.text"),
        DropDownMenuItem(title: "动态加载数据", icon: "arrow.clockwise"),
        DropDownMenuItem(title: "代理回调选中", icon: "hand.tap"),
        DropDownMenuItem(title: "协议驱动设计", icon: "gearshape.2"),
        DropDownMenuItem(title: "解耦数据与视图", icon: "arrow.triangle.branch"),
    ]

    var onSelect: ((Int, DropDownMenuItem) -> Void)?
    var onEvent: ((String) -> Void)?

    func numberOfRows(in menu: DropDownMenuState) -> Int {
        items.count
    }

    func menuItem(in menu: DropDownMenuState, at index: Int) -> DropDownMenuItem {
        items[index]
    }

    func dropDownMenu(_ menu: DropDownMenuState, didSelectItemAt index: Int) {
        onSelect?(index, items[index])
        onEvent?("Delegate: didSelectItemAt \(index) - \(items[index].title)")
    }

    func dropDownMenuWillShow(_ menu: DropDownMenuState) {
        onEvent?("Delegate: willShow")
    }

    func dropDownMenuDidShow(_ menu: DropDownMenuState) {
        onEvent?("Delegate: didShow")
    }

    func dropDownMenuWillHide(_ menu: DropDownMenuState) {
        onEvent?("Delegate: willHide")
    }

    func dropDownMenuDidHide(_ menu: DropDownMenuState) {
        onEvent?("Delegate: didHide")
    }
}

private struct DataSourceDelegateDemo: View {
    @StateObject private var menuState = DropDownMenuState()
    @State private var selectedTitle = "DataSource 菜单"
    @State private var logs: [String] = []
    private let dataProvider = MenuDataProvider()

    var body: some View {
        VStack(spacing: 0) {
            DropDownMenuTitleView(
                title: selectedTitle,
                isActive: menuState.isShowing,
                config: menuState.config,
                action: { menuState.toggle() }
            )
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))

            List {
                Section("说明") {
                    Text("数据通过 DropDownMenuDataSource 协议提供")
                        .font(.caption)
                    Text("选中事件通过 DropDownMenuDelegate 协议回调")
                        .font(.caption)
                }
                Section("Delegate 回调日志") {
                    if logs.isEmpty {
                        Text("操作菜单查看代理回调")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(Array(logs.enumerated()), id: \.offset) { _, log in
                        Text(log)
                            .font(.system(size: 12, design: .monospaced))
                    }
                }
            }
        }
        .dropDownMenu(state: menuState)
        .navigationTitle("DataSource/Delegate")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            dataProvider.onSelect = { _, item in
                selectedTitle = item.title
            }
            dataProvider.onEvent = { event in
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                let ts = formatter.string(from: Date())
                logs.append("[\(ts)] \(event)")
            }
            menuState.setDataSource(dataProvider)
            menuState.setDelegate(dataProvider)
        }
    }
}

#Preview {
    NavigationStack {
        DropDownMenuDemoView()
    }
}
