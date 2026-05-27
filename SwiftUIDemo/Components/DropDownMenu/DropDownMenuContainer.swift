import SwiftUI

// MARK: - Drop Down Menu Container

struct DropDownMenu: View {
    @ObservedObject var state: DropDownMenuState
    var attachment: DropDownMenuAttachment = .navigationBar

    var body: some View {
        ZStack(alignment: .top) {
            if state.isShowing {
                state.config.overlayColor
                    .ignoresSafeArea()
                    .onTapGesture {
                        state.hide()
                    }

                menuContent
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: state.config.animationDuration), value: state.isShowing)
    }

    @ViewBuilder
    private var menuContent: some View {
        let menuWidth = state.config.menuWidth ?? UIScreen.main.bounds.width
        let itemCount = state.items.count + (state.canGoBack ? 1 : 0)
        let maxHeight = CGFloat(min(itemCount, state.config.maxVisibleRows)) * state.config.rowHeight

        VStack(spacing: 0) {
            if state.canGoBack {
                backButton
                if state.config.showSeparator {
                    Divider().background(state.config.separatorColor)
                }
            }

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                        if item.customView != nil {
                            customViewRow(item: item)
                        } else {
                            standardRow(item: item, index: index)
                        }
                    }
                }
            }
            .frame(maxHeight: maxHeight)
        }
        .frame(width: menuWidth)
        .background(state.config.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: state.config.cornerRadius))
        .shadow(color: state.config.shadowColor, radius: state.config.shadowRadius, y: 4)
        .padding(.horizontal, menuWidth < UIScreen.main.bounds.width ? (UIScreen.main.bounds.width - menuWidth) / 2 : 0)
        .offset(y: attachmentOffset)
    }

    private var backButton: some View {
        Button {
            state.popSubMenu()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                Text("返回上一级")
                    .font(state.config.titleFont)
                Spacer()
            }
            .foregroundStyle(state.config.arrowActiveColor)
            .padding(.horizontal, 16)
            .frame(height: state.config.rowHeight)
        }
    }

    @ViewBuilder
    private func customViewRow(item: DropDownMenuItem) -> some View {
        if let customViewBuilder = item.customView {
            customViewBuilder()
        }
    }

    private func standardRow(item: DropDownMenuItem, index: Int) -> some View {
        DropDownMenuCell(
            item: item,
            config: state.config,
            showSeparator: index < state.items.count - 1
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if item.children != nil {
                state.pushSubMenu(for: index)
            } else {
                state.selectItem(at: index)
            }
        }
    }

    private var attachmentOffset: CGFloat {
        switch attachment {
        case .navigationBar:
            return 0
        case .toolbar:
            return 0
        case .custom(let offset):
            return offset
        }
    }
}

// MARK: - Menu Modifier

struct DropDownMenuModifier: ViewModifier {
    @ObservedObject var state: DropDownMenuState
    var attachment: DropDownMenuAttachment

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            DropDownMenu(state: state, attachment: attachment)
        }
    }
}

extension View {
    func dropDownMenu(state: DropDownMenuState, attachment: DropDownMenuAttachment = .navigationBar) -> some View {
        modifier(DropDownMenuModifier(state: state, attachment: attachment))
    }
}
