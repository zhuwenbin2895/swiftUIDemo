import SwiftUI
import Combine

// MARK: - Menu State Manager

class DropDownMenuState: ObservableObject {
    @Published var isShowing = false
    @Published var items: [DropDownMenuItem] = []
    @Published var selectedIndex: Int? = nil
    @Published var config = DropDownMenuConfig()
    @Published var activeMenuIndex: Int? = nil
    @Published var menuStack: [[DropDownMenuItem]] = []

    var dataSource: (any DropDownMenuDataSource)? {
        didSet { reloadData() }
    }
    var delegate: (any DropDownMenuDelegate)?

    private var onSelect: ((Int, DropDownMenuItem) -> Void)?
    private var onWillShow: (() -> Void)?
    private var onDidShow: (() -> Void)?
    private var onWillHide: (() -> Void)?
    private var onDidHide: (() -> Void)?

    var canGoBack: Bool {
        !menuStack.isEmpty
    }

    func configure(
        items: [DropDownMenuItem],
        config: DropDownMenuConfig = DropDownMenuConfig(),
        onSelect: ((Int, DropDownMenuItem) -> Void)? = nil
    ) {
        self.items = items
        self.config = config
        self.onSelect = onSelect
        self.menuStack = []
    }

    func setDataSource(_ dataSource: any DropDownMenuDataSource) {
        self.dataSource = dataSource
    }

    func setDelegate(_ delegate: any DropDownMenuDelegate) {
        self.delegate = delegate
    }

    func reloadData() {
        guard let dataSource = dataSource else { return }
        let count = dataSource.numberOfRows(in: self)
        var newItems: [DropDownMenuItem] = []
        for i in 0..<count {
            newItems.append(dataSource.menuItem(in: self, at: i))
        }
        self.items = newItems
    }

    func onShowHide(
        willShow: (() -> Void)? = nil,
        didShow: (() -> Void)? = nil,
        willHide: (() -> Void)? = nil,
        didHide: (() -> Void)? = nil
    ) {
        self.onWillShow = willShow
        self.onDidShow = didShow
        self.onWillHide = willHide
        self.onDidHide = didHide
    }

    func show() {
        onWillShow?()
        delegate?.dropDownMenuWillShow(self)
        withAnimation(.easeInOut(duration: config.animationDuration)) {
            isShowing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) { [weak self] in
            guard let self else { return }
            self.onDidShow?()
            self.delegate?.dropDownMenuDidShow(self)
        }
    }

    func hide() {
        onWillHide?()
        delegate?.dropDownMenuWillHide(self)
        withAnimation(.easeInOut(duration: config.animationDuration)) {
            isShowing = false
            activeMenuIndex = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration) { [weak self] in
            guard let self else { return }
            self.onDidHide?()
            self.delegate?.dropDownMenuDidHide(self)
            self.menuStack = []
        }
    }

    func toggle() {
        if isShowing {
            hide()
        } else {
            show()
        }
    }

    func selectItem(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        for i in items.indices {
            items[i].isSelected = (i == index)
        }
        selectedIndex = index
        onSelect?(index, items[index])
        delegate?.dropDownMenu(self, didSelectItemAt: index)
        hide()
    }

    func pushSubMenu(for index: Int) {
        guard let children = items[index].children else { return }
        withAnimation(.easeInOut(duration: config.animationDuration)) {
            menuStack.append(items)
            items = children
        }
    }

    func popSubMenu() {
        guard let parentItems = menuStack.popLast() else { return }
        withAnimation(.easeInOut(duration: config.animationDuration)) {
            items = parentItems
        }
    }
}
