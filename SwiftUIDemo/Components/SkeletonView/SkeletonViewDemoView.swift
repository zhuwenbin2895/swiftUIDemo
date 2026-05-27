import SwiftUI
import UIKit

struct SkeletonViewDemoView: View {
    var body: some View {
        List {
            Section("动画效果") {
                NavigationLink("从左向右扫光") {
                    ShimmerDemoView(animation: .shimmerLeftToRight, title: "从左向右扫光")
                }
                NavigationLink("从右向左扫光") {
                    ShimmerDemoView(animation: .shimmerRightToLeft, title: "从右向左扫光")
                }
                NavigationLink("从上向下扫光") {
                    ShimmerDemoView(animation: .shimmerTopToBottom, title: "从上向下扫光")
                }
                NavigationLink("渐变闪烁动画") {
                    ShimmerDemoView(animation: .gradientFade, title: "渐变闪烁动画")
                }
                NavigationLink("脉冲动画") {
                    ShimmerDemoView(animation: .pulse, title: "脉冲动画")
                }
            }

            Section("骨架样式") {
                NavigationLink("实体颜色骨架") {
                    SolidColorSkeletonDemo()
                }
                NavigationLink("渐变色骨架") {
                    GradientSkeletonDemo()
                }
                NavigationLink("多行文字骨架") {
                    MultilineSkeletonDemo()
                }
                NavigationLink("圆形头像骨架") {
                    AvatarSkeletonDemo()
                }
                NavigationLink("矩形卡片骨架") {
                    CardSkeletonDemo()
                }
                NavigationLink("自定义颜色骨架") {
                    CustomColorSkeletonDemo()
                }
            }

            Section("智能布局") {
                NavigationLink("嵌套视图递归骨架") {
                    NestedViewSkeletonDemo()
                }
                NavigationLink("表格单元格骨架") {
                    TableCellSkeletonDemo()
                }
                NavigationLink("自动计算内容区域") {
                    AutoLayoutSkeletonDemo()
                }
            }

            Section("集合视图") {
                NavigationLink("列表自动骨架") {
                    TableViewSkeletonDemo()
                }
                NavigationLink("网格自动骨架") {
                    CollectionViewSkeletonDemo()
                }
                NavigationLink("Header/Footer 骨架") {
                    HeaderFooterSkeletonDemo()
                }
            }

            Section("触发控制") {
                NavigationLink("手动显示/隐藏") {
                    ManualControlSkeletonDemo()
                }
                NavigationLink("数据加载自动隐藏") {
                    AutoHideSkeletonDemo()
                }
                NavigationLink("独立视图控制") {
                    IndependentControlDemo()
                }
            }

            Section("扩展功能") {
                NavigationLink("骨架大小配置") {
                    SizeConfigSkeletonDemo()
                }
                NavigationLink("圆角独立控制") {
                    CornerRadiusSkeletonDemo()
                }
                NavigationLink("骨架与占位图结合") {
                    PlaceholderSkeletonDemo()
                }
                NavigationLink("StackView 骨架") {
                    StackViewSkeletonDemo()
                }
            }
        }
        .navigationTitle("SkeletonView")
    }
}

// MARK: - Shimmer Demo
struct ShimmerDemoView: View {
    let animation: SkeletonAnimationStyle
    let title: String
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ForEach(0..<4, id: \.self) { _ in
                            SkeletonCardView(animation: animation)
                                .padding(.horizontal)
                        }
                    } else {
                        ForEach(0..<4, id: \.self) { i in
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text("用户 \(i + 1)").font(.headline)
                                    Text("数据已加载完成").font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Solid Color Skeleton Demo
struct SolidColorSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 200)
                        .skeleton(
                            isActive: isLoading,
                            style: SkeletonViewStyle(baseColor: Color(UIColor.systemGray5)),
                            animation: .none
                        )
                        .padding(.horizontal)

                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 50, height: 50)
                                .skeleton(
                                    isActive: isLoading,
                                    style: SkeletonViewStyle(shape: .circle),
                                    animation: .none
                                )

                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(height: 14)
                                    .skeleton(isActive: isLoading, animation: .none)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: 150, height: 12)
                                    .skeleton(isActive: isLoading, animation: .none)
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !isLoading {
                        loadedContent
                    }
                }
            }
        }
        .navigationTitle("实体颜色骨架")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var loadedContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .foregroundColor(.blue)
                .padding(.horizontal)

            ForEach(0..<3, id: \.self) { i in
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("用户 \(i + 1)")
                            .font(.headline)
                        Text("这是加载完成后的内容")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Gradient Skeleton Demo
struct GradientSkeletonDemo: View {
    @State private var isLoading = true
    @State private var startColor: Color = Color(UIColor.systemGray5)
    @State private var endColor: Color = .white

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            HStack {
                Text("起始色")
                ColorPicker("", selection: $startColor)
                Spacer()
                Text("结束色")
                ColorPicker("", selection: $endColor)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ForEach(0..<5, id: \.self) { _ in
                            SkeletonCardView(
                                style: SkeletonViewStyle(
                                    baseColor: startColor,
                                    highlightColor: endColor
                                ),
                                animation: .shimmerLeftToRight
                            )
                            .padding(.horizontal)
                        }
                    } else {
                        ForEach(0..<5, id: \.self) { i in
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.purple)
                                VStack(alignment: .leading) {
                                    Text("内容 \(i + 1)").font(.headline)
                                    Text("渐变骨架数据已加载").font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle("渐变色骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Multiline Skeleton Demo
struct MultilineSkeletonDemo: View {
    @State private var lineCount: Double = 4
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            HStack {
                Text("行数: \(Int(lineCount))")
                Slider(value: $lineCount, in: 1...8, step: 1)
            }
            .padding(.horizontal)

            if isLoading {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("标题骨架").font(.caption).foregroundColor(.secondary)
                        SkeletonRowView(
                            lineCount: 1,
                            lineHeight: 18,
                            style: SkeletonViewStyle(cornerRadius: 4),
                            animation: .shimmerLeftToRight
                        )
                        .frame(height: 18)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("多行内容骨架 (行高递减)").font(.caption).foregroundColor(.secondary)
                        SkeletonRowView(
                            lineCount: Int(lineCount),
                            lineHeight: 12,
                            spacing: 10,
                            lastLineWidth: 0.6,
                            style: SkeletonViewStyle(cornerRadius: 4),
                            animation: .shimmerLeftToRight
                        )
                        .frame(height: CGFloat(Int(lineCount)) * 22)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("段落骨架").font(.caption).foregroundColor(.secondary)
                        SkeletonRowView(
                            lineCount: 6,
                            lineHeight: 10,
                            spacing: 8,
                            lastLineWidth: 0.45,
                            style: SkeletonViewStyle(cornerRadius: 3),
                            animation: .shimmerLeftToRight
                        )
                        .frame(height: 108)
                    }
                    .padding(.horizontal)
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("加载完成的标题")
                        .font(.title2.bold())
                    Text("这是加载完成后显示的多行文本内容。骨架屏会根据行数自动生成对应数量的占位行，每行的高度会轻微递减，最后一行宽度较短，模拟真实文本的效果。")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("多行文字骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Avatar Skeleton Demo
struct AvatarSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 20) {
                        ForEach([32, 48, 64, 80], id: \.self) { size in
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: CGFloat(size), height: CGFloat(size))
                                    .skeleton(
                                        isActive: isLoading,
                                        style: SkeletonViewStyle(shape: .circle),
                                        animation: .pulse
                                    )

                                Text("\(size)pt")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Divider()

                    ForEach(0..<4, id: \.self) { i in
                        HStack(spacing: 14) {
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 56, height: 56)
                                .skeleton(
                                    isActive: isLoading,
                                    style: SkeletonViewStyle(shape: .circle),
                                    animation: .pulse
                                )

                            VStack(alignment: .leading, spacing: 6) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: CGFloat(120 + i * 20), height: 14)
                                    .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: CGFloat(80 + i * 15), height: 12)
                                    .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("圆形头像骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Card Skeleton Demo
struct CardSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        SkeletonCardView(animation: .shimmerLeftToRight)
                            .padding(.horizontal)

                        SkeletonCardView(
                            style: SkeletonViewStyle(cornerRadius: 8),
                            animation: .gradientFade,
                            showAvatar: false,
                            lineCount: 4
                        )
                        .padding(.horizontal)

                        HStack(spacing: 12) {
                            SkeletonGridItemView(animation: .shimmerLeftToRight)
                            SkeletonGridItemView(animation: .shimmerLeftToRight)
                        }
                        .padding(.horizontal)

                        SkeletonCardView(
                            animation: .pulse,
                            lineCount: 2
                        )
                        .padding(.horizontal)
                    } else {
                        loadedCards
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("矩形卡片骨架")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var loadedCards: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { i in
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading) {
                        Text("卡片标题 \(i + 1)")
                            .font(.headline)
                        Text("这是卡片的描述内容")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Custom Color Skeleton Demo
struct CustomColorSkeletonDemo: View {
    @State private var isLoading = true
    @State private var selectedColorIndex = 0

    let colorSets: [(String, Color, Color)] = [
        ("默认灰", Color(UIColor.systemGray5), Color(UIColor.systemGray3)),
        ("蓝色系", Color.blue.opacity(0.15), Color.blue.opacity(0.3)),
        ("紫色系", Color.purple.opacity(0.15), Color.purple.opacity(0.35)),
        ("绿色系", Color.green.opacity(0.12), Color.green.opacity(0.3)),
        ("暖橙色", Color.orange.opacity(0.12), Color.orange.opacity(0.3)),
    ]

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            Picker("颜色方案", selection: $selectedColorIndex) {
                ForEach(0..<colorSets.count, id: \.self) { i in
                    Text(colorSets[i].0).tag(i)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        let colors = colorSets[selectedColorIndex]
                        ForEach(0..<4, id: \.self) { _ in
                            SkeletonCardView(
                                style: SkeletonViewStyle(
                                    baseColor: colors.1,
                                    highlightColor: colors.2
                                ),
                                animation: .shimmerLeftToRight
                            )
                            .padding(.horizontal)
                        }
                    } else {
                        ForEach(0..<4, id: \.self) { i in
                            HStack(spacing: 12) {
                                Image(systemName: "paintpalette.fill")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading) {
                                    Text("项目 \(i + 1)").font(.headline)
                                    Text("自定义颜色数据已加载").font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle("自定义颜色骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Nested View Skeleton Demo
struct NestedViewSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Text("外层容器").font(.caption).foregroundColor(.secondary)
                        HStack(spacing: 12) {
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: 80, height: 80)
                                    .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: 80, height: 10)
                                    .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(height: 16)
                                    .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)

                                SkeletonRowView(
                                    lineCount: 3,
                                    lineHeight: 11,
                                    spacing: 6,
                                    animation: .shimmerLeftToRight
                                )
                                .frame(height: 50)

                                HStack(spacing: 8) {
                                    ForEach(0..<3, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(UIColor.systemGray5))
                                            .frame(width: 60, height: 24)
                                            .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        Text("嵌套列表").font(.caption).foregroundColor(.secondary)
                        ForEach(0..<3, id: \.self) { _ in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: 40, height: 40)
                                    .skeleton(
                                        isActive: isLoading,
                                        style: SkeletonViewStyle(shape: .circle),
                                        animation: .shimmerLeftToRight
                                    )

                                VStack(alignment: .leading, spacing: 6) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(height: 13)
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(width: 120, height: 11)
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                }

                                Spacer()

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: 50, height: 25)
                                    .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("嵌套视图递归骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Table Cell Skeleton Demo
struct TableCellSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            List {
                ForEach(0..<8, id: \.self) { i in
                    if isLoading {
                        SkeletonTableCellView(animation: .shimmerLeftToRight)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading) {
                                Text("列表项 \(i + 1)")
                                    .font(.headline)
                                Text("详细描述信息")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("表格单元格骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Auto Layout Skeleton Demo
struct AutoLayoutSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            Text("骨架自动适配容器大小")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 180)
                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 100)
                            .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 100)
                            .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                    }
                    .padding(.horizontal)

                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 60)
                                .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("自动计算内容区域")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Table View Skeleton Demo
struct TableViewSkeletonDemo: View {
    @State private var isLoading = true
    @State private var items: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding()

            List {
                if isLoading {
                    ForEach(0..<10, id: \.self) { _ in
                        SkeletonTableCellView(animation: .shimmerLeftToRight)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                } else {
                    ForEach(items, id: \.self) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 60, height: 60)

                            VStack(alignment: .leading) {
                                Text(item)
                                    .font(.headline)
                                Text("列表内容描述")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("列表自动骨架")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isLoading) { _, newValue in
            if !newValue {
                items = (1...10).map { "列表项 \($0)" }
            } else {
                items = []
            }
        }
    }
}

// MARK: - Collection View Skeleton Demo
struct CollectionViewSkeletonDemo: View {
    @State private var isLoading = true
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<8, id: \.self) { i in
                        if isLoading {
                            SkeletonGridItemView(animation: .shimmerLeftToRight)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.blue.opacity(0.3))
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)

                                Text("项目 \(i + 1)")
                                    .font(.caption)
                                Text("描述")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("网格自动骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Header Footer Skeleton Demo
struct HeaderFooterSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            List {
                ForEach(0..<3, id: \.self) { section in
                    Section {
                        ForEach(0..<3, id: \.self) { _ in
                            if isLoading {
                                SkeletonTableCellView(animation: .shimmerLeftToRight)
                            } else {
                                HStack {
                                    Image(systemName: "doc.text")
                                    Text("内容项")
                                }
                            }
                        }
                    } header: {
                        if isLoading {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 100, height: 14)
                                .skeleton(isActive: true, animation: .shimmerLeftToRight)
                        } else {
                            Text("Section \(section + 1)")
                        }
                    } footer: {
                        if isLoading {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 150, height: 10)
                                .skeleton(isActive: true, animation: .shimmerLeftToRight)
                        } else {
                            Text("共 3 条数据")
                        }
                    }
                }
            }
        }
        .navigationTitle("Header/Footer 骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Manual Control Demo
struct ManualControlSkeletonDemo: View {
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Button("显示骨架") {
                    withAnimation { isLoading = true }
                }
                .buttonStyle(.borderedProminent)

                Button("隐藏骨架") {
                    withAnimation { isLoading = false }
                }
                .buttonStyle(.bordered)
            }

            Text("交互状态: \(isLoading ? "已禁用 (骨架显示中)" : "正常")")
                .font(.caption)
                .foregroundColor(isLoading ? .red : .green)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { i in
                        if isLoading {
                            SkeletonCardView(animation: .shimmerLeftToRight)
                                .padding(.horizontal)
                        } else {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.blue)

                                VStack(alignment: .leading) {
                                    Text("用户 \(i + 1)").font(.headline)
                                    Text("已加载的内容").font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .allowsHitTesting(!isLoading)
        }
        .padding(.top)
        .navigationTitle("手动显示/隐藏")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Auto Hide Skeleton Demo
struct AutoHideSkeletonDemo: View {
    @State private var isLoading = true
    @State private var loadedData: [String] = []
    @State private var loadDuration: Double = 3.0

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    Text("加载时间: \(String(format: "%.1f", loadDuration))秒")
                    Slider(value: $loadDuration, in: 1...6, step: 0.5)
                }
                .padding(.horizontal)

                Button("模拟数据加载") {
                    startLoading()
                }
                .buttonStyle(.borderedProminent)
            }

            if isLoading {
                ProgressView("加载中...")
                    .padding(.bottom, 4)
            }

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { i in
                        if isLoading {
                            SkeletonTableCellView(animation: .shimmerLeftToRight)
                                .padding(.horizontal)
                        } else if i < loadedData.count {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 60, height: 60)

                                VStack(alignment: .leading) {
                                    Text(loadedData[i]).font(.headline)
                                    Text("加载完成").font(.caption).foregroundColor(.green)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                }
            }
        }
        .navigationTitle("数据加载自动隐藏")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startLoading() }
    }

    private func startLoading() {
        isLoading = true
        loadedData = []

        DispatchQueue.main.asyncAfter(deadline: .now() + loadDuration) {
            withAnimation {
                loadedData = (1...6).map { "数据项 \($0)" }
                isLoading = false
            }
        }
    }
}

// MARK: - Independent Control Demo
struct IndependentControlDemo: View {
    @State private var section1Loading = true
    @State private var section2Loading = true
    @State private var section3Loading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    HStack {
                        Text("区域 1").font(.headline)
                        Spacer()
                        Button(section1Loading ? "完成加载" : "重新加载") {
                            withAnimation { section1Loading.toggle() }
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)

                    if section1Loading {
                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle()
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: 60, height: 60)
                                    .skeleton(isActive: true, style: SkeletonViewStyle(shape: .circle), animation: .pulse)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { _ in
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }

                Divider()

                VStack(spacing: 8) {
                    HStack {
                        Text("区域 2").font(.headline)
                        Spacer()
                        Button(section2Loading ? "完成加载" : "重新加载") {
                            withAnimation { section2Loading.toggle() }
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)

                    if section2Loading {
                        SkeletonCardView(animation: .shimmerLeftToRight)
                            .padding(.horizontal)
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text("推荐内容").font(.headline)
                                Text("这部分已独立加载完成").font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }

                Divider()

                VStack(spacing: 8) {
                    HStack {
                        Text("区域 3").font(.headline)
                        Spacer()
                        Button(section3Loading ? "完成加载" : "重新加载") {
                            withAnimation { section3Loading.toggle() }
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)

                    if section3Loading {
                        SkeletonRowView(
                            lineCount: 4,
                            lineHeight: 14,
                            spacing: 10,
                            animation: .gradientFade
                        )
                        .frame(height: 80)
                        .padding(.horizontal)
                    } else {
                        Text("区域 3 的文字内容已加载完毕，每个区域可以独立控制骨架的显示和隐藏状态。")
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("独立视图控制")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Size Config Demo
struct SizeConfigSkeletonDemo: View {
    @State private var isLoading = true
    @State private var widthScale: Double = 1.0
    @State private var heightScale: Double = 1.0

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            VStack(spacing: 8) {
                HStack {
                    Text("宽度: \(Int(widthScale * 100))%")
                    Slider(value: $widthScale, in: 0.3...1.0, step: 0.1)
                }
                HStack {
                    Text("高度: \(Int(heightScale * 100))%")
                    Slider(value: $heightScale, in: 0.5...2.0, step: 0.1)
                }
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGray5))
                            .frame(
                                width: geo.size.width * widthScale,
                                height: 60 * heightScale
                            )
                            .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                    }
                    .frame(height: 60 * heightScale)
                    .padding(.horizontal)

                    ForEach(0..<4, id: \.self) { i in
                        GeometryReader { geo in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(
                                        width: 60 * heightScale,
                                        height: 60 * heightScale
                                    )
                                    .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)

                                VStack(alignment: .leading, spacing: 8) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(
                                            width: (geo.size.width - 84) * widthScale,
                                            height: 14 * heightScale
                                        )
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(
                                            width: (geo.size.width - 84) * widthScale * 0.7,
                                            height: 12 * heightScale
                                        )
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                }
                            }
                        }
                        .frame(height: 60 * heightScale)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("骨架大小配置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Corner Radius Demo
struct CornerRadiusSkeletonDemo: View {
    @State private var isLoading = true
    @State private var cornerRadius: Double = 4

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            HStack {
                Text("圆角: \(Int(cornerRadius))pt")
                Slider(value: $cornerRadius, in: 0...30, step: 2)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 120)
                        .skeleton(
                            isActive: isLoading,
                            style: SkeletonViewStyle(cornerRadius: CGFloat(cornerRadius)),
                            animation: .shimmerLeftToRight
                        )
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(UIColor.systemGray5))
                            .frame(width: 80, height: 80)
                            .skeleton(
                                isActive: isLoading,
                                style: SkeletonViewStyle(cornerRadius: CGFloat(cornerRadius)),
                                animation: .shimmerLeftToRight
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 16)
                                .skeleton(
                                    isActive: isLoading,
                                    style: SkeletonViewStyle(cornerRadius: CGFloat(cornerRadius)),
                                    animation: .shimmerLeftToRight
                                )

                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 150, height: 14)
                                .skeleton(
                                    isActive: isLoading,
                                    style: SkeletonViewStyle(cornerRadius: CGFloat(cornerRadius)),
                                    animation: .shimmerLeftToRight
                                )
                        }
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 60)
                                .skeleton(
                                    isActive: isLoading,
                                    style: SkeletonViewStyle(cornerRadius: CGFloat(cornerRadius)),
                                    animation: .shimmerLeftToRight
                                )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("圆角独立控制")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Placeholder Skeleton Demo
struct PlaceholderSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        if isLoading {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 200)
                                .skeleton(isActive: true, animation: .shimmerLeftToRight)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(Color(UIColor.systemGray3))
                                )
                        } else {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)

                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 12) {
                            ZStack {
                                if isLoading {
                                    Circle()
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(width: 56, height: 56)
                                        .skeleton(
                                            isActive: true,
                                            style: SkeletonViewStyle(shape: .circle),
                                            animation: .pulse
                                        )
                                        .overlay(
                                            Image(systemName: "person")
                                                .foregroundColor(Color(UIColor.systemGray3))
                                        )
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 56, height: 56)
                                        .foregroundColor(.green)
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                if isLoading {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(height: 14)
                                        .skeleton(isActive: true, animation: .shimmerLeftToRight)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(width: 100, height: 12)
                                        .skeleton(isActive: true, animation: .shimmerLeftToRight)
                                } else {
                                    Text("用户名").font(.headline)
                                    Text("在线").font(.caption).foregroundColor(.green)
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("骨架与占位图结合")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stack View Skeleton Demo
struct StackViewSkeletonDemo: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            Toggle("显示骨架", isOn: $isLoading)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("水平 Stack 骨架").font(.caption).foregroundColor(.secondary)
                        HStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { _ in
                                VStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(width: 70, height: 70)
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(width: 50, height: 10)
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("垂直 Stack 骨架").font(.caption).foregroundColor(.secondary)
                        VStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { _ in
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(width: 44, height: 44)
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)

                                    VStack(alignment: .leading, spacing: 5) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color(UIColor.systemGray5))
                                            .frame(height: 13)
                                            .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color(UIColor.systemGray5))
                                            .frame(width: 100, height: 11)
                                            .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                    }

                                    Spacer()

                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(width: 60, height: 28)
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("网格 Stack 骨架").font(.caption).foregroundColor(.secondary)
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 12
                        ) {
                            ForEach(0..<9, id: \.self) { _ in
                                VStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.systemGray5))
                                        .aspectRatio(1, contentMode: .fit)
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(height: 10)
                                        .skeleton(isActive: isLoading, animation: .shimmerLeftToRight)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("StackView 骨架")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SkeletonViewDemoView()
    }
}
