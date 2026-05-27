import SwiftUI

struct KeyboardManagerDemoView: View {
    var body: some View {
        List {
            Section("核心功能") {
                NavigationLink("自动避让输入框") { AutoAvoidDemoView() }
                NavigationLink("键盘事件回调") { KeyboardEventDemoView() }
            }
            Section("应用场景") {
                NavigationLink("表单自动滚动") { FormScrollDemoView() }
                NavigationLink("聊天输入框") { ChatInputDemoView() }
            }
        }
        .navigationTitle("KeyboardManager")
    }
}

// MARK: - Auto Avoid Demo

struct AutoAvoidDemoView: View {
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
    @State private var text4 = ""
    @State private var text5 = ""

    var body: some View {
        KeyboardAvoidingScrollView {
            VStack(spacing: 20) {
                Text("点击输入框，视图自动上移避免遮挡")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)

                GroupBox("基本信息") {
                    VStack(spacing: 12) {
                        TextField("姓名", text: $text1)
                            .textFieldStyle(.roundedBorder)
                        TextField("邮箱", text: $text2)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                GroupBox("联系方式") {
                    VStack(spacing: 12) {
                        TextField("电话", text: $text3)
                            .textFieldStyle(.roundedBorder)
                        TextField("地址", text: $text4)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                GroupBox("其他") {
                    TextField("备注信息（测试底部输入框遮挡）", text: $text5)
                        .textFieldStyle(.roundedBorder)
                }

                Color.clear.frame(height: 200)

                GroupBox("底部输入框") {
                    VStack(spacing: 12) {
                        TextField("这个输入框在页面底部", text: $text5)
                            .textFieldStyle(.roundedBorder)
                        Text("键盘弹出时自动上移")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("自动避让输入框")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Keyboard Event Demo

struct KeyboardEventDemoView: View {
    @StateObject private var keyboardManager = KeyboardManager()
    @State private var text = ""
    @State private var events: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section("键盘状态") {
                    HStack {
                        Text("状态")
                        Spacer()
                        Text(stateText)
                            .foregroundColor(stateColor)
                            .fontWeight(.medium)
                    }
                    HStack {
                        Text("高度")
                        Spacer()
                        Text("\(Int(keyboardManager.keyboardHeight))pt")
                            .foregroundColor(.blue)
                            .font(.system(.body, design: .monospaced))
                    }
                }

                Section("事件日志") {
                    if events.isEmpty {
                        Text("点击输入框触发键盘事件")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    ForEach(events.indices, id: \.self) { index in
                        Text(events[index])
                            .font(.system(size: 12, design: .monospaced))
                    }
                }
            }

            HStack {
                TextField("点击这里触发键盘", text: $text)
                    .textFieldStyle(.roundedBorder)
                Button("收起") {
                    keyboardManager.dismissKeyboard()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
        }
        .navigationTitle("键盘事件回调")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            keyboardManager.onKeyboardWillShow = { info in
                events.append("⬆️ WillShow: h=\(Int(info.height))pt")
            }
            keyboardManager.onKeyboardDidShow = { info in
                events.append("✅ DidShow: h=\(Int(info.height))pt")
            }
            keyboardManager.onKeyboardWillHide = { _ in
                events.append("⬇️ WillHide")
            }
            keyboardManager.onKeyboardDidHide = { _ in
                events.append("❌ DidHide")
            }
        }
    }

    private var stateText: String {
        switch keyboardManager.keyboardInfo.state {
        case .hidden: return "隐藏"
        case .showing: return "弹出中..."
        case .shown: return "已显示"
        case .hiding: return "收起中..."
        }
    }

    private var stateColor: Color {
        switch keyboardManager.keyboardInfo.state {
        case .hidden: return .secondary
        case .showing: return .orange
        case .shown: return .green
        case .hiding: return .orange
        }
    }
}

// MARK: - Form Scroll Demo

struct FormScrollDemoView: View {
    @State private var fields: [String] = Array(repeating: "", count: 10)

    var body: some View {
        KeyboardAvoidingScrollView {
            VStack(spacing: 16) {
                Text("包含多个输入框的表单")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)

                ForEach(0..<10) { index in
                    HStack {
                        Text("字段 \(index + 1)")
                            .frame(width: 60, alignment: .leading)
                            .font(.subheadline)
                        TextField("请输入...", text: $fields[index])
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("表单自动滚动")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Chat Input Demo

struct ChatInputDemoView: View {
    @StateObject private var keyboardManager = KeyboardManager()
    @State private var messages: [String] = [
        "你好！",
        "这是一个聊天界面演示",
        "键盘弹出时输入框会自动上移",
        "消息列表也会跟随调整",
    ]
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages.indices, id: \.self) { index in
                            HStack {
                                if index % 2 == 0 {
                                    Spacer()
                                    Text(messages[index])
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                } else {
                                    Text(messages[index])
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(16)
                                    Spacer()
                                }
                            }
                            .id(index)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack(spacing: 8) {
                TextField("输入消息...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                Button {
                    guard !inputText.isEmpty else { return }
                    messages.append(inputText)
                    inputText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))
        }
        .keyboardAdaptive()
        .navigationTitle("聊天输入框")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        KeyboardManagerDemoView()
    }
}
