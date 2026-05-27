import SwiftUI

// MARK: - Demo Item

struct ChartDemoItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let destination: AnyView
}

// MARK: - Chart Demo List

struct ChartDemoView: View {
    private let demos: [ChartDemoItem] = [
        ChartDemoItem(
            title: "柱状图",
            subtitle: "Column Chart - 纵向柱状数据对比",
            icon: "chart.bar.fill",
            destination: AnyView(ColumnChartDemo())
        ),
        ChartDemoItem(
            title: "条形图",
            subtitle: "Bar Chart - 横向条形数据对比",
            icon: "chart.bar.xaxis",
            destination: AnyView(BarChartDemo())
        ),
        ChartDemoItem(
            title: "折线图",
            subtitle: "Line Chart - 数据趋势展示",
            icon: "chart.xyaxis.line",
            destination: AnyView(LineChartDemo())
        ),
        ChartDemoItem(
            title: "曲线图",
            subtitle: "Spline Chart - 平滑曲线趋势",
            icon: "waveform.path",
            destination: AnyView(SplineChartDemo())
        ),
        ChartDemoItem(
            title: "面积图",
            subtitle: "Area Chart - 带填充区域的趋势图",
            icon: "chart.line.uptrend.xyaxis",
            destination: AnyView(AreaChartDemo())
        ),
        ChartDemoItem(
            title: "曲线面积图",
            subtitle: "Area Spline Chart - 平滑曲线面积图",
            icon: "waveform.path.ecg",
            destination: AnyView(AreaSplineChartDemo())
        ),
        ChartDemoItem(
            title: "标题与样式",
            subtitle: "Title, Subtitle, Background, Theme",
            icon: "paintbrush.fill",
            destination: AnyView(TitleStyleDemo())
        ),
        ChartDemoItem(
            title: "主题配色",
            subtitle: "多种主题风格切换",
            icon: "paintpalette.fill",
            destination: AnyView(ThemeDemo())
        ),
        ChartDemoItem(
            title: "坐标轴设置",
            subtitle: "轴标签、轴标题、数值范围",
            icon: "ruler.fill",
            destination: AnyView(AxisSettingsDemo())
        ),
        ChartDemoItem(
            title: "坐标轴反转",
            subtitle: "Inverted Axis 效果演示",
            icon: "arrow.left.arrow.right",
            destination: AnyView(InvertedChartDemo())
        ),
        ChartDemoItem(
            title: "链式语法演示",
            subtitle: "Chain Syntax 一行代码配置图表",
            icon: "link",
            destination: AnyView(ChainSyntaxDemo())
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
                        .foregroundStyle(.blue)
                        .frame(width: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(demo.title)
                            .font(.body.weight(.medium))
                        Text(demo.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("ChartKit 图表")
    }
}

// MARK: - Column Chart Demo

struct ColumnChartDemo: View {
    @StateObject private var model = AAChartModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                infoCard(
                    title: "柱状图 Column Chart",
                    description: "适用于对比不同类别的数据大小，支持多组数据系列同时展示。"
                )
            }
            .padding()
        }
        .navigationTitle("柱状图")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.column)
            .title("月度销售额")
            .subtitle("2024年上半年数据")
            .xAxisLabels(["1月", "2月", "3月", "4月", "5月", "6月"])
            .xAxisTitle("月份")
            .yAxisTitle("万元")
            .theme(.default)
            .series([
                AASeriesItem(name: "线上", data: [45, 56, 38, 72, 60, 85]),
                AASeriesItem(name: "线下", data: [30, 42, 55, 48, 38, 62])
            ])
    }
}

// MARK: - Bar Chart Demo

struct BarChartDemo: View {
    @StateObject private var model = AAChartModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                infoCard(
                    title: "条形图 Bar Chart",
                    description: "横向展示数据，适合标签较长或类目较多的场景。条形图独立绘制，无需设置坐标轴反转。"
                )
            }
            .padding()
        }
        .navigationTitle("条形图")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.bar)
            .title("编程语言流行度")
            .subtitle("2024 TIOBE Index")
            .xAxisLabels(["Python", "Java", "C++", "JavaScript", "Swift"])
            .yAxisTitle("指数")
            .theme(.ocean)
            .series([
                AASeriesItem(name: "流行度", data: [28.5, 15.7, 10.3, 8.2, 5.1])
            ])
    }
}

// MARK: - Line Chart Demo

struct LineChartDemo: View {
    @StateObject private var model = AAChartModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                infoCard(
                    title: "折线图 Line Chart",
                    description: "用直线段连接数据点，清晰展示数据变化趋势。适合时间序列数据展示。"
                )
            }
            .padding()
        }
        .navigationTitle("折线图")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.line)
            .title("用户增长趋势")
            .subtitle("日活跃用户数")
            .xAxisLabels(["周一", "周二", "周三", "周四", "周五", "周六", "周日"])
            .xAxisTitle("星期")
            .yAxisTitle("DAU (万)")
            .theme(.sunset)
            .series([
                AASeriesItem(name: "本周", data: [120, 135, 148, 155, 170, 210, 195]),
                AASeriesItem(name: "上周", data: [105, 118, 125, 140, 150, 185, 175])
            ])
    }
}

// MARK: - Spline Chart Demo

struct SplineChartDemo: View {
    @StateObject private var model = AAChartModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                infoCard(
                    title: "曲线图 Spline Chart",
                    description: "使用贝塞尔曲线平滑连接数据点，视觉效果更加流畅自然。"
                )
            }
            .padding()
        }
        .navigationTitle("曲线图")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.spline)
            .title("温度变化曲线")
            .subtitle("北京市 24 小时气温")
            .xAxisLabels(["6时", "9时", "12时", "15时", "18时", "21时", "24时"])
            .xAxisTitle("时间")
            .yAxisTitle("°C")
            .theme(.forest)
            .series([
                AASeriesItem(name: "气温", data: [8, 14, 22, 26, 23, 18, 12]),
                AASeriesItem(name: "体感", data: [5, 11, 20, 24, 21, 15, 9])
            ])
    }
}

// MARK: - Area Chart Demo

struct AreaChartDemo: View {
    @StateObject private var model = AAChartModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                infoCard(
                    title: "面积图 Area Chart",
                    description: "在折线图基础上填充底部区域，强调数据量级和变化趋势。"
                )
            }
            .padding()
        }
        .navigationTitle("面积图")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.area)
            .title("内存使用趋势")
            .subtitle("应用运行时内存占用")
            .xAxisLabels(["0s", "10s", "20s", "30s", "40s", "50s", "60s"])
            .xAxisTitle("时间")
            .yAxisTitle("MB")
            .yAxisMin(0)
            .yAxisMax(512)
            .theme(.purple)
            .series([
                AASeriesItem(name: "已用", data: [128, 156, 200, 245, 310, 280, 260]),
                AASeriesItem(name: "缓存", data: [64, 80, 95, 110, 130, 120, 100])
            ])
    }
}

// MARK: - Area Spline Chart Demo

struct AreaSplineChartDemo: View {
    @StateObject private var model = AAChartModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                infoCard(
                    title: "曲线面积图 Area Spline Chart",
                    description: "平滑曲线 + 区域填充，兼具美观和数据表现力。"
                )
            }
            .padding()
        }
        .navigationTitle("曲线面积图")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.areaspline)
            .title("网络流量监控")
            .subtitle("上传/下载带宽")
            .xAxisLabels(["00:00", "04:00", "08:00", "12:00", "16:00", "20:00"])
            .xAxisTitle("时间")
            .yAxisTitle("Mbps")
            .theme(.ocean)
            .series([
                AASeriesItem(name: "下载", data: [20, 8, 45, 80, 95, 60]),
                AASeriesItem(name: "上传", data: [5, 3, 15, 30, 40, 25])
            ])
    }
}

// MARK: - Title & Style Demo

struct TitleStyleDemo: View {
    @StateObject private var model = AAChartModel()
    @State private var bgColor: Color = .white

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("背景色")
                        .font(.subheadline.weight(.medium))
                    HStack(spacing: 12) {
                        ForEach([Color.white, Color(hex: "F0F4F8"), Color(hex: "1A1A2E"), Color(hex: "FFF8E7")], id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(.gray.opacity(0.3), lineWidth: 1))
                                .overlay {
                                    if bgColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(color == Color(hex: "1A1A2E") ? .white : .blue)
                                    }
                                }
                                .onTapGesture {
                                    bgColor = color
                                    model.backgroundColor(color)
                                }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

                infoCard(
                    title: "标题与样式",
                    description: "支持设置图表标题、副标题和背景色。通过链式语法一行配置。"
                )
            }
            .padding()
        }
        .navigationTitle("标题与样式")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.spline)
            .title("营收趋势分析")
            .subtitle("单位: 百万元 | 数据来源: 财报")
            .backgroundColor(.white)
            .xAxisLabels(["Q1", "Q2", "Q3", "Q4"])
            .yAxisTitle("百万元")
            .theme(.default)
            .series([
                AASeriesItem(name: "2023", data: [320, 380, 420, 510]),
                AASeriesItem(name: "2024", data: [380, 450, 520, 620])
            ])
    }
}

// MARK: - Theme Demo

struct ThemeDemo: View {
    @StateObject private var model = AAChartModel()
    @State private var selectedTheme: AAChartTheme = .default

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("选择主题")
                        .font(.subheadline.weight(.medium))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(AAChartTheme.allCases, id: \.name) { theme in
                                VStack(spacing: 4) {
                                    HStack(spacing: 2) {
                                        ForEach(0..<3, id: \.self) { i in
                                            Circle()
                                                .fill(theme.colors[i])
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    Text(theme.name)
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedTheme.name == theme.name ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedTheme.name == theme.name ? Color.blue : Color.clear, lineWidth: 1.5)
                                )
                                .onTapGesture {
                                    selectedTheme = theme
                                    model.theme(theme)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

                infoCard(
                    title: "主题配色",
                    description: "内置 5 种主题配色方案：默认、海洋、森林、日落、紫色，一键切换图表风格。"
                )
            }
            .padding()
        }
        .navigationTitle("主题配色")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.column)
            .title("主题配色演示")
            .subtitle("切换不同主题查看效果")
            .xAxisLabels(["A", "B", "C", "D", "E"])
            .theme(.default)
            .series([
                AASeriesItem(name: "系列1", data: [60, 80, 45, 90, 70]),
                AASeriesItem(name: "系列2", data: [40, 55, 70, 50, 85]),
                AASeriesItem(name: "系列3", data: [75, 35, 60, 65, 50])
            ])
    }
}

// MARK: - Axis Settings Demo

struct AxisSettingsDemo: View {
    @StateObject private var model = AAChartModel()
    @State private var yMin: Double = 0
    @State private var yMax: Double = 100

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Y轴范围调整")
                        .font(.subheadline.weight(.medium))

                    HStack {
                        Text("最小值: \(Int(yMin))")
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: $yMin, in: 0...50, step: 10)
                            .onChange(of: yMin) { _, newValue in
                                model.yAxisMin(newValue)
                            }
                    }

                    HStack {
                        Text("最大值: \(Int(yMax))")
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        Slider(value: $yMax, in: 50...150, step: 10)
                            .onChange(of: yMax) { _, newValue in
                                model.yAxisMax(newValue)
                            }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

                infoCard(
                    title: "坐标轴设置",
                    description: "支持设置 X/Y 轴标签、轴标题和数值范围。通过滑块调整 Y 轴范围可以放大或缩小数据视图。"
                )
            }
            .padding()
        }
        .navigationTitle("坐标轴设置")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.line)
            .title("坐标轴配置")
            .subtitle("自定义轴标签与范围")
            .xAxisLabels(["Mon", "Tue", "Wed", "Thu", "Fri"])
            .xAxisTitle("工作日")
            .yAxisTitle("完成率 (%)")
            .yAxisMin(0)
            .yAxisMax(100)
            .theme(.forest)
            .series([
                AASeriesItem(name: "任务A", data: [35, 55, 72, 68, 90]),
                AASeriesItem(name: "任务B", data: [20, 40, 58, 75, 82])
            ])
    }
}

// MARK: - Inverted Chart Demo

struct InvertedChartDemo: View {
    @StateObject private var model = AAChartModel()
    @State private var isInverted = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                Toggle("坐标轴反转", isOn: $isInverted)
                    .padding(.horizontal, 24)
                    .onChange(of: isInverted) { _, newValue in
                        model.inverted(newValue)
                    }

                infoCard(
                    title: "坐标轴反转",
                    description: "开启反转后，X轴变为纵向，Y轴变为横向。对所有图表类型生效：柱状图变为横向条形，折线图/曲线图/面积图的数据点沿纵轴排列、数值沿横轴展开。"
                )
            }
            .padding()
        }
        .navigationTitle("坐标轴反转")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.spline)
            .title("部门绩效排名")
            .subtitle("2024年度考核 - 曲线反转")
            .inverted(true)
            .xAxisLabels(["技术部", "产品部", "市场部", "运营部", "设计部"])
            .yAxisTitle("分数")
            .theme(.sunset)
            .series([
                AASeriesItem(name: "上半年", data: [92, 88, 85, 79, 76]),
                AASeriesItem(name: "下半年", data: [95, 82, 90, 83, 80])
            ])
    }
}

// MARK: - Chain Syntax Demo

struct ChainSyntaxDemo: View {
    @StateObject private var model = AAChartModel()
    @State private var selectedType: AAChartType = .column

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AAChartView(model: model)
                    .frame(height: 320)
                    .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("切换图表类型")
                        .font(.subheadline.weight(.medium))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                        ForEach(AAChartType.allCases, id: \.self) { type in
                            Button {
                                selectedType = type
                                model.chartType(type)
                            } label: {
                                Text(type.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedType == type ? Color.blue : Color(.systemGray5))
                                    .foregroundStyle(selectedType == type ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("链式语法示例")
                        .font(.subheadline.weight(.medium))
                    Text("""
                    let model = AAChartModel()
                        .chartType(.column)
                        .title("销售数据")
                        .subtitle("2024年")
                        .theme(.ocean)
                        .xAxisLabels(["Q1","Q2","Q3","Q4"])
                        .yAxisTitle("万元")
                        .series([...])
                    """)
                    .font(.system(size: 12, design: .monospaced))
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)

                infoCard(
                    title: "链式语法",
                    description: "所有配置方法均返回 Self，支持流式链式调用。一行代码完成图表全部配置，代码简洁优雅。"
                )
            }
            .padding()
        }
        .navigationTitle("链式语法")
        .onAppear { setupModel() }
    }

    private func setupModel() {
        model
            .chartType(.column)
            .title("链式语法演示")
            .subtitle("点击按钮切换图表类型")
            .xAxisLabels(["Spring", "Summer", "Autumn", "Winter"])
            .xAxisTitle("季节")
            .yAxisTitle("数值")
            .theme(.ocean)
            .series([
                AASeriesItem(name: "系列A", data: [45, 78, 62, 88]),
                AASeriesItem(name: "系列B", data: [32, 55, 80, 45])
            ])
    }
}

// MARK: - Info Card Helper

private func infoCard(title: String, description: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.subheadline.weight(.semibold))
        Text(description)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .padding(.horizontal)
}

#Preview {
    NavigationStack {
        ChartDemoView()
    }
}
