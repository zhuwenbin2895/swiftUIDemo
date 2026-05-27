import SwiftUI

// MARK: - Demo Item

struct StarRatingDemoItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let destination: AnyView
}

// MARK: - Demo List View

struct StarRatingDemoView: View {
    private let demos: [StarRatingDemoItem] = [
        StarRatingDemoItem(
            title: "整数评分模式",
            subtitle: "Full Star Mode - 只显示整星",
            icon: "star.fill",
            destination: AnyView(FullModeDemo())
        ),
        StarRatingDemoItem(
            title: "半星评分模式",
            subtitle: "Half Star Mode - 支持半星精度",
            icon: "star.leadinghalf.filled",
            destination: AnyView(HalfModeDemo())
        ),
        StarRatingDemoItem(
            title: "精确评分模式",
            subtitle: "Precise Mode - 按滑动位置显示比例",
            icon: "star.lefthalf.fill",
            destination: AnyView(PreciseModeDemo())
        ),
        StarRatingDemoItem(
            title: "手势交互",
            subtitle: "Gesture Interaction - 滑动和点击评分",
            icon: "hand.draw",
            destination: AnyView(GestureInteractionDemo())
        ),
        StarRatingDemoItem(
            title: "只读模式",
            subtitle: "Read Only - 关闭用户交互仅展示",
            icon: "eye",
            destination: AnyView(ReadOnlyDemo())
        ),
        StarRatingDemoItem(
            title: "长按提示",
            subtitle: "Long Press Hint - 长按触发提示",
            icon: "hand.tap",
            destination: AnyView(LongPressDemo())
        ),
        StarRatingDemoItem(
            title: "自定义星星数量",
            subtitle: "Star Count - 1到10颗可配置",
            icon: "number",
            destination: AnyView(StarCountDemo())
        ),
        StarRatingDemoItem(
            title: "自定义间距与尺寸",
            subtitle: "Spacing & Size - 间距和尺寸可配置",
            icon: "arrow.left.and.right",
            destination: AnyView(SpacingSizeDemo())
        ),
        StarRatingDemoItem(
            title: "自定义颜色与边框",
            subtitle: "Colors & Border - 填充色边框色可配置",
            icon: "paintpalette",
            destination: AnyView(ColorBorderDemo())
        ),
        StarRatingDemoItem(
            title: "自定义图片",
            subtitle: "Custom Images - 空星实星半星独立设置",
            icon: "photo",
            destination: AnyView(CustomImageDemo())
        ),
        StarRatingDemoItem(
            title: "评分文字显示",
            subtitle: "Rating Text - 数字实时显示与格式化",
            icon: "textformat",
            destination: AnyView(RatingTextDemo())
        ),
        StarRatingDemoItem(
            title: "描述文字",
            subtitle: "Description - 评分描述自动对应",
            icon: "text.below.photo",
            destination: AnyView(DescriptionDemo())
        ),
        StarRatingDemoItem(
            title: "布局适配",
            subtitle: "Layout - 居中/RTL/内边距",
            icon: "rectangle.3.group",
            destination: AnyView(LayoutDemo())
        ),
        StarRatingDemoItem(
            title: "动画与回调",
            subtitle: "Animation & Callback - 动画时长和事件回调",
            icon: "bolt.fill",
            destination: AnyView(AnimationCallbackDemo())
        ),
        StarRatingDemoItem(
            title: "触觉反馈",
            subtitle: "Haptic Feedback - 启用触觉反馈",
            icon: "iphone.radiowaves.left.and.right",
            destination: AnyView(HapticDemo())
        ),
    ]

    var body: some View {
        List(demos) { demo in
            NavigationLink {
                demo.destination
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: demo.icon)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .frame(width: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(demo.title)
                            .font(.headline)
                        Text(demo.subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("StarRating 评分组件")
    }
}

// MARK: - Full Mode Demo

struct FullModeDemo: View {
    @State private var rating: Double = 3

    var body: some View {
        VStack(spacing: 30) {
            Text("整数评分模式")
                .font(.title2.bold())

            Text("只能评整数分，如 1, 2, 3, 4, 5")
                .font(.subheadline)
                .foregroundColor(.secondary)

            var config = StarRatingConfig()
            let _ = {
                config.ratingMode = .full
                config.showRatingText = true
                config.starSize = 40
            }()

            StarRatingView(rating: $rating, config: config)

            Text("当前评分: \(Int(rating)) 星")
                .font(.headline)
                .foregroundColor(.orange)

            Divider()

            Text("拖动或点击星星尝试评分")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("整数评分")
    }
}

// MARK: - Half Mode Demo

struct HalfModeDemo: View {
    @State private var rating: Double = 3.5

    var body: some View {
        VStack(spacing: 30) {
            Text("半星评分模式")
                .font(.title2.bold())

            Text("支持 0.5 的精度，如 2.5, 3.0, 3.5")
                .font(.subheadline)
                .foregroundColor(.secondary)

            var config = StarRatingConfig()
            let _ = {
                config.ratingMode = .half
                config.showRatingText = true
                config.textFormat = "%.1f"
                config.starSize = 40
            }()

            StarRatingView(rating: $rating, config: config)

            Text("当前评分: \(String(format: "%.1f", rating)) 星")
                .font(.headline)
                .foregroundColor(.orange)
        }
        .padding()
        .navigationTitle("半星评分")
    }
}

// MARK: - Precise Mode Demo

struct PreciseModeDemo: View {
    @State private var rating: Double = 3.7

    var body: some View {
        VStack(spacing: 30) {
            Text("精确评分模式")
                .font(.title2.bold())

            Text("按滑动位置精确显示星星填充比例")
                .font(.subheadline)
                .foregroundColor(.secondary)

            var config = StarRatingConfig()
            let _ = {
                config.ratingMode = .precise
                config.showRatingText = true
                config.textFormat = "%.2f"
                config.starSize = 40
            }()

            StarRatingView(rating: $rating, config: config)

            Text("当前评分: \(String(format: "%.2f", rating)) 星")
                .font(.headline)
                .foregroundColor(.orange)
        }
        .padding()
        .navigationTitle("精确评分")
    }
}

// MARK: - Gesture Interaction Demo

struct GestureInteractionDemo: View {
    @State private var rating1: Double = 2.5
    @State private var rating2: Double = 4.0
    @State private var lastAction: String = "请操作星星"

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("手势交互演示")
                    .font(.title2.bold())

                GroupBox("滑动评分") {
                    VStack(spacing: 12) {
                        Text("手指在星星上滑动实时更新")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        var config = StarRatingConfig()
                        let _ = {
                            config.ratingMode = .precise
                            config.showRatingText = true
                            config.starSize = 36
                        }()

                        StarRatingView(rating: $rating1, config: config) { newRating in
                            lastAction = "滑动中: \(String(format: "%.2f", newRating))"
                        } onTouchEnded: { finalRating in
                            lastAction = "滑动结束: \(String(format: "%.2f", finalRating))"
                        }
                    }
                    .padding(.vertical, 8)
                }

                GroupBox("点击评分") {
                    VStack(spacing: 12) {
                        Text("点击星星位置直接评分")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        var config2 = StarRatingConfig()
                        let _ = {
                            config2.ratingMode = .full
                            config2.showRatingText = true
                            config2.starSize = 36
                        }()

                        StarRatingView(rating: $rating2, config: config2) { newRating in
                            lastAction = "点击评分: \(Int(newRating)) 星"
                        }
                    }
                    .padding(.vertical, 8)
                }

                Text(lastAction)
                    .font(.callout)
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
        .navigationTitle("手势交互")
    }
}

// MARK: - Read Only Demo

struct ReadOnlyDemo: View {
    let ratings: [(String, Double)] = [
        ("产品质量", 4.5),
        ("服务态度", 3.8),
        ("物流速度", 4.2),
        ("包装完好", 5.0),
        ("性价比", 3.5),
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("只读模式")
                .font(.title2.bold())

            Text("关闭交互，仅用于展示评分")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ForEach(ratings, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .frame(width: 80, alignment: .leading)

                    var config = StarRatingConfig()
                    let _ = {
                        config.isInteractive = false
                        config.ratingMode = .half
                        config.starSize = 20
                        config.starSpacing = 4
                        config.showRatingText = true
                        config.textFormat = "%.1f"
                        config.textFont = .system(size: 12)
                    }()

                    StarRatingView(
                        rating: .constant(item.1),
                        config: config
                    )
                }
            }
        }
        .padding()
        .navigationTitle("只读模式")
    }
}

// MARK: - Long Press Demo

struct LongPressDemo: View {
    @State private var rating: Double = 3.0

    var body: some View {
        VStack(spacing: 30) {
            Text("长按提示")
                .font(.title2.bold())

            Text("长按星星区域会显示提示文字")
                .font(.subheadline)
                .foregroundColor(.secondary)

            var config = StarRatingConfig()
            let _ = {
                config.enableLongPress = true
                config.longPressHint = "拖动星星可精确评分"
                config.ratingMode = .precise
                config.showRatingText = true
                config.starSize = 40
                config.enableHapticFeedback = true
            }()

            StarRatingView(rating: $rating, config: config)

            Text("长按星星区域试试")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 20)
        }
        .padding()
        .navigationTitle("长按提示")
    }
}

// MARK: - Star Count Demo

struct StarCountDemo: View {
    @State private var rating3: Double = 2.0
    @State private var rating5: Double = 3.0
    @State private var rating7: Double = 5.0
    @State private var rating10: Double = 7.0

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("自定义星星数量")
                    .font(.title2.bold())

                Text("支持1到10颗星星")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                GroupBox("3颗星") {
                    var config = StarRatingConfig(totalStars: 3)
                    let _ = {
                        config.showRatingText = true
                        config.starSize = 36
                    }()
                    StarRatingView(rating: $rating3, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("5颗星（默认）") {
                    var config = StarRatingConfig(totalStars: 5)
                    let _ = {
                        config.showRatingText = true
                        config.starSize = 36
                    }()
                    StarRatingView(rating: $rating5, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("7颗星") {
                    var config = StarRatingConfig(totalStars: 7)
                    let _ = {
                        config.showRatingText = true
                        config.starSize = 30
                    }()
                    StarRatingView(rating: $rating7, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("10颗星") {
                    var config = StarRatingConfig(totalStars: 10)
                    let _ = {
                        config.showRatingText = true
                        config.starSize = 24
                        config.starSpacing = 4
                    }()
                    StarRatingView(rating: $rating10, config: config)
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("星星数量")
    }
}

// MARK: - Spacing & Size Demo

struct SpacingSizeDemo: View {
    @State private var rating1: Double = 4.0
    @State private var rating2: Double = 3.0
    @State private var rating3: Double = 4.5
    @State private var starSize: CGFloat = 30
    @State private var spacing: CGFloat = 8

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("自定义间距与尺寸")
                    .font(.title2.bold())

                GroupBox("小尺寸 (20pt, 间距4)") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.starSize = 20
                        config.starSpacing = 4
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating1, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("中等尺寸 (36pt, 间距8)") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.starSize = 36
                        config.starSpacing = 8
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating2, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("大尺寸 (50pt, 间距12)") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.starSize = 50
                        config.starSpacing = 12
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating3, config: config)
                        .padding(.vertical, 4)
                }

                Divider()

                GroupBox("交互调整") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("尺寸: \(Int(starSize))pt")
                            Slider(value: $starSize, in: 16...60)
                        }
                        HStack {
                            Text("间距: \(Int(spacing))pt")
                            Slider(value: $spacing, in: 0...20)
                        }

                        var config = StarRatingConfig()
                        let _ = {
                            config.starSize = starSize
                            config.starSpacing = spacing
                            config.showRatingText = true
                        }()

                        StarRatingView(rating: .constant(3.5), config: config)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("间距与尺寸")
    }
}

// MARK: - Color & Border Demo

struct ColorBorderDemo: View {
    @State private var rating1: Double = 4.0
    @State private var rating2: Double = 3.5
    @State private var rating3: Double = 4.5
    @State private var rating4: Double = 2.5

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("自定义颜色与边框")
                    .font(.title2.bold())

                GroupBox("金色（默认）") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.fillColor = .yellow
                        config.emptyColor = .gray.opacity(0.3)
                        config.starSize = 36
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating1, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("红色 + 粉色空星") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.fillColor = .red
                        config.emptyColor = .pink.opacity(0.2)
                        config.starSize = 36
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating2, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("绿色 + 边框") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.fillColor = .green
                        config.emptyColor = .green.opacity(0.1)
                        config.borderColor = .green
                        config.borderWidth = 1
                        config.starSize = 36
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating3, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("蓝色 + 粗边框") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.fillColor = .blue
                        config.emptyColor = .blue.opacity(0.1)
                        config.borderColor = .blue
                        config.borderWidth = 2
                        config.starSize = 36
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating4, config: config)
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("颜色与边框")
    }
}

// MARK: - Custom Image Demo

struct CustomImageDemo: View {
    @State private var rating1: Double = 3.0
    @State private var rating2: Double = 4.0
    @State private var rating3: Double = 2.5

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("自定义图片")
                    .font(.title2.bold())

                Text("可用系统图标替代默认星星")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                GroupBox("爱心图标") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.filledImage = Image(systemName: "heart.fill")
                        config.emptyImage = Image(systemName: "heart")
                        config.fillColor = .red
                        config.starSize = 36
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating1, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("火焰图标") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.filledImage = Image(systemName: "flame.fill")
                        config.emptyImage = Image(systemName: "flame")
                        config.fillColor = .orange
                        config.starSize = 36
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating2, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("笑脸图标") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.filledImage = Image(systemName: "face.smiling.fill")
                        config.emptyImage = Image(systemName: "face.dashed")
                        config.fillColor = .purple
                        config.starSize = 36
                        config.ratingMode = .full
                        config.showRatingText = true
                    }()
                    StarRatingView(rating: $rating3, config: config)
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("自定义图片")
    }
}

// MARK: - Rating Text Demo

struct RatingTextDemo: View {
    @State private var rating1: Double = 3.5
    @State private var rating2: Double = 4.2
    @State private var rating3: Double = 2.8
    @State private var rating4: Double = 4.0

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("评分文字显示")
                    .font(.title2.bold())

                GroupBox("右侧显示（默认）") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.showRatingText = true
                        config.textPosition = .right
                        config.textFormat = "%.1f"
                        config.starSize = 30
                    }()
                    StarRatingView(rating: $rating1, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("左侧显示") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.showRatingText = true
                        config.textPosition = .left
                        config.textFormat = "%.1f 分"
                        config.textColor = .orange
                        config.textFont = .system(size: 16, weight: .bold)
                        config.starSize = 30
                    }()
                    StarRatingView(rating: $rating2, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("顶部显示") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.showRatingText = true
                        config.textPosition = .top
                        config.textFormat = "评分: %.2f"
                        config.textColor = .blue
                        config.starSize = 30
                    }()
                    StarRatingView(rating: $rating3, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("底部显示") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.showRatingText = true
                        config.textPosition = .bottom
                        config.textFormat = "%.0f / 5"
                        config.textColor = .green
                        config.textFont = .system(size: 18, weight: .heavy)
                        config.ratingMode = .full
                        config.starSize = 30
                    }()
                    StarRatingView(rating: $rating4, config: config)
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("评分文字")
    }
}

// MARK: - Description Demo

struct DescriptionDemo: View {
    @State private var rating1: Double = 3.0
    @State private var rating2: Double = 4.0

    var body: some View {
        VStack(spacing: 30) {
            Text("描述文字")
                .font(.title2.bold())

            Text("评分描述文字自动对应当前评分")
                .font(.subheadline)
                .foregroundColor(.secondary)

            GroupBox("默认描述") {
                var config = StarRatingConfig()
                let _ = {
                    config.showDescription = true
                    config.showRatingText = true
                    config.starSize = 36
                    config.ratingMode = .full
                }()
                StarRatingView(rating: $rating1, config: config)
                    .padding(.vertical, 8)
            }

            GroupBox("自定义描述") {
                var config = StarRatingConfig()
                let _ = {
                    config.showDescription = true
                    config.descriptions = ["😡 不满意", "😕 一般般", "🙂 还可以", "😊 满意", "🤩 非常满意"]
                    config.descriptionFont = .system(size: 14, weight: .medium)
                    config.descriptionColor = .orange
                    config.showRatingText = true
                    config.starSize = 36
                    config.ratingMode = .full
                }()
                StarRatingView(rating: $rating2, config: config)
                    .padding(.vertical, 8)
            }

            Text("点击或滑动改变评分查看描述变化")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("描述文字")
    }
}

// MARK: - Layout Demo

struct LayoutDemo: View {
    @State private var rating1: Double = 3.5
    @State private var rating2: Double = 4.0
    @State private var rating3: Double = 2.5

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("布局适配")
                    .font(.title2.bold())

                GroupBox("水平居中") {
                    HStack {
                        Spacer()
                        var config = StarRatingConfig()
                        let _ = {
                            config.showRatingText = true
                            config.starSize = 30
                        }()
                        StarRatingView(rating: $rating1, config: config)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("RTL 布局（从右到左）") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.supportRTL = true
                        config.showRatingText = true
                        config.textPosition = .left
                        config.starSize = 30
                    }()
                    StarRatingView(rating: $rating2, config: config)
                        .environment(\.layoutDirection, .rightToLeft)
                        .padding(.vertical, 4)
                }

                GroupBox("内边距 (Inset)") {
                    VStack(spacing: 12) {
                        var config1 = StarRatingConfig()
                        let _ = {
                            config1.contentInsets = EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
                            config1.showRatingText = true
                            config1.starSize = 30
                        }()
                        StarRatingView(rating: $rating3, config: config1)
                            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

                        Text("上面的评分有 16pt 上下和 24pt 左右内边距")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("垂直居中") {
                    HStack(spacing: 20) {
                        Text("评分:")
                            .font(.headline)

                        var config = StarRatingConfig()
                        let _ = {
                            config.showRatingText = true
                            config.starSize = 24
                        }()
                        StarRatingView(rating: $rating1, config: config)
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("布局适配")
    }
}

// MARK: - Animation & Callback Demo

struct AnimationCallbackDemo: View {
    @State private var rating1: Double = 0
    @State private var rating2: Double = 0
    @State private var logs: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("动画与回调")
                    .font(.title2.bold())

                GroupBox("快速动画 (0.1s)") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.animationDuration = 0.1
                        config.showRatingText = true
                        config.starSize = 36
                    }()
                    StarRatingView(rating: $rating1, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("慢速动画 (0.5s)") {
                    var config = StarRatingConfig()
                    let _ = {
                        config.animationDuration = 0.5
                        config.showRatingText = true
                        config.starSize = 36
                    }()
                    StarRatingView(rating: $rating2, config: config)
                        .padding(.vertical, 4)
                }

                GroupBox("回调日志") {
                    VStack(spacing: 12) {
                        var config = StarRatingConfig()
                        let _ = {
                            config.showRatingText = true
                            config.starSize = 36
                            config.ratingMode = .half
                        }()

                        StarRatingView(
                            rating: $rating1,
                            config: config
                        ) { newRating in
                            let log = "变化: \(String(format: "%.1f", newRating))"
                            if logs.last != log {
                                logs.append(log)
                                if logs.count > 8 { logs.removeFirst() }
                            }
                        } onTouchEnded: { finalRating in
                            logs.append("结束: \(String(format: "%.1f", finalRating))")
                            if logs.count > 8 { logs.removeFirst() }
                        }

                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(logs.enumerated()), id: \.offset) { _, log in
                                    Text(log)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(log.hasPrefix("结束") ? .green : .blue)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 120)
                        .padding(8)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.vertical, 4)
                }

                Button("重置") {
                    rating1 = 0
                    rating2 = 0
                    logs.removeAll()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("动画与回调")
    }
}

// MARK: - Haptic Demo

struct HapticDemo: View {
    @State private var rating: Double = 3.0
    @State private var hapticEnabled: Bool = true

    var body: some View {
        VStack(spacing: 30) {
            Text("触觉反馈")
                .font(.title2.bold())

            Text("滑动时提供触觉反馈")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Toggle("启用触觉反馈", isOn: $hapticEnabled)
                .padding(.horizontal)

            var config = StarRatingConfig()
            let _ = {
                config.enableHapticFeedback = hapticEnabled
                config.showRatingText = true
                config.starSize = 44
                config.ratingMode = .half
            }()

            StarRatingView(rating: $rating, config: config)

            Text("在真机上滑动体验触觉反馈效果")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 20)
        }
        .padding()
        .navigationTitle("触觉反馈")
    }
}
