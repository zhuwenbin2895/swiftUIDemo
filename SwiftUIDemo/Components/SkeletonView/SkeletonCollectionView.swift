import UIKit
import ObjectiveC

private var skeletonDataSourceKey: UInt8 = 0
private var skeletonDelegateKey: UInt8 = 0
private var originalDataSourceKey: UInt8 = 0
private var originalDelegateKey: UInt8 = 0
private var isShowingSkeletonKey: UInt8 = 0

// MARK: - Skeleton TableView DataSource Protocol
protocol SkeletonTableViewDataSource: UITableViewDataSource {
    func numSections(in tableView: UITableView) -> Int
    func collectionSkeletonView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func collectionSkeletonView(_ tableView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> String
    func collectionSkeletonView(_ tableView: UITableView, skeletonConfigForRowAt indexPath: IndexPath) -> SkeletonConfig
}

extension SkeletonTableViewDataSource {
    func numSections(in tableView: UITableView) -> Int { return 1 }
    func collectionSkeletonView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 6 }
    func collectionSkeletonView(_ tableView: UITableView, skeletonConfigForRowAt indexPath: IndexPath) -> SkeletonConfig { return .default }
}

// MARK: - Skeleton CollectionView DataSource Protocol
protocol SkeletonCollectionViewDataSource: UICollectionViewDataSource {
    func numSections(in collectionView: UICollectionView) -> Int
    func collectionSkeletonView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func collectionSkeletonView(_ collectionView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> String
    func collectionSkeletonView(_ collectionView: UICollectionView, skeletonConfigForItemAt indexPath: IndexPath) -> SkeletonConfig
}

extension SkeletonCollectionViewDataSource {
    func numSections(in collectionView: UICollectionView) -> Int { return 1 }
    func collectionSkeletonView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return 8 }
    func collectionSkeletonView(_ collectionView: UICollectionView, skeletonConfigForItemAt indexPath: IndexPath) -> SkeletonConfig { return .default }
}

// MARK: - UITableView Skeleton Extension
extension UITableView {

    var isShowingSkeleton: Bool {
        get { objc_getAssociatedObject(self, &isShowingSkeletonKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &isShowingSkeletonKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func showTableSkeleton(config: SkeletonConfig = .default, numberOfRows: Int = 6) {
        isShowingSkeleton = true
        isScrollEnabled = false
        isUserInteractionEnabled = false

        reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.showSkeletonForVisibleCells(config: config)
        }
    }

    func hideTableSkeleton() {
        isShowingSkeleton = false
        isScrollEnabled = true
        isUserInteractionEnabled = true

        hideSkeletonForVisibleCells()
        reloadData()
    }

    private func showSkeletonForVisibleCells(config: SkeletonConfig) {
        for cell in visibleCells {
            cell.contentView.isSkeletonable = true
            cell.contentView.showSkeleton(config: config)
            showSkeletonForCellSubviews(cell, config: config)
        }

        if let headerView = tableHeaderView {
            headerView.isSkeletonable = true
            headerView.showSkeleton(config: config)
        }

        if let footerView = tableFooterView {
            footerView.isSkeletonable = true
            footerView.showSkeleton(config: config)
        }
    }

    private func hideSkeletonForVisibleCells() {
        for cell in visibleCells {
            cell.contentView.hideSkeleton()
        }

        tableHeaderView?.hideSkeleton()
        tableFooterView?.hideSkeleton()
    }

    private func showSkeletonForCellSubviews(_ cell: UITableViewCell, config: SkeletonConfig) {
        for subview in cell.contentView.subviews {
            subview.isSkeletonable = true
        }
    }
}

// MARK: - UICollectionView Skeleton Extension
extension UICollectionView {

    var isShowingCollectionSkeleton: Bool {
        get { objc_getAssociatedObject(self, &isShowingSkeletonKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &isShowingSkeletonKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func showCollectionSkeleton(config: SkeletonConfig = .default) {
        isShowingCollectionSkeleton = true
        isScrollEnabled = false
        isUserInteractionEnabled = false

        reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.showSkeletonForVisibleItems(config: config)
        }
    }

    func hideCollectionSkeleton() {
        isShowingCollectionSkeleton = false
        isScrollEnabled = true
        isUserInteractionEnabled = true

        hideSkeletonForVisibleItems()
        reloadData()
    }

    private func showSkeletonForVisibleItems(config: SkeletonConfig) {
        for cell in visibleCells {
            cell.contentView.isSkeletonable = true
            cell.contentView.showSkeleton(config: config)
            for subview in cell.contentView.subviews {
                subview.isSkeletonable = true
            }
        }

        for indexPath in indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader) {
            if let header = supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                header.isSkeletonable = true
                header.showSkeleton(config: config)
            }
        }

        for indexPath in indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter) {
            if let footer = supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: indexPath) {
                footer.isSkeletonable = true
                footer.showSkeleton(config: config)
            }
        }
    }

    private func hideSkeletonForVisibleItems() {
        for cell in visibleCells {
            cell.contentView.hideSkeleton()
        }
    }
}

// MARK: - Skeleton Cell Protocol
protocol SkeletonCell {
    func configureForSkeleton()
    var skeletonableViews: [UIView] { get }
}

extension SkeletonCell where Self: UIView {
    func configureForSkeleton() {
        for view in skeletonableViews {
            view.isSkeletonable = true
        }
    }
}
