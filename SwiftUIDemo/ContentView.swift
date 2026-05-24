import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("组件演示") {
                    NavigationLink {
                        ProgressHUDDemoView()
                    } label: {
                        Label("ProgressHUD", systemImage: "circles.hexagonpath")
                    }
                }
            }
            .navigationTitle("SwiftUI Demo")
        }
    }
}

#Preview {
    ContentView()
}
