import SwiftUI

struct FloatingPopoverDemoView: View {
    var body: some View {
        List {
            Section("方向演示") {
                NavigationLink("向下弹出") { DirectionDemoView(direction: .bottom) }
                NavigationLink("向上弹出") { DirectionDemoView(direction: .top) }
                NavigationLink("向左弹出") { DirectionDemoView(direction: .left) }
                NavigationLink("向右弹出") { DirectionDemoView(direction: .right) }
            }
            Section("功能演示") {
                NavigationLink("菜单浮层") { MenuPopoverDemoView() }
                NavigationLink("提示浮层") { TooltipDemoView() }
                NavigationLink("自定义样式") { CustomStyleDemoView() }
            }
        }
        .navigationTitle("FloatingPopover")
    }
}

// MARK: - Direction Demo

struct DirectionDemoView: View {
    let direction: PopoverDirection
    @State private var showPopover = false

    var body: some View {
        VStack {
            Spacer()
            Button {
                withAnimation { showPopover.toggle() }
            } label: {
                Text("点击显示浮层")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .floatingPopover(
                isPresented: $showPopover,
                config: PopoverConfig(direction: direction)
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("浮层内容")
                        .font(.headline)
                    Text("点击空白处关闭")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle(directionTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var directionTitle: String {
        switch direction {
        case .top: return "向上弹出"
        case .bottom: return "向下弹出"
        case .left: return "向左弹出"
        case .right: return "向右弹出"
        }
    }
}

// MARK: - Menu Popover Demo

struct MenuPopoverDemoView: View {
    @State private var showMenu = false
    @State private var selectedItem = ""

    var body: some View {
        VStack(spacing: 20) {
            if !selectedItem.isEmpty {
                Text("已选择: \(selectedItem)")
                    .foregroundColor(.blue)
            }

            Spacer()

            Button {
                withAnimation { showMenu.toggle() }
            } label: {
                HStack {
                    Image(systemName: "ellipsis.circle")
                    Text("菜单")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .floatingPopover(
                isPresented: $showMenu,
                config: PopoverConfig(direction: .top, maxWidth: 160)
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(["复制", "粘贴", "删除", "分享"], id: \.self) { item in
                        Button {
                            selectedItem = item
                            withAnimation { showMenu = false }
                        } label: {
                            HStack {
                                Text(item)
                                    .foregroundColor(item == "删除" ? .red : .primary)
                                Spacer()
                                Image(systemName: iconForItem(item))
                                    .foregroundColor(item == "删除" ? .red : .secondary)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 4)
                        }
                        if item != "分享" {
                            Divider()
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("菜单浮层")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func iconForItem(_ item: String) -> String {
        switch item {
        case "复制": return "doc.on.doc"
        case "粘贴": return "clipboard"
        case "删除": return "trash"
        case "分享": return "square.and.arrow.up"
        default: return "circle"
        }
    }
}

// MARK: - Tooltip Demo

struct TooltipDemoView: View {
    @State private var showTooltip1 = false
    @State private var showTooltip2 = false
    @State private var showTooltip3 = false

    var body: some View {
        VStack(spacing: 60) {
            Spacer()

            Button("功能说明") {
                withAnimation { showTooltip1.toggle() }
            }
            .floatingPopover(
                isPresented: $showTooltip1,
                config: PopoverConfig(direction: .bottom, maxWidth: 200)
            ) {
                Text("这是一个功能说明提示，点击空白处关闭")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button("操作提示") {
                withAnimation { showTooltip2.toggle() }
            }
            .floatingPopover(
                isPresented: $showTooltip2,
                config: PopoverConfig(direction: .bottom, maxWidth: 180)
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("长按可拖拽排序")
                        .font(.caption)
                }
            }

            Button("警告提示") {
                withAnimation { showTooltip3.toggle() }
            }
            .floatingPopover(
                isPresented: $showTooltip3,
                config: PopoverConfig(
                    direction: .top,
                    backgroundColor: Color.red.opacity(0.1),
                    maxWidth: 200
                )
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("此操作不可撤销")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("提示浮层")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Custom Style Demo

struct CustomStyleDemoView: View {
    @State private var showDark = false
    @State private var showColored = false
    @State private var showLarge = false

    var body: some View {
        VStack(spacing: 50) {
            Spacer()

            Button("深色风格") {
                withAnimation { showDark.toggle() }
            }
            .floatingPopover(
                isPresented: $showDark,
                config: PopoverConfig(
                    direction: .bottom,
                    backgroundColor: Color(.darkGray),
                    shadowRadius: 12
                )
            ) {
                Text("深色背景浮层")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            Button("彩色风格") {
                withAnimation { showColored.toggle() }
            }
            .floatingPopover(
                isPresented: $showColored,
                config: PopoverConfig(
                    direction: .bottom,
                    cornerRadius: 12,
                    backgroundColor: Color.blue.opacity(0.9)
                )
            ) {
                VStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("彩色主题")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
            }

            Button("大圆角风格") {
                withAnimation { showLarge.toggle() }
            }
            .floatingPopover(
                isPresented: $showLarge,
                config: PopoverConfig(
                    direction: .bottom,
                    arrowSize: 14,
                    cornerRadius: 16,
                    maxWidth: 280,
                    padding: 20
                )
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("大圆角风格")
                        .font(.headline)
                    Text("支持自定义圆角大小、箭头尺寸、内边距和最大宽度等参数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("自定义样式")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FloatingPopoverDemoView()
    }
}
