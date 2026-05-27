import SwiftUI

// MARK: - Carousel Type

enum iCarouselType: String, CaseIterable, Identifiable {
    case linear = "线性排列"
    case cylindrical = "圆形环绕"
    case coverFlow = "覆盖流"
    case timeMachine = "时间线轮播"
    case rotary = "旋转木马"
    case invertedCoverFlow = "倒转覆盖流"
    case custom = "自定义变换"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .linear: return "line.3.horizontal"
        case .cylindrical: return "circle.dashed"
        case .coverFlow: return "rectangle.stack"
        case .timeMachine: return "clock.arrow.circlepath"
        case .rotary: return "arrow.triangle.2.circlepath"
        case .invertedCoverFlow: return "rectangle.stack.fill"
        case .custom: return "slider.horizontal.3"
        }
    }
}

// MARK: - Carousel Item

struct iCarouselItem: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let color: Color
    let imageName: String
    var imageURL: String?

    static func == (lhs: iCarouselItem, rhs: iCarouselItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Transform Result

struct iCarouselTransform {
    var offset: CGSize = .zero
    var scale: CGFloat = 1.0
    var rotation3D: (angle: Double, axis: (x: CGFloat, y: CGFloat, z: CGFloat)) = (0, (0, 1, 0))
    var opacity: Double = 1.0
    var zIndex: Double = 0
    var anchorZ: CGFloat = 0
    var perspective: CGFloat = 0
}

// MARK: - Configuration

struct iCarouselConfig {
    var carouselType: iCarouselType = .coverFlow
    var isInfinite: Bool = true
    var autoScrollInterval: TimeInterval = 3.0
    var autoScrollEnabled: Bool = false
    var decelerationRate: CGFloat = 0.92
    var itemSpacing: CGFloat = 220
    var perspectiveDepth: CGFloat = 500
    var visibleItems: Int = 7
    var isUserScrollEnabled: Bool = true
    var itemSize: CGSize = CGSize(width: 200, height: 280)
    var parallaxFactor: CGFloat = 0.0
    var customTransform: ((CGFloat, CGSize) -> iCarouselTransform)?

    var tilt: CGFloat = 0.6
    var radius: CGFloat? = nil
}

// MARK: - Delegate Protocol

protocol iCarouselDelegate: AnyObject {
    func carouselDidScroll(offset: CGFloat)
    func carouselDidSelectItem(at index: Int)
    func carouselCurrentIndexChanged(to index: Int)
    func carouselWillBeginDragging()
    func carouselDidEndDragging()
}

extension iCarouselDelegate {
    func carouselDidScroll(offset: CGFloat) {}
    func carouselDidSelectItem(at index: Int) {}
    func carouselCurrentIndexChanged(to index: Int) {}
    func carouselWillBeginDragging() {}
    func carouselDidEndDragging() {}
}
