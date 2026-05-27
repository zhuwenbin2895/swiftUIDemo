import SwiftUI
import UIKit

struct TGLayoutRepresentable<T: TGBaseLayout>: UIViewRepresentable {
    let layout: T
    let configure: (T) -> Void

    init(_ layoutType: T.Type = T.self, configure: @escaping (T) -> Void) {
        self.layout = T()
        self.configure = configure
    }

    func makeUIView(context: Context) -> T {
        configure(layout)
        return layout
    }

    func updateUIView(_ uiView: T, context: Context) {
        configure(uiView)
        uiView.setNeedsLayout()
    }
}

struct TGLayoutWrapper: UIViewRepresentable {
    let makeLayout: () -> TGBaseLayout

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let layout = makeLayout()
        container.addSubview(layout)
        layout.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            layout.topAnchor.constraint(equalTo: container.topAnchor),
            layout.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            layout.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            layout.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.first?.setNeedsLayout()
    }
}

// MARK: - Layout Size Estimation

struct TGSizeEstimator {
    static func estimatedSize(for layout: TGBaseLayout, maxWidth: CGFloat = .greatestFiniteMagnitude, maxHeight: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        return layout.estimatedSize(maxWidth: maxWidth, maxHeight: maxHeight)
    }
}

// MARK: - Rotation Adaptive Layout

class TGRotationAdaptiveLayout: TGLinearLayout {

    init() {
        super.init(frame: .zero)
        self.orientation = .horizontal
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.orientation = .horizontal
    }

    override func layoutSubviews() {
        orientation = bounds.width > bounds.height ? .vertical : .horizontal
        super.layoutSubviews()
    }
}
