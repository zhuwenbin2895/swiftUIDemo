import SwiftUI

struct ProgressHUDDemoView: View {
    @StateObject private var hud = ProgressHUDManager()
    @State private var progressValue: Double = 0
    @State private var progressTimer: Timer?

    var body: some View {
        List {
            Section("显示模式") {
                Button("菊花加载") {
                    hud.show(mode: .spinner, state: .loading, title: "加载中...")
                    hud.hide(afterDelay: 2)
                }
                Button("环形进度条") {
                    startProgress(mode: .annularProgress)
                }
                Button("细环进度条") {
                    startProgress(mode: .thinRingProgress)
                }
                Button("水平进度条") {
                    startProgress(mode: .horizontalProgress)
                }
                Button("自定义视图") {
                    let customView = AnyView(
                        VStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                                .symbolEffect(.pulse)
                        }
                    )
                    hud.show(mode: .customView(customView), title: "自定义内容", subtitle: "可放入任意视图")
                    hud.hide(afterDelay: 2)
                }
                Button("纯文字") {
                    hud.show(mode: .textOnly, title: "这是一条纯文字提示信息")
                    hud.hide(afterDelay: 2)
                }
            }

            Section("状态类型") {
                Button("加载中") {
                    hud.show(mode: .spinner, state: .loading, title: "请稍候", subtitle: "正在处理数据...")
                    hud.hide(afterDelay: 2)
                }
                Button("成功") {
                    hud.show(mode: .spinner, state: .success, title: "操作成功", subtitle: "数据已保存")
                    hud.hide(afterDelay: 1.5)
                }
                Button("失败") {
                    hud.show(mode: .spinner, state: .failure, title: "操作失败", subtitle: "请检查网络连接后重试")
                    hud.hide(afterDelay: 1.5)
                }
                Button("普通提示") {
                    hud.show(mode: .spinner, state: .info, title: "温馨提示", subtitle: "这是一条普通提示信息")
                    hud.hide(afterDelay: 1.5)
                }
            }

            Section("文字换行") {
                Button("长标题自动换行") {
                    hud.show(mode: .spinner, state: .loading, title: "这是一个非常非常长的标题用来测试文字自动换行的效果是否正常", subtitle: "副标题也可以很长很长来验证多行显示的排版效果是否美观整齐")
                    hud.hide(afterDelay: 3)
                }
            }

            Section("自定义样式") {
                Button("自定义背景色") {
                    var config = HUDConfig()
                    config.backgroundColor = Color.blue.opacity(0.9)
                    config.contentColor = .white
                    hud.show(mode: .spinner, state: .loading, title: "深色背景", config: config)
                    hud.hide(afterDelay: 2)
                }
                Button("大圆角 + 大字号") {
                    var config = HUDConfig()
                    config.cornerRadius = 28
                    config.titleFont = .system(size: 20, weight: .bold)
                    config.subtitleFont = .system(size: 16)
                    hud.show(mode: .spinner, state: .success, title: "大圆角", subtitle: "字号更大", config: config)
                    hud.hide(afterDelay: 2)
                }
                Button("深色遮罩") {
                    var config = HUDConfig()
                    config.maskColor = Color.black.opacity(0.6)
                    hud.show(mode: .spinner, state: .loading, title: "深色遮罩", config: config)
                    hud.hide(afterDelay: 2)
                }
                Button("透明遮罩") {
                    var config = HUDConfig()
                    config.maskColor = .clear
                    hud.show(mode: .spinner, state: .info, title: "无遮罩", config: config)
                    hud.hide(afterDelay: 2)
                }
            }

            Section("高级功能") {
                Button("延时隐藏 (3秒)") {
                    hud.show(mode: .spinner, state: .loading, title: "3秒后消失")
                    hud.hide(afterDelay: 3)
                }
                Button("最短显示时间 (防闪烁)") {
                    var config = HUDConfig()
                    config.minShowTime = 1.0
                    config.gracePeriod = 0
                    hud.show(mode: .spinner, state: .loading, title: "最短显示1秒", config: config)
                    hud.hide()
                }
                Button("快速任务跳过显示 (Grace Period)") {
                    var config = HUDConfig()
                    config.gracePeriod = 1.0
                    hud.show(mode: .spinner, state: .loading, title: "不会显示", config: config)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        hud.hide()
                    }
                }
                Button("模拟异步任务完成") {
                    hud.show(mode: .spinner, state: .loading, title: "处理中...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        hud.state = .success
                        hud.title = "完成!"
                        hud.subtitle = nil
                        hud.hide(afterDelay: 1)
                    }
                }
            }
        }
        .navigationTitle("ProgressHUD")
        .progressHUD(manager: hud)
    }

    private func startProgress(mode: HUDMode) {
        progressValue = 0
        hud.show(mode: mode, title: "下载中...", subtitle: "0%")
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak hud] timer in
            MainActor.assumeIsolated {
                guard let hud else {
                    timer.invalidate()
                    return
                }
                self.progressValue += Double.random(in: 0.01...0.04)
                if self.progressValue >= 1.0 {
                    self.progressValue = 1.0
                    timer.invalidate()
                    hud.updateProgress(1.0)
                    hud.title = "完成"
                    hud.subtitle = nil
                    hud.state = .success
                    hud.hide(afterDelay: 1)
                } else {
                    hud.updateProgress(self.progressValue)
                    hud.subtitle = "\(Int(self.progressValue * 100))%"
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProgressHUDDemoView()
    }
}
