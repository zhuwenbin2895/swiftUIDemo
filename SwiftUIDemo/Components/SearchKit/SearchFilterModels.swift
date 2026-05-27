import SwiftUI
import Combine

// MARK: - 筛选状态

enum FilterType: String, CaseIterable {
    case single = "单选筛选"
    case multi = "多选筛选"
    case range = "范围滑块"
    case dateRange = "日期范围"
    case rating = "星级评分"
}

struct FilterOption: Identifiable, Hashable {
    let id: String
    let label: String
    let count: Int

    init(id: String, label: String, count: Int = 0) {
        self.id = id
        self.label = label
        self.count = count
    }
}

// MARK: - 筛选状态管理

@MainActor
class FilterStateManager: ObservableObject {
    @Published var singleSelections: [String: String] = [:]
    @Published var multiSelections: [String: Set<String>] = [:]
    @Published var rangeValues: [String: ClosedRange<Double>] = [:]
    @Published var dateRangeValues: [String: ClosedRange<Date>] = [:]
    @Published var ratingValues: [String: Int] = [:]

    @Published var activeFilterTags: [ActiveFilterTag] = []

    func setSingleSelection(filterID: String, optionID: String?) {
        singleSelections[filterID] = optionID
        updateActiveTags()
    }

    func toggleMultiSelection(filterID: String, optionID: String) {
        var current = multiSelections[filterID] ?? []
        if current.contains(optionID) {
            current.remove(optionID)
        } else {
            current.insert(optionID)
        }
        multiSelections[filterID] = current
        updateActiveTags()
    }

    func setRange(filterID: String, range: ClosedRange<Double>) {
        rangeValues[filterID] = range
        updateActiveTags()
    }

    func setDateRange(filterID: String, range: ClosedRange<Date>) {
        dateRangeValues[filterID] = range
        updateActiveTags()
    }

    func setRating(filterID: String, rating: Int) {
        ratingValues[filterID] = rating
        updateActiveTags()
    }

    func removeFilter(tag: ActiveFilterTag) {
        switch tag.type {
        case .single:
            singleSelections.removeValue(forKey: tag.filterID)
        case .multi:
            multiSelections[tag.filterID]?.remove(tag.valueID ?? "")
            if multiSelections[tag.filterID]?.isEmpty == true {
                multiSelections.removeValue(forKey: tag.filterID)
            }
        case .range:
            rangeValues.removeValue(forKey: tag.filterID)
        case .dateRange:
            dateRangeValues.removeValue(forKey: tag.filterID)
        case .rating:
            ratingValues.removeValue(forKey: tag.filterID)
        }
        updateActiveTags()
    }

    func clearAll() {
        singleSelections.removeAll()
        multiSelections.removeAll()
        rangeValues.removeAll()
        dateRangeValues.removeAll()
        ratingValues.removeAll()
        activeFilterTags.removeAll()
    }

    var hasActiveFilters: Bool {
        !singleSelections.isEmpty || !multiSelections.isEmpty ||
        !rangeValues.isEmpty || !dateRangeValues.isEmpty || !ratingValues.isEmpty
    }

    private func updateActiveTags() {
        var tags: [ActiveFilterTag] = []

        for (filterID, value) in singleSelections {
            tags.append(ActiveFilterTag(filterID: filterID, type: .single, label: value, valueID: value))
        }

        for (filterID, values) in multiSelections {
            for value in values {
                tags.append(ActiveFilterTag(filterID: filterID, type: .multi, label: value, valueID: value))
            }
        }

        for (filterID, range) in rangeValues {
            tags.append(ActiveFilterTag(filterID: filterID, type: .range, label: "\(Int(range.lowerBound))-\(Int(range.upperBound))"))
        }

        for (filterID, range) in dateRangeValues {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            tags.append(ActiveFilterTag(filterID: filterID, type: .dateRange, label: "\(formatter.string(from: range.lowerBound))-\(formatter.string(from: range.upperBound))"))
        }

        for (filterID, rating) in ratingValues {
            tags.append(ActiveFilterTag(filterID: filterID, type: .rating, label: "\(rating)星及以上"))
        }

        activeFilterTags = tags
    }
}

struct ActiveFilterTag: Identifiable {
    let id = UUID()
    let filterID: String
    let type: FilterType
    let label: String
    var valueID: String?
}
