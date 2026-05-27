import SwiftUI

// MARK: - Menu Item Model

struct DropDownMenuItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var icon: String?
    var iconColor: Color?
    var isSelected: Bool = false
    var children: [DropDownMenuItem]?
    var customView: (() -> AnyView)?

    static func == (lhs: DropDownMenuItem, rhs: DropDownMenuItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Menu Configuration

struct DropDownMenuConfig {
    var menuWidth: CGFloat?
    var rowHeight: CGFloat = 44
    var maxVisibleRows: Int = 8
    var backgroundColor: Color = Color(uiColor: .systemBackground)
    var separatorColor: Color = Color(uiColor: .separator)
    var showSeparator: Bool = true
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 8
    var shadowColor: Color = .black.opacity(0.15)
    var overlayColor: Color = .black.opacity(0.3)
    var animationDuration: Double = 0.25

    var titleFont: Font = .system(size: 16)
    var titleColor: Color = .primary
    var selectedTitleColor: Color = .accentColor
    var iconSize: CGFloat = 20
    var checkmarkIcon: String = "checkmark"
    var checkmarkColor: Color = .accentColor

    var arrowIcon: String = "chevron.down"
    var arrowActiveIcon: String = "chevron.up"
    var arrowColor: Color = .secondary
    var arrowActiveColor: Color = .accentColor
    var arrowSize: CGFloat = 12

    var titleViewFont: Font = .system(size: 16, weight: .medium)
    var titleViewColor: Color = .primary
    var titleViewActiveColor: Color = .accentColor
    var titleViewSpacing: CGFloat = 4
    var titleViewPadding: EdgeInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
}

// MARK: - Data Source Protocol

protocol DropDownMenuDataSource {
    func numberOfRows(in menu: DropDownMenuState) -> Int
    func menuItem(in menu: DropDownMenuState, at index: Int) -> DropDownMenuItem
}

// MARK: - Delegate Protocol

protocol DropDownMenuDelegate {
    func dropDownMenu(_ menu: DropDownMenuState, didSelectItemAt index: Int)
    func dropDownMenuWillShow(_ menu: DropDownMenuState)
    func dropDownMenuDidShow(_ menu: DropDownMenuState)
    func dropDownMenuWillHide(_ menu: DropDownMenuState)
    func dropDownMenuDidHide(_ menu: DropDownMenuState)
}

extension DropDownMenuDelegate {
    func dropDownMenuWillShow(_ menu: DropDownMenuState) {}
    func dropDownMenuDidShow(_ menu: DropDownMenuState) {}
    func dropDownMenuWillHide(_ menu: DropDownMenuState) {}
    func dropDownMenuDidHide(_ menu: DropDownMenuState) {}
}

// MARK: - Attachment Position

enum DropDownMenuAttachment {
    case navigationBar
    case toolbar
    case custom(offset: CGFloat)
}
