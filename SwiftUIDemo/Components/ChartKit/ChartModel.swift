import SwiftUI
import Combine

// MARK: - Chart Type

enum AAChartType: String, CaseIterable {
    case column = "柱状图"
    case bar = "条形图"
    case line = "折线图"
    case spline = "曲线图"
    case area = "面积图"
    case areaspline = "曲线面积图"
}

// MARK: - Theme

enum AAChartTheme: CaseIterable {
    case `default`
    case ocean
    case forest
    case sunset
    case purple

    var colors: [Color] {
        switch self {
        case .default:
            return [.blue, .green, .orange, .red, .purple]
        case .ocean:
            return [Color(hex: "0077B6"), Color(hex: "00B4D8"), Color(hex: "90E0EF"), Color(hex: "023E8A"), Color(hex: "48CAE4")]
        case .forest:
            return [Color(hex: "2D6A4F"), Color(hex: "40916C"), Color(hex: "52B788"), Color(hex: "74C69D"), Color(hex: "95D5B2")]
        case .sunset:
            return [Color(hex: "FF6B6B"), Color(hex: "FFA06B"), Color(hex: "FFD93D"), Color(hex: "FF8FA3"), Color(hex: "C9184A")]
        case .purple:
            return [Color(hex: "7209B7"), Color(hex: "560BAD"), Color(hex: "480CA8"), Color(hex: "3A0CA3"), Color(hex: "B5179E")]
        }
    }

    var name: String {
        switch self {
        case .default: return "默认"
        case .ocean: return "海洋"
        case .forest: return "森林"
        case .sunset: return "日落"
        case .purple: return "紫色"
        }
    }
}

// MARK: - Series Data

struct AASeriesItem: Identifiable {
    let id = UUID()
    var name: String
    var data: [Double]
}

// MARK: - Chart Model (Chain Syntax)

class AAChartModel: ObservableObject {
    @Published var chartType: AAChartType = .column
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var backgroundColor: Color = .white
    @Published var theme: AAChartTheme = .default
    @Published var inverted: Bool = false

    @Published var xAxisLabels: [String] = []
    @Published var xAxisTitle: String = ""
    @Published var yAxisTitle: String = ""
    @Published var yAxisMin: Double?
    @Published var yAxisMax: Double?

    @Published var series: [AASeriesItem] = []
    @Published var animationDuration: Double = 0.6

    // MARK: - Chain Methods

    @discardableResult
    func chartType(_ type: AAChartType) -> Self {
        self.chartType = type
        return self
    }

    @discardableResult
    func title(_ title: String) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func subtitle(_ subtitle: String) -> Self {
        self.subtitle = subtitle
        return self
    }

    @discardableResult
    func backgroundColor(_ color: Color) -> Self {
        self.backgroundColor = color
        return self
    }

    @discardableResult
    func theme(_ theme: AAChartTheme) -> Self {
        self.theme = theme
        return self
    }

    @discardableResult
    func inverted(_ inverted: Bool) -> Self {
        self.inverted = inverted
        return self
    }

    @discardableResult
    func xAxisLabels(_ labels: [String]) -> Self {
        self.xAxisLabels = labels
        return self
    }

    @discardableResult
    func xAxisTitle(_ title: String) -> Self {
        self.xAxisTitle = title
        return self
    }

    @discardableResult
    func yAxisTitle(_ title: String) -> Self {
        self.yAxisTitle = title
        return self
    }

    @discardableResult
    func yAxisMin(_ min: Double) -> Self {
        self.yAxisMin = min
        return self
    }

    @discardableResult
    func yAxisMax(_ max: Double) -> Self {
        self.yAxisMax = max
        return self
    }

    @discardableResult
    func series(_ series: [AASeriesItem]) -> Self {
        self.series = series
        return self
    }

    @discardableResult
    func animationDuration(_ duration: Double) -> Self {
        self.animationDuration = duration
        return self
    }
}

