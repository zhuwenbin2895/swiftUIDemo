import SwiftUI

// MARK: - Menu Cell View

struct DropDownMenuCell: View {
    let item: DropDownMenuItem
    let config: DropDownMenuConfig
    let showSeparator: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.system(size: config.iconSize))
                        .foregroundStyle(item.iconColor ?? config.titleColor)
                        .frame(width: config.iconSize + 4)
                }

                Text(item.title)
                    .font(config.titleFont)
                    .foregroundStyle(item.isSelected ? config.selectedTitleColor : config.titleColor)

                Spacer()

                if item.isSelected {
                    Image(systemName: config.checkmarkIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(config.checkmarkColor)
                }

                if item.children != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(config.arrowColor)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: config.rowHeight)

            if showSeparator && config.showSeparator {
                Divider()
                    .background(config.separatorColor)
                    .padding(.leading, item.icon != nil ? 52 : 16)
            }
        }
    }
}

// MARK: - Title View

struct DropDownMenuTitleView: View {
    let title: String
    let isActive: Bool
    let config: DropDownMenuConfig
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: config.titleViewSpacing) {
                Text(title)
                    .font(config.titleViewFont)
                    .foregroundStyle(isActive ? config.titleViewActiveColor : config.titleViewColor)

                Image(systemName: isActive ? config.arrowActiveIcon : config.arrowIcon)
                    .font(.system(size: config.arrowSize))
                    .foregroundStyle(isActive ? config.arrowActiveColor : config.arrowColor)
                    .rotationEffect(.degrees(isActive ? 0 : 0))
                    .animation(.easeInOut(duration: config.animationDuration), value: isActive)
            }
            .padding(config.titleViewPadding)
        }
    }
}

// MARK: - Multi-Title View (for multiple menu tabs)

struct DropDownMenuMultiTitleView: View {
    let titles: [String]
    @ObservedObject var menuState: DropDownMenuState
    let onTitleTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                DropDownMenuTitleView(
                    title: title,
                    isActive: menuState.activeMenuIndex == index && menuState.isShowing,
                    config: menuState.config,
                    action: { onTitleTap(index) }
                )
                if index < titles.count - 1 {
                    Divider()
                        .frame(height: 20)
                }
            }
        }
    }
}
