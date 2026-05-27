import SwiftUI

// MARK: - 筛选标签栏

struct FilterTagsBar: View {
    @ObservedObject var filterState: FilterStateManager
    var onFilterTap: (() -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    onFilterTap?()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text("筛选")
                    }
                    .font(.callout)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(filterState.hasActiveFilters ? Color.blue.opacity(0.1) : Color(uiColor: .systemGray5))
                    .foregroundColor(filterState.hasActiveFilters ? .blue : .primary)
                    .cornerRadius(16)
                }

                ForEach(filterState.activeFilterTags) { tag in
                    HStack(spacing: 4) {
                        Text(tag.label)
                            .font(.callout)
                        Button {
                            filterState.removeFilter(tag: tag)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption2)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(16)
                }

                if filterState.hasActiveFilters {
                    Button("清除全部") {
                        filterState.clearAll()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 单选筛选

struct SingleSelectFilterView: View {
    let title: String
    let filterID: String
    let options: [FilterOption]
    @ObservedObject var filterState: FilterStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())

            ForEach(options) { option in
                Button {
                    let current = filterState.singleSelections[filterID]
                    filterState.setSingleSelection(
                        filterID: filterID,
                        optionID: current == option.id ? nil : option.id
                    )
                } label: {
                    HStack {
                        Text(option.label)
                            .foregroundColor(.primary)
                        Spacer()
                        if option.count > 0 {
                            Text("\(option.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if filterState.singleSelections[filterID] == option.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }
}

// MARK: - 多选筛选

struct MultiSelectFilterView: View {
    let title: String
    let filterID: String
    let options: [FilterOption]
    @ObservedObject var filterState: FilterStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())

            ForEach(options) { option in
                Button {
                    filterState.toggleMultiSelection(filterID: filterID, optionID: option.id)
                } label: {
                    HStack {
                        Image(systemName: (filterState.multiSelections[filterID]?.contains(option.id) == true)
                              ? "checkmark.square.fill" : "square")
                            .foregroundColor((filterState.multiSelections[filterID]?.contains(option.id) == true)
                                            ? .blue : .secondary)
                        Text(option.label)
                            .foregroundColor(.primary)
                        Spacer()
                        if option.count > 0 {
                            Text("\(option.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - 范围滑块筛选

struct RangeSliderFilterView: View {
    let title: String
    let filterID: String
    let bounds: ClosedRange<Double>
    let step: Double
    let unit: String
    @ObservedObject var filterState: FilterStateManager
    @State private var low: Double = 0
    @State private var high: Double = 100
    @State private var isInitialized = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(Int(low))\(unit) - \(Int(high))\(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 16) {
                HStack {
                    Text("最低")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 30)
                    Slider(value: $low, in: bounds, step: step)
                        .tint(.blue.opacity(0.5))
                    Text("\(Int(low))\(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }
                HStack {
                    Text("最高")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 30)
                    Slider(value: $high, in: bounds, step: step)
                        .tint(.blue)
                    Text("\(Int(high))\(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .onAppear {
            low = filterState.rangeValues[filterID]?.lowerBound ?? bounds.lowerBound
            high = filterState.rangeValues[filterID]?.upperBound ?? bounds.upperBound
            isInitialized = true
        }
        .onChange(of: low) { _, newValue in
            guard isInitialized else { return }
            var newLow = newValue
            if newLow > high { newLow = high }
            if newLow != newValue { low = newLow }
            filterState.setRange(filterID: filterID, range: newLow...high)
        }
        .onChange(of: high) { _, newValue in
            guard isInitialized else { return }
            var newHigh = newValue
            if newHigh < low { newHigh = low }
            if newHigh != newValue { high = newHigh }
            filterState.setRange(filterID: filterID, range: low...newHigh)
        }
    }
}

// MARK: - 日期范围筛选

struct DateRangeFilterView: View {
    let title: String
    let filterID: String
    @ObservedObject var filterState: FilterStateManager
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.bold())

            HStack {
                VStack(alignment: .leading) {
                    Text("开始日期")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .labelsHidden()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("结束日期")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $endDate, displayedComponents: .date)
                        .labelsHidden()
                }
            }
        }
        .onAppear {
            if let range = filterState.dateRangeValues[filterID] {
                startDate = range.lowerBound
                endDate = range.upperBound
            }
        }
        .onChange(of: startDate) { _, _ in
            filterState.setDateRange(filterID: filterID, range: startDate...endDate)
        }
        .onChange(of: endDate) { _, _ in
            filterState.setDateRange(filterID: filterID, range: startDate...endDate)
        }
    }
}

// MARK: - 星级评分筛选

struct RatingFilterView: View {
    let title: String
    let filterID: String
    @ObservedObject var filterState: FilterStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())

            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        let current = filterState.ratingValues[filterID]
                        filterState.setRating(filterID: filterID, rating: current == rating ? 0 : rating)
                    } label: {
                        HStack(spacing: 2) {
                            ForEach(1...rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(filterState.ratingValues[filterID] == rating ? Color.orange.opacity(0.2) : Color(uiColor: .systemGray5))
                        .foregroundColor(filterState.ratingValues[filterID] == rating ? .orange : .secondary)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// MARK: - 级联筛选菜单

struct CascadeFilterMenuView: View {
    let categories: [CascadeCategory]
    @ObservedObject var filterState: FilterStateManager
    @State private var selectedCategoryIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                        Button {
                            selectedCategoryIndex = index
                        } label: {
                            Text(category.name)
                                .font(.callout)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedCategoryIndex == index ? Color(uiColor: .systemBackground) : Color(uiColor: .systemGray6))
                                .foregroundColor(selectedCategoryIndex == index ? .blue : .primary)
                        }
                    }
                    Spacer()
                }
                .frame(width: 100)
                .background(Color(uiColor: .systemGray6))

                if selectedCategoryIndex < categories.count {
                    let category = categories[selectedCategoryIndex]
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(category.options) { option in
                                Button {
                                    filterState.toggleMultiSelection(filterID: category.id, optionID: option.id)
                                } label: {
                                    HStack {
                                        Text(option.label)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if filterState.multiSelections[category.id]?.contains(option.id) == true {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 250)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(uiColor: .systemGray4), lineWidth: 0.5)
        )
    }
}

struct CascadeCategory: Identifiable {
    let id: String
    let name: String
    let options: [FilterOption]
}
