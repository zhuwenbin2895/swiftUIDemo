import SwiftUI
import UIKit

// MARK: - Demo Helper

struct TangramLayoutDemo<Layout: TGBaseLayout>: UIViewRepresentable {
    let makeLayout: (Layout) -> Void
    let height: CGFloat

    init(height: CGFloat = 200, _ makeLayout: @escaping (Layout) -> Void) {
        self.makeLayout = makeLayout
        self.height = height
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray6
        container.layer.cornerRadius = 8

        let layout = Layout()
        makeLayout(layout)
        layout.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(layout)

        NSLayoutConstraint.activate([
            layout.topAnchor.constraint(equalTo: container.topAnchor),
            layout.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            layout.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            layout.heightAnchor.constraint(equalToConstant: height)
        ])
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Demo Helper: Colored Label

private func makeLabel(_ text: String, color: UIColor, width: CGFloat = 80, height: CGFloat = 40) -> UILabel {
    let label = UILabel()
    label.text = text
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 14)
    label.textColor = .white
    label.backgroundColor = color
    label.layer.cornerRadius = 4
    label.clipsToBounds = true
    label.frame = CGRect(x: 0, y: 0, width: width, height: height)
    return label
}

private let colors: [UIColor] = [
    .systemRed, .systemBlue, .systemGreen, .systemOrange,
    .systemPurple, .systemTeal, .systemPink, .systemIndigo
]

// MARK: - Main Demo View

struct TangramKitDemoView: View {
    var body: some View {
        List {
            linearLayoutSection
            relativeLayoutSection
            tableLayoutSection
            flowLayoutSection
            floatLayoutSection
            systemIntegrationSection
            subviewManagementSection
            extensionSection
        }
        .navigationTitle("TangramKit 布局引擎")
    }

    // MARK: - Linear Layout Section

    var linearLayoutSection: some View {
        Section("线性布局 LinearLayout") {
            NavigationLink("垂直线性布局 + weight权重 + 比例 + offset") {
                LinearVerticalDemo()
            }
            NavigationLink("水平线性布局 + 对齐 + fill") {
                LinearHorizontalDemo()
            }
            NavigationLink("线性布局 useFrame 属性") {
                LinearUseFrameDemo()
            }
            NavigationLink("线性布局 layoutMargin 边距") {
                LinearMarginDemo()
            }
        }
    }

    // MARK: - Relative Layout Section

    var relativeLayoutSection: some View {
        Section("相对布局 RelativeLayout") {
            NavigationLink("leftOf / rightOf 约束") {
                RelativeHorizontalDemo()
            }
            NavigationLink("above / below 约束") {
                RelativeVerticalDemo()
            }
            NavigationLink("alignTop / alignBottom / alignLeft / alignRight") {
                RelativeAlignDemo()
            }
            NavigationLink("centerX / centerY 居中") {
                RelativeCenterDemo()
            }
        }
    }

    // MARK: - Table Layout Section

    var tableLayoutSection: some View {
        Section("表格布局 TableLayout") {
            NavigationLink("基本网格 3列") {
                TableBasicDemo()
            }
            NavigationLink("columnSpan 列合并") {
                TableColSpanDemo()
            }
            NavigationLink("rowSpan 行合并") {
                TableRowSpanDemo()
            }
            NavigationLink("复杂行列合并") {
                TableComplexDemo()
            }
        }
    }

    // MARK: - Flow Layout Section

    var flowLayoutSection: some View {
        Section("流式布局 FlowLayout") {
            NavigationLink("水平流式自动换行") {
                FlowHorizontalDemo()
            }
            NavigationLink("垂直流式自动换行") {
                FlowVerticalDemo()
            }
            NavigationLink("arrangedCount 每行数量限制") {
                FlowArrangedCountDemo()
            }
        }
    }

    // MARK: - Float Layout Section

    var floatLayoutSection: some View {
        Section("浮动布局 FloatLayout") {
            NavigationLink("水平浮动 (左浮+右浮混合)") {
                FloatHorizontalDemo()
            }
            NavigationLink("垂直浮动") {
                FloatVerticalDemo()
            }
            NavigationLink("noBoundaryLimit 无边界限制") {
                FloatNoBoundaryDemo()
            }
        }
    }

    // MARK: - System Integration Section

    var systemIntegrationSection: some View {
        Section("系统集成") {
            NavigationLink("SizeClasses 适配 (compact/regular)") {
                SizeClassesDemo()
            }
            NavigationLink("屏幕旋转自适应") {
                RotationAdaptiveDemo()
            }
            NavigationLink("尺寸评估系统 estimatedSize") {
                SizeEstimationDemo()
            }
            NavigationLink("CSS 盒子模型 Padding + Margin") {
                BoxModelDemo()
            }
            NavigationLink("layoutTarget: subviews vs all") {
                LayoutTargetDemo()
            }
        }
    }

    // MARK: - Subview Management Section

    var subviewManagementSection: some View {
        Section("子视图管理") {
            NavigationLink("widthRatio / heightRatio 宽高比例") {
                RatioDemo()
            }
            NavigationLink("offsetX / offsetY 布局偏移") {
                OffsetDemo()
            }
        }
    }

    // MARK: - Extension Section

    var extensionSection: some View {
        Section("扩展能力") {
            NavigationLink("全局/局部布局目标切换") {
                LayoutTargetDemo()
            }
            NavigationLink("XIB 接口桥接演示") {
                XIBBridgeDemo()
            }
            NavigationLink("边距缓存性能演示") {
                CachePerformanceDemo()
            }
        }
    }
}

// MARK: - Linear Layout Demos

struct LinearVerticalDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("垂直线性布局 + weight 权重分配")
                    .font(.headline)
                TangramLayoutDemo<TGLinearLayout>(height: 250) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("Weight 3", color: .systemRed, height: 30)
                    v1.tg.weight = 3

                    let v2 = makeLabel("Weight 1", color: .systemBlue, height: 30)
                    v2.tg.weight = 1

                    let v3 = makeLabel("Fixed 40pt", color: .systemGreen, height: 40)

                    let v4 = makeLabel("Weight 2", color: .systemOrange, height: 30)
                    v4.tg.weight = 2

                    [v1, v2, v3, v4].forEach { layout.addSubview($0) }
                }

                Text("垂直 + widthRatio 宽度比例")
                    .font(.headline)
                TangramLayoutDemo<TGLinearLayout>(height: 180) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("100%", color: .systemPurple, height: 35)
                    v1.tg.widthRatio = 1.0

                    let v2 = makeLabel("70% + right", color: .systemTeal, height: 35)
                    v2.tg.widthRatio = 0.7
                    v2.tg.horizontalGravity = .right

                    let v3 = makeLabel("50% + center", color: .systemPink, height: 35)
                    v3.tg.widthRatio = 0.5
                    v3.tg.horizontalGravity = .center

                    [v1, v2, v3].forEach { layout.addSubview($0) }
                }

                Text("垂直 + 对齐方式 (left/center/right/fill)")
                    .font(.headline)
                TangramLayoutDemo<TGLinearLayout>(height: 220) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("Left (默认)", color: .systemRed, height: 30)

                    let v2 = makeLabel("Center", color: .systemBlue, height: 30)
                    v2.tg.horizontalGravity = .center

                    let v3 = makeLabel("Right", color: .systemGreen, height: 30)
                    v3.tg.horizontalGravity = .right

                    let v4 = makeLabel("Fill 铺满", color: .systemOrange, height: 30)
                    v4.tg.horizontalGravity = .fill

                    let v5 = makeLabel("Offset +20 +10", color: .systemPurple, height: 30)
                    v5.tg.offsetX = 20
                    v5.tg.offsetY = 10

                    [v1, v2, v3, v4, v5].forEach { layout.addSubview($0) }
                }

                Text("垂直 + heightRatio 高度比例")
                    .font(.headline)
                TangramLayoutDemo<TGLinearLayout>(height: 200) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 4
                    layout.tgPadding = TGEdgeInsets(all: 8)

                    let v1 = makeLabel("heightRatio 0.3", color: .systemIndigo, height: 30)
                    v1.tg.heightRatio = 0.3

                    let v2 = makeLabel("heightRatio 0.2", color: .systemTeal, height: 30)
                    v2.tg.heightRatio = 0.2

                    let v3 = makeLabel("Fixed 40", color: .systemGray, height: 40)

                    [v1, v2, v3].forEach { layout.addSubview($0) }
                }
            }
            .padding()
        }
        .navigationTitle("垂直线性布局")
    }
}

struct LinearHorizontalDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("水平线性布局 + weight 权重")
                    .font(.headline)
                TangramLayoutDemo<TGLinearLayout>(height: 80) { layout in
                    layout.orientation = .horizontal
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("W3", color: .systemRed, width: 50, height: 50)
                    v1.tg.weight = 3

                    let v2 = makeLabel("W1", color: .systemBlue, width: 50, height: 50)
                    v2.tg.weight = 1

                    let v3 = makeLabel("W2", color: .systemGreen, width: 50, height: 50)
                    v3.tg.weight = 2

                    [v1, v2, v3].forEach { layout.addSubview($0) }
                }

                Text("水平 + 对齐方式 + fill")
                    .font(.headline)
                TangramLayoutDemo<TGLinearLayout>(height: 150) { layout in
                    layout.orientation = .horizontal
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("Top", color: .systemRed, width: 70, height: 30)
                    v1.tg.verticalGravity = .top

                    let v2 = makeLabel("Center", color: .systemBlue, width: 70, height: 30)
                    v2.tg.verticalGravity = .center

                    let v3 = makeLabel("Bottom", color: .systemGreen, width: 70, height: 30)
                    v3.tg.verticalGravity = .bottom

                    let v4 = makeLabel("Fill", color: .systemOrange, width: 70, height: 30)
                    v4.tg.verticalGravity = .fill

                    [v1, v2, v3, v4].forEach { layout.addSubview($0) }
                }

                Text("水平 + widthRatio + heightRatio")
                    .font(.headline)
                TangramLayoutDemo<TGLinearLayout>(height: 100) { layout in
                    layout.orientation = .horizontal
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("60%W", color: .systemPurple, width: 60, height: 40)
                    v1.tg.widthRatio = 0.6

                    let v2 = makeLabel("30%W", color: .systemTeal, width: 60, height: 40)
                    v2.tg.widthRatio = 0.3

                    let v3 = makeLabel("FillH", color: .systemPink, width: 30, height: 40)
                    v3.tg.heightRatio = 1.0

                    [v1, v2, v3].forEach { layout.addSubview($0) }
                }
            }
            .padding()
        }
        .navigationTitle("水平线性布局")
    }
}

struct LinearUseFrameDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("useFrame 属性")
                    .font(.headline)
                Text("设置 useFrame = true 的子视图使用自己的原始 frame，不受布局控制")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TangramLayoutDemo<TGLinearLayout>(height: 200) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("Layout managed", color: .systemBlue, height: 30)
                    // v1 由布局管理

                    let v2 = makeLabel("useFrame = true", color: .systemRed, height: 30)
                    v2.frame = CGRect(x: 50, y: 80, width: 200, height: 50)
                    v2.tg.useFrame = true
                    // v2 使用自己的 frame，不受布局影响

                    let v3 = makeLabel("Layout managed 2", color: .systemGreen, height: 30)
                    // v3 由布局管理

                    [v1, v2, v3].forEach { layout.addSubview($0) }
                }
            }
            .padding()
        }
        .navigationTitle("useFrame 演示")
    }
}

struct LinearMarginDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("layoutMargin 边距")
                    .font(.headline)

                TangramLayoutDemo<TGLinearLayout>(height: 250) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 4
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("margin 20 all", color: .systemRed, height: 30)
                    v1.tg.layoutMargin = TGEdgeInsets(all: 20)
                    v1.tg.horizontalGravity = .fill

                    let v2 = makeLabel("margin L40 R10", color: .systemBlue, height: 30)
                    v2.tg.layoutMargin = TGEdgeInsets(top: 5, left: 40, bottom: 5, right: 10)
                    v2.tg.horizontalGravity = .fill

                    let v3 = makeLabel("margin T20 B5", color: .systemGreen, height: 30)
                    v3.tg.layoutMargin = TGEdgeInsets(top: 20, left: 10, bottom: 5, right: 10)
                    v3.tg.horizontalGravity = .fill

                    let v4 = makeLabel("No margin", color: .systemOrange, height: 30)
                    v4.tg.horizontalGravity = .fill

                    [v1, v2, v3, v4].forEach { layout.addSubview($0) }
                }
            }
            .padding()
        }
        .navigationTitle("layoutMargin 演示")
    }
}

// MARK: - Relative Layout Demos

struct RelativeHorizontalDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("相对布局: leftOf / rightOf 约束")
                    .font(.headline)

                TangramLayoutDemo<TGRelativeLayout>(height: 200) { layout in
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let a = makeLabel("A", color: .systemRed, width: 60, height: 60)
                    a.tag = 1

                    let b = makeLabel("leftOf A", color: .systemBlue, width: 80, height: 40)
                    b.tag = 2
                    b.tg.leftOf = a

                    let c = makeLabel("rightOf A", color: .systemGreen, width: 80, height: 40)
                    c.tag = 3
                    c.tg.rightOf = a

                    let d = makeLabel("leftOf B", color: .systemOrange, width: 70, height: 30)
                    d.tag = 4
                    d.tg.leftOf = b

                    [a, b, c, d].forEach { layout.addSubview($0) }
                }

                Text("说明: A 在默认位置(左上方)，B 在 A 的左侧，C 在 A 的右侧，D 在 B 的左侧")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("leftOf / rightOf")
    }
}

struct RelativeVerticalDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("相对布局: above / below 约束")
                    .font(.headline)

                TangramLayoutDemo<TGRelativeLayout>(height: 220) { layout in
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let a = makeLabel("A (anchor)", color: .systemRed, width: 80, height: 50)
                    a.frame.origin = CGPoint(x: 120, y: 60)

                    let b = makeLabel("above A", color: .systemBlue, width: 80, height: 30)
                    b.tg.above = a
                    b.tg.alignLeft = a

                    let c = makeLabel("below A", color: .systemGreen, width: 80, height: 40)
                    c.tg.below = a
                    c.tg.alignLeft = a

                    let d = makeLabel("below C", color: .systemOrange, width: 80, height: 30)
                    d.tg.below = c
                    d.tg.alignLeft = c

                    [a, b, c, d].forEach { layout.addSubview($0) }
                }

                Text("说明: A 为锚点，B 在 A 上方，C 在 A 下方，D 在 C 下方")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("相对布局: 链式依赖")
                    .font(.headline)
                TangramLayoutDemo<TGRelativeLayout>(height: 180) { layout in
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let a = makeLabel("A", color: .systemRed, width: 60, height: 60)

                    let b = makeLabel("rightOf A", color: .systemBlue, width: 70, height: 40)
                    b.tg.rightOf = a
                    b.tg.alignTop = a

                    let c = makeLabel("below B", color: .systemGreen, width: 70, height: 40)
                    c.tg.below = b
                    c.tg.alignLeft = b

                    let d = makeLabel("rightOf C", color: .systemOrange, width: 60, height: 40)
                    d.tg.rightOf = c
                    d.tg.alignTop = c

                    [a, b, c, d].forEach { layout.addSubview($0) }
                }

                Text("说明: 形成链式布局 A → B → C → D，每个视图依赖前一个")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("above / below")
    }
}

struct RelativeAlignDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("相对布局: alignTop / alignBottom / alignLeft / alignRight")
                    .font(.headline)

                TangramLayoutDemo<TGRelativeLayout>(height: 200) { layout in
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let a = makeLabel("A", color: .systemRed, width: 80, height: 80)
                    a.frame.origin = CGPoint(x: 130, y: 40)

                    let b = makeLabel("alignTop A", color: .systemBlue, width: 80, height: 30)
                    b.tg.alignTop = a
                    b.tg.rightOf = a

                    let c = makeLabel("alignBottom A", color: .systemGreen, width: 80, height: 30)
                    c.tg.alignBottom = a
                    c.tg.rightOf = a

                    let d = makeLabel("alignLeft A", color: .systemOrange, width: 80, height: 30)
                    d.tg.alignLeft = a
                    d.tg.below = a

                    let e = makeLabel("alignRight A", color: .systemPurple, width: 80, height: 30)
                    e.tg.alignRight = a
                    e.tg.below = a

                    [a, b, c, d, e].forEach { layout.addSubview($0) }
                }

                Text("说明: 以 A 为参考，各子视图分别对齐 A 的上下左右边界")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("对齐约束")
    }
}

struct RelativeCenterDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("相对布局: centerX / centerY 居中")
                    .font(.headline)

                TangramLayoutDemo<TGRelativeLayout>(height: 250) { layout in
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let centerLabel = makeLabel("Center", color: .systemRed, width: 60, height: 60)
                    centerLabel.tg.centerX = true
                    centerLabel.tg.centerY = true

                    let topLabel = makeLabel("Top Center", color: .systemBlue, width: 100, height: 30)
                    topLabel.tg.centerX = true

                    let bottomLabel = makeLabel("Bottom Center", color: .systemGreen, width: 100, height: 30)
                    bottomLabel.tg.centerX = true
                    bottomLabel.tg.alignBottom = centerLabel
                    bottomLabel.tg.above = centerLabel

                    let leftLabel = makeLabel("Left Center", color: .systemOrange, width: 90, height: 30)
                    leftLabel.tg.centerY = true

                    let rightLabel = makeLabel("Right Center", color: .systemPurple, width: 90, height: 30)
                    rightLabel.tg.centerY = true
                    rightLabel.tg.horizontalGravity = .right

                    [centerLabel, topLabel, bottomLabel, leftLabel, rightLabel].forEach { layout.addSubview($0) }
                }
            }
            .padding()
        }
        .navigationTitle("居中定位")
    }
}

// MARK: - Table Layout Demos

struct TableBasicDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("表格布局: 3列基本网格")
                    .font(.headline)

                TangramLayoutDemo<TGTableLayout>(height: 200) { layout in
                    layout.columns = 3
                    layout.rowSpacing = 8
                    layout.columnSpacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    for i in 0..<9 {
                        let label = makeLabel("\(i+1)", color: colors[i % colors.count], width: 60, height: 50)
                        layout.addSubview(label)
                    }
                }

                Text("表格布局: 4列网格")
                    .font(.headline)
                TangramLayoutDemo<TGTableLayout>(height: 160) { layout in
                    layout.columns = 4
                    layout.rowSpacing = 8
                    layout.columnSpacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    for i in 0..<8 {
                        let label = makeLabel("\(i+1)", color: colors[i % colors.count], width: 50, height: 50)
                        layout.addSubview(label)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("基本表格")
    }
}

struct TableColSpanDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("表格布局: columnSpan 列合并")
                    .font(.headline)

                TangramLayoutDemo<TGTableLayout>(height: 160) { layout in
                    layout.columns = 3
                    layout.rowSpacing = 8
                    layout.columnSpacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let h = makeLabel("Header (colSpan=3)", color: .systemRed, width: 60, height: 40)
                    h.tg.columnSpan = 3

                    let c1 = makeLabel("1", color: .systemBlue, width: 60, height: 40)
                    let c2 = makeLabel("2", color: .systemGreen, width: 60, height: 40)
                    let c3 = makeLabel("3", color: .systemOrange, width: 60, height: 40)

                    let footer = makeLabel("Footer (colSpan=2)", color: .systemPurple, width: 60, height: 40)
                    footer.tg.columnSpan = 2

                    let extra = makeLabel("Extra", color: .systemTeal, width: 60, height: 40)

                    [h, c1, c2, c3, footer, extra].forEach { layout.addSubview($0) }
                }

                Text("说明: 第一行表头占3列，最后一行footer占2列+extra占1列")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("列合并")
    }
}

struct TableRowSpanDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("表格布局: rowSpan 行合并")
                    .font(.headline)

                TangramLayoutDemo<TGTableLayout>(height: 220) { layout in
                    layout.columns = 3
                    layout.rowSpacing = 4
                    layout.columnSpacing = 4
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let sidebar = makeLabel("Sidebar\nrowSpan=3", color: .systemRed, width: 60, height: 60)
                    sidebar.tg.rowSpan = 3

                    let r1 = makeLabel("R1C2", color: .systemBlue, width: 60, height: 40)
                    let r2 = makeLabel("R1C3", color: .systemGreen, width: 60, height: 40)

                    let r3 = makeLabel("R2C2", color: .systemOrange, width: 60, height: 40)
                    let r4 = makeLabel("R2C3", color: .systemPurple, width: 60, height: 40)

                    let r5 = makeLabel("R3C2", color: .systemTeal, width: 60, height: 40)
                    let r6 = makeLabel("R3C3", color: .systemPink, width: 60, height: 40)

                    [sidebar, r1, r2, r3, r4, r5, r6].forEach { layout.addSubview($0) }
                }

                Text("说明: 第一列 Sidebar 占3行高度")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("行合并")
    }
}

struct TableComplexDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("表格布局: 复杂行列混合合并")
                    .font(.headline)

                TangramLayoutDemo<TGTableLayout>(height: 200) { layout in
                    layout.columns = 3
                    layout.rowSpacing = 6
                    layout.columnSpacing = 6
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let corner = makeLabel("Corner\nRow2\nCol2", color: .systemRed, width: 60, height: 60)
                    corner.tg.rowSpan = 2
                    corner.tg.columnSpan = 2

                    let right = makeLabel("Right\nRow2\nCol1", color: .systemBlue, width: 60, height: 60)
                    right.tg.rowSpan = 2

                    let bottom = makeLabel("Bottom\nRow1\nCol2", color: .systemGreen, width: 60, height: 40)
                    bottom.tg.columnSpan = 2

                    [corner, right, bottom].forEach { layout.addSubview($0) }
                }

                Text("说明: 左上角占2×2，右上角占2行×1列，底部占1行×2列")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("复杂合并")
    }
}

// MARK: - Flow Layout Demos

struct FlowHorizontalDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("流式布局: 水平自动换行")
                    .font(.headline)

                TangramLayoutDemo<TGFlowLayout>(height: 250) { layout in
                    layout.orientation = .horizontal
                    layout.itemSpacing = 8
                    layout.lineSpacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let widths: [CGFloat] = [100, 60, 80, 40, 120, 70, 90, 50, 110, 65, 85, 45]
                    for i in 0..<12 {
                        let label = makeLabel("标签\(i+1)", color: colors[i % colors.count], width: widths[i], height: 32)
                        layout.addSubview(label)
                    }
                }

                Text("说明: 不同宽度标签自动换行排列，类似 CSS flex-wrap")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("水平流式")
    }
}

struct FlowVerticalDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("流式布局: 垂直自动换列")
                    .font(.headline)

                TangramLayoutDemo<TGFlowLayout>(height: 250) { layout in
                    layout.orientation = .vertical
                    layout.itemSpacing = 8
                    layout.lineSpacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let heights: [CGFloat] = [40, 60, 30, 80, 45, 55, 35, 70, 50, 65, 40, 55]
                    for i in 0..<12 {
                        let label = makeLabel("V\(i+1)", color: colors[i % colors.count], width: 60, height: heights[i])
                        layout.addSubview(label)
                    }
                }

                Text("说明: 不同高度视图垂直排列，超出容器高度自动换列")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("垂直流式")
    }
}

struct FlowArrangedCountDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("流式布局: arrangedCount 每行限制3个")
                    .font(.headline)

                TangramLayoutDemo<TGFlowLayout>(height: 200) { layout in
                    layout.orientation = .horizontal
                    layout.itemSpacing = 8
                    layout.lineSpacing = 8
                    layout.arrangedCount = 3
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    for i in 0..<9 {
                        let label = makeLabel("\(i+1)", color: colors[i % colors.count], width: 70, height: 40)
                        layout.addSubview(label)
                    }
                }

                Text("说明: 每行固定3个元素，自动换行")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("流式布局: arrangedCount 每行限制2个")
                    .font(.headline)
                TangramLayoutDemo<TGFlowLayout>(height: 250) { layout in
                    layout.orientation = .horizontal
                    layout.itemSpacing = 8
                    layout.lineSpacing = 8
                    layout.arrangedCount = 2
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    for i in 0..<6 {
                        let label = makeLabel("Item \(i+1)", color: colors[i % colors.count], width: 90, height: 50)
                        layout.addSubview(label)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("数量限制")
    }
}

// MARK: - Float Layout Demos

struct FloatHorizontalDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("浮动布局: 水平浮动 (左浮+右浮混合)")
                    .font(.headline)

                TangramLayoutDemo<TGFloatLayout>(height: 280) { layout in
                    layout.orientation = .horizontal
                    layout.itemSpacing = 4
                    layout.lineSpacing = 4
                    layout.tgPadding = TGEdgeInsets(all: 8)

                    let sizes: [(CGFloat, CGFloat)] = [(100, 40), (80, 60), (60, 30), (120, 50), (70, 45), (90, 55), (50, 35), (110, 40), (85, 65), (65, 30)]
                    for i in 0..<sizes.count {
                        let label = makeLabel("F\(i+1)", color: colors[i % colors.count], width: sizes[i].0, height: sizes[i].1)
                        label.tg.horizontalGravity = i % 3 == 0 ? .right : .left
                        layout.addSubview(label)
                    }
                }

                Text("说明: 部分视图右浮(每3个中的第1个)，其余左浮，自动寻找可用空间")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("水平浮动")
    }
}

struct FloatVerticalDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("浮动布局: 垂直浮动")
                    .font(.headline)

                TangramLayoutDemo<TGFloatLayout>(height: 250) { layout in
                    layout.orientation = .vertical
                    layout.itemSpacing = 8
                    layout.lineSpacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let configs: [(String, TGGravity.Horz)] = [
                        ("Left", .left), ("Center", .center),
                        ("Right", .right), ("Left2", .left),
                        ("Fill", .fill), ("Center2", .center),
                    ]
                    for (text, gravity) in configs {
                        let label = makeLabel(text, color: colors.randomElement()!, width: 80, height: 30)
                        label.tg.horizontalGravity = gravity
                        layout.addSubview(label)
                    }
                }

                Text("说明: 垂直排列，不同水平对齐方式的视图逐行排列")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("垂直浮动")
    }
}

struct FloatNoBoundaryDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("浮动布局: noBoundaryLimit 无边界限制")
                    .font(.headline)

                TangramLayoutDemo<TGFloatLayout>(height: 200) { layout in
                    layout.orientation = .horizontal
                    layout.itemSpacing = 4
                    layout.lineSpacing = 4
                    layout.noBoundaryLimit = true
                    layout.tgPadding = TGEdgeInsets(all: 8)

                    let widths: [CGFloat] = [180, 120, 200, 160, 140, 180, 100, 150]
                    for i in 0..<widths.count {
                        let label = makeLabel("Wide \(i+1)", color: colors[i % colors.count], width: widths[i], height: 35)
                        label.tg.horizontalGravity = i.isMultiple(of: 2) ? .left : .right
                        layout.addSubview(label)
                    }
                }

                Text("说明: noBoundaryLimit=true 允许视图超出容器边界（向下无限延伸找空间）")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("无边界限制")
    }
}

// MARK: - System Integration Demos

struct SizeClassesDemo: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("当前 SizeClass: \(horizontalSizeClass == .compact ? "Compact" : "Regular")")
                    .font(.headline)

                TangramLayoutDemo<TGLinearLayout>(height: 180) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    layout.sizeClassConfigs[.compactWidth] = {
                        layout.orientation = .vertical
                        layout.spacing = 8
                    }
                    layout.sizeClassConfigs[.regularWidth] = {
                        layout.orientation = .horizontal
                        layout.spacing = 16
                    }

                    for i in 0..<4 {
                        let label = makeLabel("View \(i+1)", color: colors[i % colors.count], width: 80, height: 40)
                        layout.addSubview(label)
                    }
                }

                Text("说明: compact宽度时垂直排列，regular宽度时水平排列")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("SizeClasses")
    }
}

struct RotationAdaptiveDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("屏幕旋转自适应")
                    .font(.headline)
                Text("旋转设备查看效果：bounds宽>高时(横屏)使用垂直布局，bounds宽<=高时(竖屏)使用水平布局")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TangramLayoutDemo<TGRotationAdaptiveLayout>(height: 200) { layout in
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    for i in 0..<5 {
                        let label = makeLabel("View \(i+1)", color: colors[i % colors.count], width: 80, height: 35)
                        label.tg.weight = 1
                        layout.addSubview(label)
                    }
                }

                Text("说明: TGRotationAdaptiveLayout 继承自 TGLinearLayout，根据 bounds 宽高比自动切换方向")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("旋转自适应")
    }
}

struct SizeEstimationDemo: View {
    @State private var estimatedSize: CGSize = .zero
    @State private var testWidth: CGFloat = 300
    @State private var testHeight: CGFloat = 200

    var body: some View {
        VStack(spacing: 16) {
            Text("尺寸评估系统 estimatedSize")
                .font(.headline)

            HStack {
                Text("Max Width:")
                Slider(value: $testWidth, in: 100...500, step: 10)
                Text("\(Int(testWidth))")
                    .font(.caption)
                    .monospacedDigit()
            }
            .padding(.horizontal)

            HStack {
                Text("Max Height:")
                Slider(value: $testHeight, in: 100...500, step: 10)
                Text("\(Int(testHeight))")
                    .font(.caption)
                    .monospacedDigit()
            }
            .padding(.horizontal)

            Button("评估尺寸") {
                let layout = TGLinearLayout()
                layout.orientation = .vertical
                layout.spacing = 8
                layout.tgPadding = TGEdgeInsets(all: 12)

                for i in 0..<5 {
                    let label = makeLabel("Item \(i+1)", color: colors[i % colors.count], width: 100, height: 35)
                    layout.addSubview(label)
                }

                estimatedSize = TGSizeEstimator.estimatedSize(for: layout, maxWidth: testWidth, maxHeight: testHeight)
            }
            .buttonStyle(.borderedProminent)

            Text("评估结果: \(String(format: "%.0f", estimatedSize.width)) x \(String(format: "%.0f", estimatedSize.height))")
                .font(.title3)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            Text("说明: 传入不同 maxWidth/maxHeight，评估布局所需的最小尺寸")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .navigationTitle("尺寸评估")
    }
}

struct BoxModelDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("CSS 盒子模型完整演示")
                    .font(.headline)
                Text("Padding(内边距) + Margin(外边距)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TangramLayoutDemo<TGLinearLayout>(height: 300) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 4
                    layout.tgPadding = TGEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                    layout.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)

                    let v1 = makeLabel("Padding+Margin", color: .systemRed, height: 40)
                    v1.tg.layoutMargin = TGEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                    v1.tg.horizontalGravity = .fill

                    let v2 = makeLabel("Margin Only", color: .systemBlue, height: 40)
                    v2.tg.layoutMargin = TGEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
                    v2.tg.horizontalGravity = .fill

                    let v3 = makeLabel("Nested Padding Effect", color: .systemGreen, height: 40)
                    v3.tg.padding = TGEdgeInsets(all: 15)

                    let v4 = makeLabel("Full Box Model", color: .systemOrange, height: 40)
                    v4.tg.layoutMargin = TGEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
                    v4.tg.padding = TGEdgeInsets(all: 5)

                    [v1, v2, v3, v4].forEach { layout.addSubview($0) }
                }

                Text("说明: 黄色半透明区域 = 布局 Padding(20)，子视图各自有不同 Margin")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("CSS盒子模型")
    }
}

struct LayoutTargetDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("layoutTarget: .subviews vs .all")
                    .font(.headline)
                Text("subviews 模式：忽略 useFrame=true 的隐藏视图")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TangramLayoutDemo<TGLinearLayout>(height: 120) { layout in
                    layout.orientation = .horizontal
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)
                    layout.tgLayoutTarget = .subviews

                    let v1 = makeLabel("Managed 1", color: .systemBlue, width: 70, height: 40)
                    let v2 = makeLabel("useFrame", color: .systemRed, width: 70, height: 40)
                    v2.tg.useFrame = true
                    v2.frame = CGRect(x: 50, y: 10, width: 80, height: 30)
                    let v3 = makeLabel("Managed 2", color: .systemGreen, width: 70, height: 40)

                    [v1, v2, v3].forEach { layout.addSubview($0) }
                }

                Text("all 模式：只忽略隐藏视图，useFrame 视图也参与布局")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TangramLayoutDemo<TGLinearLayout>(height: 80) { layout in
                    layout.orientation = .horizontal
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)
                    layout.tgLayoutTarget = .all

                    let v1 = makeLabel("All 1", color: .systemBlue, width: 70, height: 40)
                    let v2 = makeLabel("All 2", color: .systemGreen, width: 70, height: 40)

                    [v1, v2].forEach { layout.addSubview($0) }
                }
            }
            .padding()
        }
        .navigationTitle("布局目标")
    }
}

// MARK: - Subview Management Demos

struct RatioDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("widthRatio / heightRatio 宽高比计算")
                    .font(.headline)

                TangramLayoutDemo<TGLinearLayout>(height: 220) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("width 100%", color: .systemRed, height: 40)
                    v1.tg.widthRatio = 1.0

                    let v2 = makeLabel("width 75% + height 20%", color: .systemBlue, height: 30)
                    v2.tg.widthRatio = 0.75
                    v2.tg.heightRatio = 0.2

                    let v3 = makeLabel("width 50% + center", color: .systemGreen, height: 35)
                    v3.tg.widthRatio = 0.5
                    v3.tg.horizontalGravity = .center

                    let v4 = makeLabel("width 90% + right", color: .systemOrange, height: 30)
                    v4.tg.widthRatio = 0.9
                    v4.tg.horizontalGravity = .right

                    [v1, v2, v3, v4].forEach { layout.addSubview($0) }
                }

                Text("horizontal + widthRatio + heightRatio")
                    .font(.headline)
                TangramLayoutDemo<TGLinearLayout>(height: 120) { layout in
                    layout.orientation = .horizontal
                    layout.spacing = 8
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("W50% H100%", color: .systemPurple, width: 60, height: 40)
                    v1.tg.widthRatio = 0.5
                    v1.tg.heightRatio = 1.0

                    let v2 = makeLabel("W30% H60%", color: .systemTeal, width: 60, height: 40)
                    v2.tg.widthRatio = 0.3
                    v2.tg.heightRatio = 0.6

                    [v1, v2].forEach { layout.addSubview($0) }
                }
            }
            .padding()
        }
        .navigationTitle("宽高比例")
    }
}

struct OffsetDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("offsetX / offsetY 布局偏移")
                    .font(.headline)

                TangramLayoutDemo<TGLinearLayout>(height: 250) { layout in
                    layout.orientation = .vertical
                    layout.spacing = 4
                    layout.tgPadding = TGEdgeInsets(all: 12)

                    let v1 = makeLabel("Normal position", color: .systemRed, height: 25)

                    let v2 = makeLabel("offsetX +20", color: .systemBlue, height: 25)
                    v2.tg.offsetX = 20

                    let v3 = makeLabel("offsetX +40, offsetY +10", color: .systemGreen, height: 25)
                    v3.tg.offsetX = 40
                    v3.tg.offsetY = 10

                    let v4 = makeLabel("offsetX -10", color: .systemOrange, height: 25)
                    v4.tg.offsetX = -10

                    let v5 = makeLabel("offsetY +20", color: .systemPurple, height: 25)
                    v5.tg.offsetY = 20

                    let v6 = makeLabel("offsetX +60 offsetY -5", color: .systemTeal, height: 25)
                    v6.tg.offsetX = 60
                    v6.tg.offsetY = -5

                    [v1, v2, v3, v4, v5, v6].forEach { layout.addSubview($0) }
                }

                Text("说明: 每个视图在原始布局位置上叠加 offset 偏移量")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("布局偏移")
    }
}

// MARK: - Extension Demos

struct XIBBridgeDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("XIB / Storyboard 接口桥接")
                    .font(.headline)

                Text("TGBaseLayout 实现了以下 XIB 支持接口:")
                    .font(.subheadline)

                Group {
                    Text("awakeFromNib()")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    Text("  从 XIB 加载后自动刷新布局缓存")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("prepareForInterfaceBuilder()")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    Text("  Xcode IB 预览时自动执行布局")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("SwiftUI 桥接组件:")
                    .font(.subheadline)
                Group {
                    Text("TGLayoutRepresentable<T>")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.green)
                    Text("  通用 UIViewRepresentable，将任意 TGBaseLayout 子类桥接到 SwiftUI")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("TGLayoutWrapper")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.green)
                    Text("  容器式包装器，通过闭包创建布局")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("所有 Demo 中的布局均通过这些桥接组件在 SwiftUI 中渲染")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("XIB桥接")
    }
}

struct CachePerformanceDemo: View {
    @State private var layoutCount = 0
    @State private var timer: Timer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("边距缓存性能演示")
                    .font(.headline)
                Text("TGBaseLayout 内部使用 Dictionary 缓存各视图的 margin 计算结果")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Group {
                    Text("cachedMargin(for:) 方法:")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    Text("  首次访问时计算并缓存，后续直接返回缓存值")

                    Text("invalidateLayoutCache() 方法:")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    Text("  清空所有缓存并触发重新布局")

                    Text("traitCollectionDidChange(:)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    Text("  SizeClass 变化时自动刷新缓存")
                }
                .padding(.horizontal)

                Button("模拟100次布局(演示缓存效果)") {
                    let layout = TGLinearLayout()
                    layout.orientation = .vertical
                    for i in 0..<20 {
                        let v = UILabel()
                        v.text = "View \(i)"
                        v.tg.layoutMargin = TGEdgeInsets(all: CGFloat((i % 5) * 2 + 2))
                        layout.addSubview(v)
                    }

                    let start = CFAbsoluteTimeGetCurrent()
                    for _ in 0..<100 {
                        layout.setNeedsLayout()
                        layout.layoutIfNeeded()
                    }
                    let elapsed = CFAbsoluteTimeGetCurrent() - start
                    layoutCount = Int(elapsed * 1000)
                }
                .buttonStyle(.borderedProminent)

                if layoutCount > 0 {
                    Text("100次布局耗时: \(layoutCount)ms")
                        .font(.title3)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("缓存性能")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TangramKitDemoView()
    }
}
