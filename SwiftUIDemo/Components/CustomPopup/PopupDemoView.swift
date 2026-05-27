import SwiftUI

struct PopupDemoView: View {
    @StateObject private var popupManager = PopupManager()
    @State private var inputText = ""

    var body: some View {
        List {
            Section("弹窗类型") {
                Button("底部弹窗") { showBottomPopup() }
                Button("中间弹窗") { showCenterPopup() }
                Button("全屏弹窗") { showFullscreenPopup() }
            }

            Section("自定义动画") {
                Button("从底部滑入") { showSlideAnimation() }
                Button("淡入缩放") { showFadeScaleAnimation() }
                Button("弹性效果") { showSpringAnimation() }
            }

            Section("按钮组合") {
                Button("单按钮") { showSingleButton() }
                Button("双按钮") { showDoubleButton() }
                Button("自定义按钮区域") { showCustomButtons() }
            }

            Section("自定义内容") {
                Button("详情页弹窗") { showDetailContent() }
                Button("列表页弹窗") { showListContent() }
                Button("输入框弹窗（键盘适配）") { showInputPopup() }
            }

            Section("交互行为") {
                Button("点击蒙层不关闭") { showNonDismissible() }
                Button("拖拽关闭（底部弹窗）") { showDraggable() }
            }

            Section("高级功能") {
                Button("弹窗队列（连续3个）") { showQueue() }
            }
        }
        .navigationTitle("CustomPopup")
        .customPopup(manager: popupManager)
    }

    // MARK: - 弹窗类型

    private func showBottomPopup() {
        var config = PopupConfig()
        config.style = .bottom
        config.animation = .slideFromBottom
        config.title = "底部弹窗"
        config.message = "这是一个从底部弹出的弹窗，支持拖拽关闭。"
        config.icon = "arrow.up.doc"
        config.buttons = [
            PopupButton(title: "确定", style: .default) {}
        ]
        popupManager.show(config)
    }

    private func showCenterPopup() {
        var config = PopupConfig()
        config.style = .center
        config.animation = .fadeScale
        config.title = "居中弹窗"
        config.message = "这是一个显示在屏幕中央的弹窗，适合展示确认信息或提示内容。"
        config.icon = "info.circle.fill"
        config.buttons = [
            PopupButton(title: "取消", style: .cancel) {},
            PopupButton(title: "确认", style: .default) {}
        ]
        popupManager.show(config)
    }

    private func showFullscreenPopup() {
        var config = PopupConfig()
        config.style = .fullscreen
        config.animation = .fadeScale
        config.showCloseButton = true
        config.tapBackgroundToDismiss = false
        config.customContent = AnyView(
            VStack(spacing: 20) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                    .padding(.top, 40)

                Text("全屏弹窗")
                    .font(.largeTitle.bold())

                Text("这是一个全屏显示的弹窗，带有关闭按钮。适合展示协议、大段内容或引导页面。")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer()

                Text("点击右上角关闭按钮退出")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 40)
            }
        )
        popupManager.show(config)
    }

    // MARK: - 自定义动画

    private func showSlideAnimation() {
        var config = PopupConfig()
        config.style = .bottom
        config.animation = .slideFromBottom
        config.title = "滑入动画"
        config.message = "从屏幕底部平滑滑入"
        config.buttons = [PopupButton(title: "知道了", style: .default) {}]
        popupManager.show(config)
    }

    private func showFadeScaleAnimation() {
        var config = PopupConfig()
        config.style = .center
        config.animation = .fadeScale
        config.title = "淡入缩放"
        config.message = "从小到大淡入显示"
        config.icon = "sparkles"
        config.buttons = [PopupButton(title: "好的", style: .default) {}]
        popupManager.show(config)
    }

    private func showSpringAnimation() {
        var config = PopupConfig()
        config.style = .center
        config.animation = .spring
        config.title = "弹性效果"
        config.message = "带有弹性回弹的出现动画"
        config.icon = "wand.and.stars"
        config.buttons = [PopupButton(title: "好的", style: .default) {}]
        popupManager.show(config)
    }

    // MARK: - 按钮组合

    private func showSingleButton() {
        var config = PopupConfig()
        config.style = .center
        config.animation = .fadeScale
        config.title = "操作成功"
        config.message = "您的数据已保存成功。"
        config.icon = "checkmark.circle.fill"
        config.buttons = [
            PopupButton(title: "确定", style: .default) {}
        ]
        popupManager.show(config)
    }

    private func showDoubleButton() {
        var config = PopupConfig()
        config.style = .center
        config.animation = .fadeScale
        config.title = "确认删除"
        config.message = "删除后数据将无法恢复，确定要删除吗？"
        config.icon = "trash.fill"
        config.buttons = [
            PopupButton(title: "取消", style: .cancel) {},
            PopupButton(title: "删除", style: .destructive) {}
        ]
        popupManager.show(config)
    }

    private func showCustomButtons() {
        var config = PopupConfig()
        config.style = .center
        config.animation = .spring
        config.title = "选择操作"
        config.message = "请选择你要执行的操作"
        config.customButtons = AnyView(
            VStack(spacing: 8) {
                ForEach(["分享到朋友圈", "发送给好友", "收藏", "取消"], id: \.self) { title in
                    Button {
                        popupManager.dismiss()
                    } label: {
                        Text(title)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(title == "取消" ? Color(.secondarySystemFill) : Color.accentColor.opacity(0.1))
                            .foregroundStyle(title == "取消" ? .secondary : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        )
        popupManager.show(config)
    }

    // MARK: - 自定义内容

    private func showDetailContent() {
        var config = PopupConfig()
        config.style = .bottom
        config.animation = .slideFromBottom
        config.maxHeight = 450
        config.customContent = AnyView(
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("张三")
                            .font(.title2.bold())
                        Text("iOS 开发工程师")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 20)

                Divider()

                DetailRow(icon: "envelope.fill", title: "邮箱", value: "zhangsan@example.com")
                DetailRow(icon: "phone.fill", title: "电话", value: "138-0000-0000")
                DetailRow(icon: "building.2.fill", title: "部门", value: "移动开发部")
                DetailRow(icon: "calendar", title: "入职日期", value: "2023-06-01")

                Spacer()

                Button {
                    popupManager.dismiss()
                } label: {
                    Text("关闭")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        )
        popupManager.show(config)
    }

    private func showListContent() {
        var config = PopupConfig()
        config.style = .bottom
        config.animation = .slideFromBottom
        config.maxHeight = 500
        config.customContent = AnyView(
            VStack(spacing: 0) {
                Text("选择城市")
                    .font(.headline)
                    .padding(.vertical, 16)

                Divider()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(["北京", "上海", "广州", "深圳", "杭州", "成都", "武汉", "南京", "西安", "重庆"], id: \.self) { city in
                            Button {
                                popupManager.dismiss()
                            } label: {
                                HStack {
                                    Text(city)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                            }
                            Divider().padding(.leading, 20)
                        }
                    }
                }
            }
        )
        popupManager.show(config)
    }

    private func showInputPopup() {
        var config = PopupConfig()
        config.style = .center
        config.animation = .fadeScale
        config.tapBackgroundToDismiss = false
        config.customContent = AnyView(
            InputPopupContent(manager: popupManager)
        )
        popupManager.show(config)
    }

    // MARK: - 交互行为

    private func showNonDismissible() {
        var config = PopupConfig()
        config.style = .center
        config.animation = .spring
        config.tapBackgroundToDismiss = false
        config.title = "重要提示"
        config.message = "此弹窗点击蒙层不会关闭，必须点击按钮才能关闭。"
        config.icon = "exclamationmark.triangle.fill"
        config.buttons = [
            PopupButton(title: "我知道了", style: .default) {}
        ]
        popupManager.show(config)
    }

    private func showDraggable() {
        var config = PopupConfig()
        config.style = .bottom
        config.animation = .slideFromBottom
        config.dragToDismiss = true
        config.title = "拖拽关闭"
        config.message = "向下拖拽此弹窗可以将其关闭，也可以点击蒙层关闭。"
        config.icon = "hand.draw"
        config.buttons = [
            PopupButton(title: "关闭", style: .cancel) {}
        ]
        popupManager.show(config)
    }

    // MARK: - 高级功能

    private func showQueue() {
        for i in 1...3 {
            var config = PopupConfig()
            config.style = .center
            config.animation = .spring
            config.title = "弹窗 \(i)/3"
            config.message = "这是队列中的第 \(i) 个弹窗，关闭后会自动显示下一个。"
            config.icon = "\(i).circle.fill"
            config.buttons = [
                PopupButton(title: i < 3 ? "下一个" : "完成", style: .default) {}
            ]
            popupManager.show(config)
        }
    }
}

// MARK: - Helper Views

private struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.subheadline)
        }
    }
}

private struct InputPopupContent: View {
    @ObservedObject var manager: PopupManager
    @State private var text = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("请输入反馈")
                .font(.headline)
                .padding(.top, 20)

            TextField("输入内容...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .frame(minHeight: 80, alignment: .topLeading)
                .background(Color(.secondarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 20)

            HStack(spacing: 12) {
                Button {
                    manager.dismiss()
                } label: {
                    Text("取消")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(.secondarySystemFill))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    manager.dismiss()
                } label: {
                    Text("提交")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    NavigationStack {
        PopupDemoView()
    }
}
