import SwiftUI

struct AAChartView: View {
    @ObservedObject var model: AAChartModel
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            headerView
            chartContent
                .padding(.horizontal, 4)
        }
        .padding()
        .background(model.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeInOut(duration: model.animationDuration)) {
                animationProgress = 1
            }
        }
        .onChange(of: model.chartType) { _, _ in
            animationProgress = 0
            withAnimation(.easeInOut(duration: model.animationDuration)) {
                animationProgress = 1
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 4) {
            if !model.title.isEmpty {
                Text(model.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            if !model.subtitle.isEmpty {
                Text(model.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Chart Content

    @ViewBuilder
    private var chartContent: some View {
        if model.chartType == .bar {
            barChartLayout
        } else if model.inverted {
            invertedChartLayout
        } else {
            normalChartLayout
        }
    }

    // MARK: - Normal Layout (vertical X, vertical Y)

    private var normalChartLayout: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 0) {
                yAxisView
                GeometryReader { geo in
                    chartBody(in: geo.size)
                }
            }
            .frame(height: 200)
            xAxisView
            legendView
        }
    }

    // MARK: - Bar Chart Layout (independent horizontal bars)

    private var barChartLayout: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top, spacing: 0) {
                barYAxisLabels
                GeometryReader { geo in
                    barChartBody(in: geo.size)
                }
            }
            .frame(height: 200)
            barXAxisView
            legendView
        }
    }

    // MARK: - Inverted Layout (X/Y axes swapped for all types)

    private var invertedChartLayout: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top, spacing: 0) {
                invertedYAxisLabels
                GeometryReader { geo in
                    invertedChartBody(in: geo.size)
                }
            }
            .frame(height: 200)
            invertedXAxisView
            legendView
        }
    }

    // MARK: - Normal Chart Body

    private func chartBody(in size: CGSize) -> some View {
        ZStack(alignment: .bottomLeading) {
            gridLines(in: size, horizontal: true)

            switch model.chartType {
            case .column:
                columnChart(in: size)
            case .bar:
                EmptyView()
            case .line:
                lineChart(in: size, curved: false, filled: false)
            case .spline:
                lineChart(in: size, curved: true, filled: false)
            case .area:
                lineChart(in: size, curved: false, filled: true)
            case .areaspline:
                lineChart(in: size, curved: true, filled: true)
            }
        }
    }

    // MARK: - Bar Chart Body (horizontal bars, independent)

    private func barChartBody(in size: CGSize) -> some View {
        let dataCount = model.series.first?.data.count ?? 0
        let seriesCount = model.series.count
        let groupHeight = size.height / CGFloat(max(dataCount, 1))
        let barHeight = groupHeight * 0.6 / CGFloat(max(seriesCount, 1))

        return ZStack(alignment: .topLeading) {
            gridLines(in: size, horizontal: false)

            ForEach(0..<dataCount, id: \.self) { dataIndex in
                ForEach(0..<seriesCount, id: \.self) { seriesIndex in
                    let value = model.series[seriesIndex].data[dataIndex]
                    let normalizedWidth = normalizeValue(value) * size.width * animationProgress
                    let yOffset = CGFloat(dataIndex) * groupHeight + (groupHeight - barHeight * CGFloat(seriesCount)) / 2 + CGFloat(seriesIndex) * barHeight

                    RoundedRectangle(cornerRadius: 3)
                        .fill(seriesColor(at: seriesIndex))
                        .frame(width: max(normalizedWidth, 0), height: barHeight - 1)
                        .offset(x: 0, y: yOffset)
                }
            }
        }
    }

    // MARK: - Inverted Chart Body (X/Y swapped for column/line/spline/area/areaspline)

    private func invertedChartBody(in size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            gridLines(in: size, horizontal: false)

            switch model.chartType {
            case .column:
                invertedColumnChart(in: size)
            case .bar:
                EmptyView()
            case .line:
                invertedLineChart(in: size, curved: false, filled: false)
            case .spline:
                invertedLineChart(in: size, curved: true, filled: false)
            case .area:
                invertedLineChart(in: size, curved: false, filled: true)
            case .areaspline:
                invertedLineChart(in: size, curved: true, filled: true)
            }
        }
    }

    // MARK: - Inverted Column (horizontal bars)

    private func invertedColumnChart(in size: CGSize) -> some View {
        let dataCount = model.series.first?.data.count ?? 0
        let seriesCount = model.series.count
        let groupHeight = size.height / CGFloat(max(dataCount, 1))
        let barHeight = groupHeight * 0.6 / CGFloat(max(seriesCount, 1))

        return ForEach(0..<dataCount, id: \.self) { dataIndex in
            ForEach(0..<seriesCount, id: \.self) { seriesIndex in
                let value = model.series[seriesIndex].data[dataIndex]
                let normalizedWidth = normalizeValue(value) * size.width * animationProgress
                let yOffset = CGFloat(dataIndex) * groupHeight + (groupHeight - barHeight * CGFloat(seriesCount)) / 2 + CGFloat(seriesIndex) * barHeight

                RoundedRectangle(cornerRadius: 3)
                    .fill(seriesColor(at: seriesIndex))
                    .frame(width: max(normalizedWidth, 0), height: barHeight - 1)
                    .offset(x: 0, y: yOffset)
            }
        }
    }

    // MARK: - Inverted Line/Area Chart (X/Y axes swapped)

    private func invertedLineChart(in size: CGSize, curved: Bool, filled: Bool) -> some View {
        ForEach(model.series.indices, id: \.self) { seriesIndex in
            let data = model.series[seriesIndex].data
            let color = seriesColor(at: seriesIndex)

            ZStack {
                if data.count < 2 {
                    singlePointView(data: data, in: size, color: color, inverted: true)
                } else {
                    if filled {
                        invertedFilledPath(data: data, in: size, curved: curved)
                            .fill(color.opacity(0.2 * animationProgress))
                    }
                    invertedLinePath(data: data, in: size, curved: curved)
                        .trim(from: 0, to: animationProgress)
                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    invertedPointDots(data: data, in: size, color: color)
                }
            }
        }
    }

    private func invertedDataPoints(data: [Double], in size: CGSize) -> [CGPoint] {
        guard data.count > 1 else { return [] }
        let step = size.height / CGFloat(data.count - 1)
        return data.enumerated().map { i, value in
            CGPoint(x: normalizeValue(value) * size.width, y: CGFloat(i) * step)
        }
    }

    private func invertedLinePath(data: [Double], in size: CGSize, curved: Bool) -> Path {
        Path { path in
            guard data.count > 1 else { return }
            let points = invertedDataPoints(data: data, in: size)
            path.move(to: points[0])

            if curved {
                for i in 1..<points.count {
                    let prev = points[i - 1]
                    let curr = points[i]
                    let midY = (prev.y + curr.y) / 2
                    path.addCurve(to: curr,
                                  control1: CGPoint(x: prev.x, y: midY),
                                  control2: CGPoint(x: curr.x, y: midY))
                }
            } else {
                for i in 1..<points.count {
                    path.addLine(to: points[i])
                }
            }
        }
    }

    private func invertedFilledPath(data: [Double], in size: CGSize, curved: Bool) -> Path {
        Path { path in
            guard data.count > 1 else { return }
            let points = invertedDataPoints(data: data, in: size)
            path.move(to: CGPoint(x: 0, y: points[0].y))
            path.addLine(to: points[0])

            if curved {
                for i in 1..<points.count {
                    let prev = points[i - 1]
                    let curr = points[i]
                    let midY = (prev.y + curr.y) / 2
                    path.addCurve(to: curr,
                                  control1: CGPoint(x: prev.x, y: midY),
                                  control2: CGPoint(x: curr.x, y: midY))
                }
            } else {
                for i in 1..<points.count {
                    path.addLine(to: points[i])
                }
            }

            path.addLine(to: CGPoint(x: 0, y: points.last!.y))
            path.closeSubpath()
        }
    }

    private func invertedPointDots(data: [Double], in size: CGSize, color: Color) -> some View {
        let points = invertedDataPoints(data: data, in: size)
        return ForEach(points.indices, id: \.self) { i in
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .position(points[i])
                .opacity(Double(animationProgress))
        }
    }

    // MARK: - Column Chart (vertical)

    private func columnChart(in size: CGSize) -> some View {
        let dataCount = model.series.first?.data.count ?? 0
        let seriesCount = model.series.count
        let groupWidth = size.width / CGFloat(max(dataCount, 1))
        let barWidth = groupWidth * 0.6 / CGFloat(max(seriesCount, 1))

        return HStack(alignment: .bottom, spacing: 0) {
            ForEach(0..<dataCount, id: \.self) { dataIndex in
                HStack(alignment: .bottom, spacing: 1) {
                    ForEach(0..<seriesCount, id: \.self) { seriesIndex in
                        let value = model.series[seriesIndex].data[dataIndex]
                        let barHeight = normalizeValue(value) * size.height * animationProgress

                        RoundedRectangle(cornerRadius: 3)
                            .fill(seriesColor(at: seriesIndex))
                            .frame(width: barWidth, height: max(barHeight, 0))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Line / Area Chart (normal orientation)

    private func lineChart(in size: CGSize, curved: Bool, filled: Bool) -> some View {
        ForEach(model.series.indices, id: \.self) { seriesIndex in
            let data = model.series[seriesIndex].data
            let color = seriesColor(at: seriesIndex)

            ZStack {
                if data.count < 2 {
                    singlePointView(data: data, in: size, color: color, inverted: false)
                } else {
                    if filled {
                        filledPath(data: data, in: size, curved: curved)
                            .fill(color.opacity(0.2 * animationProgress))
                    }
                    linePath(data: data, in: size, curved: curved)
                        .trim(from: 0, to: animationProgress)
                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    pointDots(data: data, in: size, color: color)
                }
            }
        }
    }

    // MARK: - Single Point Fallback

    @ViewBuilder
    private func singlePointView(data: [Double], in size: CGSize, color: Color, inverted: Bool) -> some View {
        if let value = data.first {
            let normalized = normalizeValue(value)
            let point = inverted
                ? CGPoint(x: normalized * size.width, y: size.height / 2)
                : CGPoint(x: size.width / 2, y: size.height - normalized * size.height)
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .position(point)
                .opacity(Double(animationProgress))
        }
    }

    private func linePath(data: [Double], in size: CGSize, curved: Bool) -> Path {
        Path { path in
            guard data.count > 1 else { return }
            let points = dataPoints(data: data, in: size)
            path.move(to: points[0])

            if curved {
                for i in 1..<points.count {
                    let prev = points[i - 1]
                    let curr = points[i]
                    let midX = (prev.x + curr.x) / 2
                    path.addCurve(to: curr,
                                  control1: CGPoint(x: midX, y: prev.y),
                                  control2: CGPoint(x: midX, y: curr.y))
                }
            } else {
                for i in 1..<points.count {
                    path.addLine(to: points[i])
                }
            }
        }
    }

    private func filledPath(data: [Double], in size: CGSize, curved: Bool) -> Path {
        Path { path in
            guard data.count > 1 else { return }
            let points = dataPoints(data: data, in: size)
            path.move(to: CGPoint(x: points[0].x, y: size.height))
            path.addLine(to: points[0])

            if curved {
                for i in 1..<points.count {
                    let prev = points[i - 1]
                    let curr = points[i]
                    let midX = (prev.x + curr.x) / 2
                    path.addCurve(to: curr,
                                  control1: CGPoint(x: midX, y: prev.y),
                                  control2: CGPoint(x: midX, y: curr.y))
                }
            } else {
                for i in 1..<points.count {
                    path.addLine(to: points[i])
                }
            }

            path.addLine(to: CGPoint(x: points.last!.x, y: size.height))
            path.closeSubpath()
        }
    }

    private func pointDots(data: [Double], in size: CGSize, color: Color) -> some View {
        let points = dataPoints(data: data, in: size)
        return ForEach(points.indices, id: \.self) { i in
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .position(points[i])
                .opacity(Double(animationProgress))
        }
    }

    // MARK: - Grid

    private func gridLines(in size: CGSize, horizontal: Bool) -> some View {
        let ticks = yAxisTicks
        return ZStack {
            if horizontal {
                ForEach(ticks, id: \.self) { value in
                    let y = size.height - (normalizeValue(value) * size.height)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                }
            } else {
                ForEach(ticks, id: \.self) { value in
                    let x = normalizeValue(value) * size.width
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                }
            }
        }
    }

    // MARK: - Axis Views for Bar Chart

    private var barYAxisLabels: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if !model.xAxisTitle.isEmpty {
                Text(model.xAxisTitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)
            }
            let dataCount = model.series.first?.data.count ?? 0
            ForEach(0..<dataCount, id: \.self) { i in
                let label = i < model.xAxisLabels.count ? model.xAxisLabels[i] : "\(i + 1)"
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .frame(maxHeight: .infinity)
                    .lineLimit(1)
            }
        }
        .frame(width: 50)
    }

    private var barXAxisView: some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                Spacer().frame(width: 50)
                ForEach(yAxisTicks, id: \.self) { value in
                    Text(formatAxisValue(value))
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            if !model.yAxisTitle.isEmpty {
                Text(model.yAxisTitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Axis Views for Inverted Chart

    private var invertedYAxisLabels: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if !model.xAxisTitle.isEmpty {
                Text(model.xAxisTitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)
            }
            let dataCount = model.series.first?.data.count ?? 0
            ForEach(0..<dataCount, id: \.self) { i in
                let label = i < model.xAxisLabels.count ? model.xAxisLabels[i] : "\(i + 1)"
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .frame(maxHeight: .infinity)
                    .lineLimit(1)
            }
        }
        .frame(width: 50)
    }

    private var invertedXAxisView: some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                Spacer().frame(width: 50)
                ForEach(yAxisTicks, id: \.self) { value in
                    Text(formatAxisValue(value))
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            if !model.yAxisTitle.isEmpty {
                Text(model.yAxisTitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Normal Y Axis

    private var yAxisView: some View {
        VStack(alignment: .trailing) {
            if !model.yAxisTitle.isEmpty {
                Text(model.yAxisTitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(-90))
                    .fixedSize()
                    .frame(width: 12)
            }
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(yAxisTicks.reversed(), id: \.self) { value in
                    Text(formatAxisValue(value))
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    if value != yAxisTicks.first {
                        Spacer()
                    }
                }
            }
            .frame(width: 35)
        }
    }

    // MARK: - Normal X Axis

    private var xAxisView: some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                Spacer().frame(width: model.yAxisTitle.isEmpty ? 35 : 47)
                if model.xAxisLabels.isEmpty {
                    let count = model.series.first?.data.count ?? 0
                    ForEach(0..<count, id: \.self) { i in
                        Text("\(i + 1)")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    ForEach(model.xAxisLabels.indices, id: \.self) { i in
                        Text(model.xAxisLabels[i])
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .lineLimit(1)
                    }
                }
            }
            if !model.xAxisTitle.isEmpty {
                Text(model.xAxisTitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: 12) {
            ForEach(model.series.indices, id: \.self) { i in
                HStack(spacing: 4) {
                    Circle()
                        .fill(seriesColor(at: i))
                        .frame(width: 8, height: 8)
                    Text(model.series[i].name)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Helpers

    private func dataPoints(data: [Double], in size: CGSize) -> [CGPoint] {
        guard data.count > 1 else { return [] }
        let step = size.width / CGFloat(data.count - 1)
        return data.enumerated().map { i, value in
            CGPoint(x: CGFloat(i) * step, y: size.height - normalizeValue(value) * size.height)
        }
    }

    private var dataMin: Double {
        model.yAxisMin ?? (model.series.flatMap(\.data).min() ?? 0)
    }

    private var dataMax: Double {
        model.yAxisMax ?? (model.series.flatMap(\.data).max() ?? 1)
    }

    private func normalizeValue(_ value: Double) -> CGFloat {
        let min = dataMin
        let max = dataMax
        guard max > min else { return 0 }
        return CGFloat((value - min) / (max - min))
    }

    private var yAxisTicks: [Double] {
        let min = dataMin
        let max = dataMax
        let step = (max - min) / 4
        return (0...4).map { min + Double($0) * step }
    }

    private func formatAxisValue(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private func seriesColor(at index: Int) -> Color {
        let colors = model.theme.colors
        return colors[index % colors.count]
    }
}
