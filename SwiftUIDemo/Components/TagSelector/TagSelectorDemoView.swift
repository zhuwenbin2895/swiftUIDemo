import SwiftUI

struct TagSelectorDemoView: View {
    @StateObject private var singleManager = TagSelectorManager(
        tags: TagItem.sampleTags,
        config: TagSelectorConfig(selectionMode: .single)
    )
    @StateObject private var multiManager = TagSelectorManager(
        tags: TagItem.sampleTags,
        config: TagSelectorConfig(selectionMode: .multiple(maxCount: 5))
    )
    @State private var preferredColorScheme: ColorScheme?
    @State private var singleSelection: [TagItem] = []
    @State private var multiSelection: [TagItem] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                singleSelectionSection
                multiSelectionSection
            }
            .padding()
        }
        .navigationTitle("TagSelector")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("跟随系统") { preferredColorScheme = nil }
                    Button("浅色模式") { preferredColorScheme = .light }
                    Button("深色模式") { preferredColorScheme = .dark }
                } label: {
                    Image(systemName: themeIcon)
                }
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .onAppear {
            singleManager.onSelectionChanged = { singleSelection = $0 }
            multiManager.onSelectionChanged = { multiSelection = $0 }
        }
    }

    private var singleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("单选模式")
                    .font(.headline)
                Spacer()
                if !singleSelection.isEmpty {
                    Text("当前: \(singleSelection.first?.title ?? "")")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }

            TagSelectorView(manager: singleManager)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var multiSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("多选模式（最多5个）")
                    .font(.headline)
                Spacer()
                Text("\(multiSelection.count)/5")
                    .font(.subheadline)
                    .foregroundStyle(multiSelection.count >= 5 ? .red : .blue)
            }

            TagSelectorView(manager: multiManager)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
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

#Preview {
    NavigationStack {
        TagSelectorDemoView()
    }
}
