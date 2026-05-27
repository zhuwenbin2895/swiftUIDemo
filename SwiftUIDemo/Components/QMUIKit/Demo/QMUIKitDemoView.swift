import SwiftUI
import UIKit

// MARK: - Main Demo List View

struct QMUIKitDemoView: View {
    var body: some View {
        List {
            Section("全局配置") {
                NavigationLink("主题管理") {
                    QMUIThemeDemoView()
                }
            }
            Section("UIView 扩展") {
                NavigationLink("Frame便捷属性") {
                    QMUIViewFrameDemoView()
                }
                NavigationLink("圆角/边框/阴影") {
                    QMUIViewStyleDemoView()
                }
            }
            Section("UIViewController 扩展") {
                NavigationLink("导航栏与返回拦截") {
                    QMUIViewControllerDemoWrapper()
                }
            }
            Section("UIImage 扩展") {
                NavigationLink("图片处理") {
                    QMUIImageDemoView()
                }
            }
            Section("UILabel 扩展") {
                NavigationLink("长按复制/内边距/行高") {
                    QMUILabelDemoView()
                }
            }
            Section("UIButton 扩展") {
                NavigationLink("图文布局/倒计时") {
                    QMUIButtonDemoView()
                }
            }
            Section("UITextField 扩展") {
                NavigationLink("占位符/内边距/最大长度") {
                    QMUITextFieldDemoView()
                }
            }
            Section("UITextView 扩展") {
                NavigationLink("占位符/自动高度") {
                    QMUITextViewDemoView()
                }
            }
            Section("弹窗组件") {
                NavigationLink("链式弹窗") {
                    QMUIAlertDemoView()
                }
            }
        }
        .navigationTitle("QMUIKit")
    }
}

// MARK: - Theme Demo

struct QMUIThemeDemoView: View {
    @ObservedObject private var themeManager = QMUIThemeManager.shared
    @State private var selectedMode: QMUIThemeMode = QMUIThemeManager.shared.themeMode
    @State private var cornerRadius: Double = Double(QMUIThemeManager.shared.cornerRadius)
    @State private var fontSize: Double = Double(QMUIThemeManager.shared.fontSize)
    @State private var selectedColor: Color = Color(QMUIThemeManager.shared.primaryColor)

    var body: some View {
        Form {
            Section("主题模式") {
                Picker("模式", selection: $selectedMode) {
                    Text("浅色").tag(QMUIThemeMode.light)
                    Text("深色").tag(QMUIThemeMode.dark)
                    Text("跟随系统").tag(QMUIThemeMode.system)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedMode) { _, newValue in
                    themeManager.themeMode = newValue
                }
            }

            Section("主题色") {
                ColorPicker("主色调", selection: $selectedColor)
                    .onChange(of: selectedColor) { _, newValue in
                        themeManager.primaryColor = UIColor(newValue)
                    }
            }

            Section("全局圆角: \(Int(cornerRadius))pt") {
                Slider(value: $cornerRadius, in: 0...24, step: 1)
                    .onChange(of: cornerRadius) { _, newValue in
                        themeManager.cornerRadius = CGFloat(newValue)
                    }
                RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                    .fill(selectedColor)
                    .frame(height: 60)
            }

            Section("全局字号: \(Int(fontSize))pt") {
                Slider(value: $fontSize, in: 12...24, step: 1)
                    .onChange(of: fontSize) { _, newValue in
                        themeManager.fontSize = CGFloat(newValue)
                    }
                Text("示例文本 Sample Text")
                    .font(.system(size: fontSize))
            }

            Section("预览卡片") {
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                        .fill(selectedColor)
                        .frame(height: 44)
                        .overlay(
                            Text("主按钮")
                                .font(.system(size: fontSize, weight: .medium))
                                .foregroundColor(.white)
                        )
                    RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                        .stroke(selectedColor, lineWidth: 1)
                        .frame(height: 44)
                        .overlay(
                            Text("次按钮")
                                .font(.system(size: fontSize, weight: .medium))
                                .foregroundColor(selectedColor)
                        )
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("主题管理")
    }
}

// MARK: - UIView Frame Demo

struct QMUIViewFrameDemoView: View {
    @State private var viewInfo = "点击按钮查看"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("Frame 便捷属性") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("qmui_x / qmui_y / qmui_width / qmui_height")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("qmui_right / qmui_bottom / qmui_centerX / qmui_centerY")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        FrameDemoRepresentable(info: $viewInfo)
                            .frame(height: 150)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)

                        Text(viewInfo)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("移除所有子视图") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("view.qmui_removeAllSubviews()")
                            .font(.system(.caption, design: .monospaced))
                        Text("移除当前视图的所有子视图")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("获取所在控制器") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("view.qmui_viewController")
                            .font(.system(.caption, design: .monospaced))
                        Text("沿响应者链查找当前视图所属的 UIViewController")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("Frame便捷属性")
    }
}

struct FrameDemoRepresentable: UIViewRepresentable {
    @Binding var info: String

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let box = UIView(frame: CGRect(x: 20, y: 20, width: 100, height: 80))
        box.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        box.layer.borderColor = UIColor.systemBlue.cgColor
        box.layer.borderWidth = 2
        box.tag = 100
        container.addSubview(box)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            info = """
            x=\(box.qmui_x) y=\(box.qmui_y) w=\(box.qmui_width) h=\(box.qmui_height)
            right=\(box.qmui_right) bottom=\(box.qmui_bottom)
            centerX=\(box.qmui_centerX) centerY=\(box.qmui_centerY)
            """
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - UIView Style Demo

struct QMUIViewStyleDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("圆角设置") {
                    ViewStyleRepresentable(type: .cornerRadius)
                        .frame(height: 100)
                }
                GroupBox("边框设置") {
                    ViewStyleRepresentable(type: .border)
                        .frame(height: 100)
                }
                GroupBox("阴影设置") {
                    ViewStyleRepresentable(type: .shadow)
                        .frame(height: 120)
                }
            }
            .padding()
        }
        .navigationTitle("圆角/边框/阴影")
    }
}

enum ViewStyleType {
    case cornerRadius, border, shadow
}

struct ViewStyleRepresentable: UIViewRepresentable {
    let type: ViewStyleType

    func makeUIView(context: Context) -> UIView {
        let container = UIView()

        let box = UIView(frame: CGRect(x: 20, y: 10, width: 80, height: 80))
        box.backgroundColor = .systemBlue

        switch type {
        case .cornerRadius:
            box.qmui_setCornerRadius(16)
            let box2 = UIView(frame: CGRect(x: 120, y: 10, width: 80, height: 80))
            box2.backgroundColor = .systemGreen
            box2.qmui_setCornerRadius(16, corners: [.topLeft, .bottomRight])
            container.addSubview(box2)

            let label1 = UILabel(frame: CGRect(x: 20, y: 92, width: 80, height: 20))
            label1.text = "全圆角"
            label1.font = .systemFont(ofSize: 11)
            label1.textAlignment = .center
            container.addSubview(label1)

            let label2 = UILabel(frame: CGRect(x: 120, y: 92, width: 80, height: 20))
            label2.text = "部分圆角"
            label2.font = .systemFont(ofSize: 11)
            label2.textAlignment = .center
            container.addSubview(label2)

        case .border:
            box.qmui_setBorder(color: .systemRed, width: 3)
            box.qmui_setCornerRadius(8)

            let box2 = UIView(frame: CGRect(x: 120, y: 10, width: 80, height: 80))
            box2.backgroundColor = .systemYellow
            box2.qmui_setBorder(color: .systemOrange, width: 2)
            box2.layer.cornerRadius = 40
            container.addSubview(box2)

        case .shadow:
            box.qmui_setShadow(color: .black, offset: CGSize(width: 0, height: 4), radius: 8, opacity: 0.3)
            box.qmui_setCornerRadius(12)
        }

        container.addSubview(box)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - UIViewController Demo

struct QMUIViewControllerDemoWrapper: View {
    var body: some View {
        VCDemoRepresentable()
            .navigationTitle("ViewController扩展")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct VCDemoRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> VCDemoController {
        VCDemoController()
    }
    func updateUIViewController(_ uiViewController: VCDemoController, context: Context) {}
}

class VCDemoController: UIViewController {
    private let infoLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        let items: [(String, String)] = [
            ("qmui_prefersNavigationBarHidden", "隐藏导航栏"),
            ("qmui_statusBarStyle", "状态栏样式控制"),
            ("qmui_adjustScrollViewInsets(_:)", "自动计算滚动视图内边距"),
            ("qmui_interceptBackAction", "拦截返回事件（闭包返回 Bool）")
        ]

        for item in items {
            let label = UILabel()
            label.numberOfLines = 0
            let attr = NSMutableAttributedString()
            attr.append(NSAttributedString(
                string: item.0 + "\n",
                attributes: [.font: UIFont.monospacedSystemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.systemBlue]
            ))
            attr.append(NSAttributedString(
                string: item.1,
                attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.secondaryLabel]
            ))
            label.attributedText = attr
            stackView.addArrangedSubview(label)
        }

        qmui_interceptBackAction = { [weak self] in
            let alert = UIAlertController(title: "拦截返回", message: "确定要返回吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                self?.navigationController?.popViewController(animated: true)
            })
            self?.present(alert, animated: true)
            return false
        }
    }
}

// MARK: - UIImage Demo

struct QMUIImageDemoView: View {
    @State private var colorImage: UIImage?
    @State private var tintedImage: UIImage?
    @State private var roundedImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("颜色生成图片") {
                    HStack(spacing: 12) {
                        if let img = colorImage {
                            Image(uiImage: img)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        }
                        VStack(alignment: .leading) {
                            Text("UIImage.qmui_image(color:size:)")
                                .font(.system(.caption, design: .monospaced))
                            Text("纯色生成指定尺寸图片")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("染色") {
                    HStack(spacing: 12) {
                        if let img = tintedImage {
                            Image(uiImage: img)
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        VStack(alignment: .leading) {
                            Text("image.qmui_tintImage(color:)")
                                .font(.system(.caption, design: .monospaced))
                            Text("对图片进行染色处理")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("异步圆角") {
                    HStack(spacing: 12) {
                        if let img = roundedImage {
                            Image(uiImage: img)
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                        VStack(alignment: .leading) {
                            Text("image.qmui_asyncCornerRadius(_:size:)")
                                .font(.system(.caption, design: .monospaced))
                            Text("异步线程切圆角，避免主线程卡顿")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("压缩指定大小") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("image.qmui_compress(toMaxBytes:)")
                            .font(.system(.caption, design: .monospaced))
                        Text("自动压缩至指定字节大小以内")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("拉伸保护") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("image.qmui_stretchableImage()")
                            .font(.system(.caption, design: .monospaced))
                        Text("从中心点拉伸，保护边缘不变形")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .navigationTitle("图片处理")
        .onAppear {
            colorImage = UIImage.qmui_image(color: .systemBlue, size: CGSize(width: 60, height: 60))

            let baseImage = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
            tintedImage = baseImage?.qmui_tintImage(color: .systemOrange)

            if let source = UIImage.qmui_image(color: .systemPurple, size: CGSize(width: 60, height: 60)) {
                source.qmui_asyncCornerRadius(20, size: CGSize(width: 60, height: 60)) { result in
                    roundedImage = result
                }
            }
        }
    }
}

// MARK: - UILabel Demo

struct QMUILabelDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("长按复制") {
                    LabelCopyDemoRepresentable()
                        .frame(height: 60)
                }
                GroupBox("内边距 Label") {
                    LabelPaddingDemoRepresentable()
                        .frame(height: 60)
                }
                GroupBox("行高调整") {
                    LabelLineHeightDemoRepresentable()
                        .frame(height: 100)
                }
            }
            .padding()
        }
        .navigationTitle("UILabel扩展")
    }
}

struct LabelCopyDemoRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let label = UILabel(frame: CGRect(x: 16, y: 10, width: 280, height: 40))
        label.text = "长按我可以复制文本内容"
        label.font = .systemFont(ofSize: 16)
        label.qmui_copyEnabled = true
        label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        container.addSubview(label)
        return container
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct LabelPaddingDemoRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let label = QMUIPaddedLabel(frame: CGRect(x: 16, y: 10, width: 200, height: 40))
        label.text = "带内边距的Label"
        label.contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        container.addSubview(label)
        return container
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct LabelLineHeightDemoRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let label = UILabel(frame: CGRect(x: 16, y: 10, width: 280, height: 80))
        label.numberOfLines = 0
        label.text = "这是第一行文本\n这是第二行文本\n这是第三行文本"
        label.font = .systemFont(ofSize: 15)
        label.qmui_setLineHeight(28)
        container.addSubview(label)
        return container
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - UIButton Demo

struct QMUIButtonDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("图文位置调整") {
                    ButtonLayoutDemoRepresentable()
                        .frame(height: 200)
                }
                GroupBox("按钮倒计时") {
                    ButtonCountdownDemoRepresentable()
                        .frame(height: 60)
                }
            }
            .padding()
        }
        .navigationTitle("UIButton扩展")
    }
}

struct ButtonLayoutDemoRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView()

        let positions: [(QMUIButtonImagePosition, String, CGRect)] = [
            (.left, "左图右文", CGRect(x: 16, y: 10, width: 140, height: 40)),
            (.right, "左文右图", CGRect(x: 170, y: 10, width: 140, height: 40)),
            (.top, "上图下文", CGRect(x: 16, y: 70, width: 120, height: 80)),
            (.bottom, "下图上文", CGRect(x: 170, y: 70, width: 120, height: 80))
        ]

        for (position, title, frame) in positions {
            let button = UIButton(type: .system)
            button.frame = frame
            button.setTitle(title, for: .normal)
            button.setImage(UIImage(systemName: "star.fill"), for: .normal)
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
            button.layer.cornerRadius = 8
            container.addSubview(button)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                button.qmui_setImagePosition(position, spacing: 8)
            }
        }

        return container
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ButtonCountdownDemoRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 16, y: 10, width: 180, height: 40)
        button.setTitle("获取验证码", for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.addTarget(context.coordinator, action: #selector(Coordinator.countdownTapped(_:)), for: .touchUpInside)
        container.addSubview(button)
        return container
    }
    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject {
        @objc func countdownTapped(_ sender: UIButton) {
            sender.qmui_startCountdown(seconds: 10)
        }
    }
}

// MARK: - UITextField Demo

struct QMUITextFieldDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("占位符颜色") {
                    TextFieldDemoRepresentable(type: .placeholderColor)
                        .frame(height: 50)
                }
                GroupBox("输入框内边距") {
                    TextFieldDemoRepresentable(type: .insets)
                        .frame(height: 50)
                }
                GroupBox("最大长度限制 (10字符)") {
                    TextFieldDemoRepresentable(type: .maxLength)
                        .frame(height: 50)
                }
            }
            .padding()
        }
        .navigationTitle("UITextField扩展")
    }
}

enum TextFieldDemoType {
    case placeholderColor, insets, maxLength
}

struct TextFieldDemoRepresentable: UIViewRepresentable {
    let type: TextFieldDemoType

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let textField = QMUITextField(frame: CGRect(x: 16, y: 5, width: 280, height: 40))
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.layer.cornerRadius = 8

        switch type {
        case .placeholderColor:
            textField.placeholder = "红色占位符"
            textField.qmui_placeholderColor = .systemRed
            textField.qmui_textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        case .insets:
            textField.placeholder = "大内边距输入框"
            textField.qmui_textInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        case .maxLength:
            textField.placeholder = "最多输入10个字符"
            textField.qmui_maxLength = 10
            textField.qmui_textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }

        container.addSubview(textField)
        return container
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - UITextView Demo

struct QMUITextViewDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("占位符文本") {
                    TextViewDemoRepresentable(type: .placeholder)
                        .frame(height: 100)
                }
                GroupBox("自动高度 (最大120pt)") {
                    TextViewDemoRepresentable(type: .autoHeight)
                        .frame(height: 130)
                }
            }
            .padding()
        }
        .navigationTitle("UITextView扩展")
    }
}

enum TextViewDemoType {
    case placeholder, autoHeight
}

struct TextViewDemoRepresentable: UIViewRepresentable {
    let type: TextViewDemoType

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let textView = QMUITextView(frame: CGRect(x: 16, y: 5, width: 280, height: 90))
        textView.font = .systemFont(ofSize: 15)
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.layer.cornerRadius = 8

        switch type {
        case .placeholder:
            textView.qmui_placeholder = "请输入内容..."
            textView.qmui_placeholderColor = .placeholderText

        case .autoHeight:
            textView.qmui_placeholder = "输入文字自动增高..."
            textView.qmui_autoHeight = true
            textView.qmui_maxHeight = 120
        }

        container.addSubview(textView)
        return container
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Alert Demo

struct QMUIAlertDemoView: View {
    var body: some View {
        List {
            Button("基础弹窗") {
                showBasicAlert()
            }
            Button("多按钮弹窗") {
                showMultiActionAlert()
            }
            Button("富文本弹窗") {
                showRichTextAlert()
            }
            Button("自定义视图弹窗") {
                showCustomViewAlert()
            }
            Button("ActionSheet") {
                showActionSheet()
            }
        }
        .navigationTitle("链式弹窗")
    }

    private func getTopVC() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              var topVC = window.rootViewController else { return nil }
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }

    private func showBasicAlert() {
        guard let vc = getTopVC() else { return }
        QMUIAlertBuilder()
            .setTitle("提示")
            .setMessage("这是一个基础弹窗示例")
            .addAction(title: "确定")
            .show(in: vc)
    }

    private func showMultiActionAlert() {
        guard let vc = getTopVC() else { return }
        QMUIAlertBuilder()
            .setTitle("确认操作")
            .setMessage("你确定要执行此操作吗？此操作不可撤销。")
            .addAction(title: "取消", style: .cancel)
            .addAction(title: "删除", style: .destructive) {
                print("删除操作执行")
            }
            .show(in: vc)
    }

    private func showRichTextAlert() {
        guard let vc = getTopVC() else { return }
        let title = NSMutableAttributedString(string: "重要通知", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.systemRed
        ])
        let message = NSMutableAttributedString(string: "您的账户存在异常，请及时处理。", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ])

        QMUIAlertBuilder()
            .setAttributedTitle(title)
            .setAttributedMessage(message)
            .addAction(title: "去处理", style: .default)
            .addAction(title: "稍后再说", style: .cancel)
            .show(in: vc)
    }

    private func showCustomViewAlert() {
        guard let vc = getTopVC() else { return }

        let customView = UIView()
        customView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])

        QMUIAlertBuilder()
            .setTitle("操作成功")
            .setMessage("数据已保存")
            .setCustomView(customView)
            .addAction(title: "好的")
            .show(in: vc)
    }

    private func showActionSheet() {
        guard let vc = getTopVC() else { return }
        QMUIAlertBuilder()
            .setStyle(.actionSheet)
            .setTitle("选择操作")
            .addAction(title: "拍照")
            .addAction(title: "从相册选择")
            .addAction(title: "取消", style: .cancel)
            .show(in: vc)
    }
}

#Preview {
    NavigationStack {
        QMUIKitDemoView()
    }
}
