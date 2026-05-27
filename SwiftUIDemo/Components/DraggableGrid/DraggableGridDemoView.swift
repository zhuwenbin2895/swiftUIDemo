import SwiftUI
import Combine

struct DraggableGridDemoView: View {
    @StateObject private var manager = DraggableGridManager()
    @State private var preferredColorScheme: ColorScheme?

    var body: some View {
        DraggableGridView(manager: manager)
            .navigationTitle("DraggableGrid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("跟随系统") { preferredColorScheme = nil }
                        Button("浅色模式") { preferredColorScheme = .light }
                        Button("深色模式") { preferredColorScheme = .dark }
                    } label: {
                        Image(systemName: themeIcon)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(manager.isEditMode ? "完成" : "编辑") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if manager.isEditMode {
                                manager.exitEditMode()
                            } else {
                                manager.enterEditMode()
                            }
                        }
                    }
                }
            }
            .preferredColorScheme(preferredColorScheme)
            .onAppear {
                manager.loadItems()
            }
    }

    private var themeIcon: String {
        switch preferredColorScheme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        default: return "circle.lefthalf.filled"
        }
    }
}
