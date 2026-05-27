import SwiftUI
import UIKit

struct RuntimeToolsDemoView: View {
    var body: some View {
        List {
            Section("方法交换") {
                NavigationLink("安全方法交换演示") { SwizzleDemoView() }
                NavigationLink("交换记录查看") { SwizzleRecordView() }
            }
            Section("动态属性") {
                NavigationLink("动态属性绑定") { DynamicPropertyDemoView() }
                NavigationLink("属性记录查看") { PropertyRecordView() }
            }
        }
        .navigationTitle("RuntimeTools")
    }
}

// MARK: - Swizzle Demo

struct SwizzleDemoView: View {
    @State private var resultText = ""
    @State private var isSwizzled = false
    @State private var logs: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("方法交换说明") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Method Swizzling 是 ObjC Runtime 的核心能力")
                            .font(.subheadline)
                        Text("• 在运行时交换两个方法的实现\n• 常用于 AOP、无侵入埋点、Bug 修复\n• 需要注意线程安全和调用顺序")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                GroupBox("操作") {
                    VStack(spacing: 12) {
                        Button("调用 originalMethod()") {
                            let obj = RuntimeDemoObject()
                            let result = obj.originalMethod()
                            resultText = result
                            logs.append("[\(timeString())] 调用结果: \(result)")
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button(isSwizzled ? "已交换 ✓" : "执行方法交换") {
                            let success = MethodSwizzler.shared.swizzle(
                                class: RuntimeDemoObject.self,
                                original: #selector(RuntimeDemoObject.originalMethod),
                                swizzled: #selector(RuntimeDemoObject.swizzledMethod)
                            )
                            isSwizzled = true
                            logs.append("[\(timeString())] 方法交换\(success ? "成功" : "失败")")
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .disabled(isSwizzled)

                        if !resultText.isEmpty {
                            HStack {
                                Image(systemName: "arrow.right.circle")
                                    .foregroundColor(.blue)
                                Text(resultText)
                                    .font(.system(.subheadline, design: .monospaced))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                    }
                }

                if !logs.isEmpty {
                    GroupBox("操作日志") {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(logs.indices, id: \.self) { index in
                                Text(logs[index])
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("方法交换")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func timeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

// MARK: - Swizzle Record View

struct SwizzleRecordView: View {
    @State private var records: [MethodSwizzler.SwizzleRecord] = []

    var body: some View {
        List {
            if records.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.title)
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("暂无交换记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("先到\"方法交换演示\"执行交换操作")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }

            ForEach(records) { record in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "arrow.2.squarepath")
                            .foregroundColor(.purple)
                        Text(record.className)
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.medium)
                    }
                    Group {
                        HStack(spacing: 4) {
                            Text("原方法:")
                                .foregroundColor(.secondary)
                            Text(record.originalSelector)
                                .foregroundColor(.blue)
                        }
                        HStack(spacing: 4) {
                            Text("新方法:")
                                .foregroundColor(.secondary)
                            Text(record.swizzledSelector)
                                .foregroundColor(.green)
                        }
                    }
                    .font(.system(size: 11, design: .monospaced))

                    HStack {
                        Circle()
                            .fill(record.isActive ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        Text(record.isActive ? "活跃" : "已还原")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("交换记录")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            records = MethodSwizzler.shared.records
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("刷新") {
                    records = MethodSwizzler.shared.records
                }
            }
        }
    }
}

// MARK: - Dynamic Property Demo

struct DynamicPropertyDemoView: View {
    @State private var propertyName = ""
    @State private var propertyValue = ""
    @State private var results: [(String, String)] = []
    @State private var logs: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox("动态属性说明") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("通过 Associated Object 为任意对象动态添加属性")
                            .font(.subheadline)
                        Text("• 无需修改原始类定义\n• 支持多种内存管理策略\n• 属性生命周期跟随宿主对象")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                GroupBox("绑定属性") {
                    VStack(spacing: 12) {
                        Button("绑定 customName = \"TestView\"") {
                            let view = UIView()
                            view.runtimeCustomName = "TestView"
                            let readback = view.runtimeCustomName ?? "nil"
                            results.append(("customName", readback))
                            logs.append("设置 customName = \"TestView\", 读取 = \"\(readback)\"")
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button("绑定 customTag = 42") {
                            let view = UIView()
                            view.runtimeCustomTag = 42
                            let readback = view.runtimeCustomTag ?? 0
                            results.append(("customTag", "\(readback)"))
                            logs.append("设置 customTag = 42, 读取 = \(readback)")
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button("绑定 customData 字典") {
                            let view = UIView()
                            view.runtimeCustomData = ["key": "value", "count": 99]
                            let readback = view.runtimeCustomData ?? [:]
                            results.append(("customData", "\(readback)"))
                            logs.append("设置 customData, 读取 = \(readback)")
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }

                if !results.isEmpty {
                    GroupBox("绑定结果") {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(results.indices, id: \.self) { index in
                                HStack {
                                    Text(results[index].0)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.blue)
                                    Text("=")
                                        .foregroundColor(.secondary)
                                    Text(results[index].1)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }

                if !logs.isEmpty {
                    GroupBox("操作日志") {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(logs.indices, id: \.self) { index in
                                Text(logs[index])
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("动态属性绑定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Property Record View

struct PropertyRecordView: View {
    @State private var records: [DynamicProperty.PropertyRecord] = []

    var body: some View {
        List {
            if records.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "link.badge.plus")
                        .font(.title)
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("暂无属性记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("先到\"动态属性绑定\"执行操作")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }

            ForEach(records) { record in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.orange)
                        Text(record.objectType)
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.medium)
                    }
                    Group {
                        HStack(spacing: 4) {
                            Text("类型:")
                                .foregroundColor(.secondary)
                            Text(record.valueType)
                                .foregroundColor(.blue)
                        }
                        HStack(spacing: 4) {
                            Text("策略:")
                                .foregroundColor(.secondary)
                            Text(record.policy)
                                .foregroundColor(.green)
                        }
                    }
                    .font(.system(size: 11, design: .monospaced))
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("属性记录")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            records = DynamicProperty.shared.records
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("刷新") {
                    records = DynamicProperty.shared.records
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RuntimeToolsDemoView()
    }
}
