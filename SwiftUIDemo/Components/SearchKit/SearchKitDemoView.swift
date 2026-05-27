import SwiftUI

// MARK: - 搜索功能演示主视图

struct SearchKitDemoView: View {
    let demoItems: [(String, String, AnyView)] = [
        ("实时搜索与建议", "magnifyingglass", AnyView(SearchInputDemoView())),
        ("筛选组件", "line.3.horizontal.decrease", AnyView(FilterComponentsDemoView())),
        ("搜索结果展示", "list.bullet", AnyView(SearchResultsDemoView())),
        ("联邦搜索", "rectangle.3.group", AnyView(FederatedSearchDemoView())),
        ("排序与分页", "arrow.up.arrow.down.circle", AnyView(SortAndPaginationDemoView())),
        ("完整搜索体验", "sparkle.magnifyingglass", AnyView(FullSearchExperienceDemoView())),
    ]

    var body: some View {
        List {
            Section {
                Text("模仿 InstantSearch iOS 实现的搜索组件库，包含搜索输入、筛选、结果展示、联邦搜索等功能。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("功能演示") {
                ForEach(Array(demoItems.enumerated()), id: \.offset) { _, item in
                    NavigationLink {
                        item.2
                            .navigationTitle(item.0)
                    } label: {
                        Label(item.0, systemImage: item.1)
                    }
                }
            }
        }
        .navigationTitle("SearchKit")
    }
}

// MARK: - 1. 实时搜索与建议演示

struct SearchInputDemoView: View {
    @State private var searchText = ""
    @StateObject private var historyManager = SearchHistoryManager(storageKey: "searchkit_demo_history")
    @StateObject private var suggestionEngine = SearchSuggestionEngine()
    @State private var showSuggestions = false
    @State private var searchResults: [ProductRecord] = []

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                SearchInputView(
                    text: $searchText,
                    placeholder: "搜索商品...",
                    onSubmit: { query in
                        performSearch(query)
                    },
                    onClear: {
                        searchResults = []
                        showSuggestions = false
                    }
                )
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if showSuggestions && !suggestionEngine.suggestions.isEmpty {
                        SearchSuggestionsView(
                            suggestions: suggestionEngine.suggestions,
                            query: searchText,
                            onSelect: { suggestion in
                                searchText = suggestion
                                performSearch(suggestion)
                            }
                        )
                    }

                    if searchText.isEmpty && !historyManager.history.isEmpty {
                        SearchHistoryView(historyManager: historyManager) { query in
                            searchText = query
                            performSearch(query)
                        }
                    }

                    if !searchResults.isEmpty {
                        ForEach(searchResults) { product in
                            ProductRowView(product: product, query: searchText)
                        }
                    } else if !searchText.isEmpty && searchResults.isEmpty {
                        EmptySearchStateView()
                    }
                }
            }
        }
        .onAppear {
            suggestionEngine.configure(terms: SearchSampleData.suggestionTerms)
        }
        .onChange(of: searchText) { _, newValue in
            suggestionEngine.updateSuggestions(for: newValue)
            showSuggestions = !newValue.isEmpty
        }
    }

    private func performSearch(_ query: String) {
        showSuggestions = false
        historyManager.addQuery(query)
        let index = SearchIndex(name: "products", records: SearchSampleData.products)
        let searchQuery = SearchQuery(query: query, hitsPerPage: 20)
        let result = index.search(query: searchQuery)
        searchResults = result.hits.map { $0.record }
    }
}

// MARK: - 2. 筛选组件演示

struct FilterComponentsDemoView: View {
    @StateObject private var filterState = FilterStateManager()
    @State private var showCascade = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FilterTagsBar(filterState: filterState)

                VStack(alignment: .leading, spacing: 20) {
                    SingleSelectFilterView(
                        title: "品类（单选）",
                        filterID: "category",
                        options: Array(SearchSampleData.categoryOptions.prefix(5)),
                        filterState: filterState
                    )

                    Divider()

                    MultiSelectFilterView(
                        title: "品牌（多选）",
                        filterID: "brand",
                        options: Array(SearchSampleData.brandOptions.prefix(5)),
                        filterState: filterState
                    )

                    Divider()

                    RangeSliderFilterView(
                        title: "价格范围",
                        filterID: "price",
                        bounds: 0...10000,
                        step: 100,
                        unit: "¥",
                        filterState: filterState
                    )

                    Divider()

                    DateRangeFilterView(
                        title: "上架日期",
                        filterID: "date",
                        filterState: filterState
                    )

                    Divider()

                    RatingFilterView(
                        title: "最低评分",
                        filterID: "rating",
                        filterState: filterState
                    )

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            showCascade.toggle()
                        } label: {
                            HStack {
                                Text("级联筛选菜单")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: showCascade ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.secondary)
                            }
                        }

                        if showCascade {
                            CascadeFilterMenuView(
                                categories: SearchSampleData.cascadeCategories,
                                filterState: filterState
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - 3. 搜索结果展示演示

struct SearchResultsDemoView: View {
    @State private var searchText = ""
    @State private var results: [SearchHit<ProductRecord>] = []
    @State private var totalHits = 0
    @State private var isLoading = false
    @State private var hasMore = false
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            SearchInputView(
                text: $searchText,
                placeholder: "输入关键词查看结果展示...",
                onSubmit: { _ in performSearch() }
            )
            .padding()

            ScrollView {
                SearchResultsListView(
                    hits: results,
                    totalHits: totalHits,
                    isLoading: isLoading,
                    hasMore: hasMore,
                    onLoadMore: { loadMore() }
                ) { hit in
                    ProductRowView(product: hit.record, query: searchText)
                }
            }
        }
        .onAppear {
            searchText = "Apple"
            performSearch()
        }
        .onChange(of: searchText) { _, _ in
            currentPage = 0
            performSearch()
        }
    }

    private func performSearch() {
        let index = SearchIndex(name: "products", records: SearchSampleData.products)
        let query = SearchQuery(query: searchText, page: 0, hitsPerPage: 10)
        let result = index.search(query: query)
        results = result.hits
        totalHits = result.totalHits
        hasMore = result.hasMore
        currentPage = 0
    }

    private func loadMore() {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let index = SearchIndex(name: "products", records: SearchSampleData.products)
            let query = SearchQuery(query: searchText, page: currentPage, hitsPerPage: 10)
            let result = index.search(query: query)
            results.append(contentsOf: result.hits)
            hasMore = result.hasMore
            isLoading = false
        }
    }
}

// MARK: - 4. 联邦搜索演示

struct FederatedSearchDemoView: View {
    @State private var searchText = ""
    @State private var productResults: [ProductRecord] = []
    @State private var articleResults: [ArticleRecord] = []
    @State private var userResults: [UserRecord] = []
    @State private var isSearching = false

    var body: some View {
        VStack(spacing: 0) {
            SearchInputView(
                text: $searchText,
                placeholder: "同时搜索商品、文章、用户...",
                onSubmit: { _ in performFederatedSearch() }
            )
            .padding()

            ScrollView {
                if searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "rectangle.3.group")
                            .font(.largeTitle)
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("输入关键词同时搜索多个数据源")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 0) {
                        if !productResults.isEmpty {
                            FederatedResultSection(
                                title: "商品",
                                icon: "bag",
                                count: productResults.count
                            ) {
                                VStack(spacing: 0) {
                                    ForEach(productResults.prefix(3)) { product in
                                        ProductRowView(product: product, query: searchText)
                                        Divider()
                                    }
                                }
                            }
                        }

                        if !articleResults.isEmpty {
                            FederatedResultSection(
                                title: "文章",
                                icon: "doc.text",
                                count: articleResults.count
                            ) {
                                VStack(spacing: 0) {
                                    ForEach(articleResults.prefix(3)) { article in
                                        ArticleRowView(article: article, query: searchText)
                                        Divider()
                                    }
                                }
                            }
                        }

                        if !userResults.isEmpty {
                            FederatedResultSection(
                                title: "用户",
                                icon: "person.2",
                                count: userResults.count
                            ) {
                                VStack(spacing: 0) {
                                    ForEach(userResults.prefix(3)) { user in
                                        UserRowView(user: user, query: searchText)
                                        Divider()
                                    }
                                }
                            }
                        }

                        if productResults.isEmpty && articleResults.isEmpty && userResults.isEmpty {
                            EmptySearchStateView()
                        }
                    }
                }
            }
        }
        .onChange(of: searchText) { _, newValue in
            if !newValue.isEmpty {
                performFederatedSearch()
            } else {
                productResults = []
                articleResults = []
                userResults = []
            }
        }
    }

    private func performFederatedSearch() {
        let productIndex = SearchIndex(name: "products", records: SearchSampleData.products)
        let articleIndex = SearchIndex(name: "articles", records: SearchSampleData.articles)
        let userIndex = SearchIndex(name: "users", records: SearchSampleData.users)

        let query = SearchQuery(query: searchText, hitsPerPage: 10)
        productResults = productIndex.search(query: query).hits.map { $0.record }
        articleResults = articleIndex.search(query: query).hits.map { $0.record }
        userResults = userIndex.search(query: query).hits.map { $0.record }
    }
}

// MARK: - 5. 排序与分页演示

struct SortAndPaginationDemoView: View {
    @State private var selectedSort = "relevance"
    @State private var results: [ProductRecord] = []
    @State private var currentPage = 0
    @State private var totalPages = 0
    @State private var totalHits = 0
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SortSelectorView(
                    options: SearchSampleData.sortOptions,
                    selectedID: $selectedSort
                )
                Spacer()
                PaginationIndicator(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    totalHits: totalHits
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(results) { product in
                        ProductRowView(product: product, query: "")
                        Divider()
                    }

                    if currentPage < totalPages - 1 {
                        LoadMoreIndicator(isLoading: isLoading)
                            .onAppear { loadMore() }
                    }
                }
            }
        }
        .onAppear { loadData() }
        .onChange(of: selectedSort) { _, _ in
            currentPage = 0
            loadData()
        }
    }

    private func loadData() {
        var sorted = SearchSampleData.products
        switch selectedSort {
        case "price_asc":
            sorted.sort { $0.price < $1.price }
        case "price_desc":
            sorted.sort { $0.price > $1.price }
        case "rating":
            sorted.sort { $0.rating > $1.rating }
        case "newest":
            sorted.sort { $0.date > $1.date }
        default:
            break
        }

        let hitsPerPage = 15
        totalHits = sorted.count
        totalPages = (totalHits + hitsPerPage - 1) / hitsPerPage
        let start = currentPage * hitsPerPage
        let end = min(start + hitsPerPage, totalHits)
        results = Array(sorted[start..<end])
    }

    private func loadMore() {
        guard !isLoading, currentPage < totalPages - 1 else { return }
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            currentPage += 1
            var sorted = SearchSampleData.products
            switch selectedSort {
            case "price_asc": sorted.sort { $0.price < $1.price }
            case "price_desc": sorted.sort { $0.price > $1.price }
            case "rating": sorted.sort { $0.rating > $1.rating }
            case "newest": sorted.sort { $0.date > $1.date }
            default: break
            }
            let hitsPerPage = 15
            let start = currentPage * hitsPerPage
            let end = min(start + hitsPerPage, sorted.count)
            results.append(contentsOf: sorted[start..<end])
            isLoading = false
        }
    }
}

// MARK: - 6. 完整搜索体验演示

struct FullSearchExperienceDemoView: View {
    @State private var searchText = ""
    @StateObject private var historyManager = SearchHistoryManager(storageKey: "searchkit_full_history")
    @StateObject private var suggestionEngine = SearchSuggestionEngine()
    @StateObject private var filterState = FilterStateManager()
    @State private var selectedSort = "relevance"
    @State private var results: [SearchHit<ProductRecord>] = []
    @State private var totalHits = 0
    @State private var currentPage = 0
    @State private var totalPages = 0
    @State private var isLoading = false
    @State private var showFilters = false

    var body: some View {
        VStack(spacing: 0) {
            SearchInputView(
                text: $searchText,
                placeholder: "搜索商品...",
                onSubmit: { query in
                    historyManager.addQuery(query)
                    performSearch()
                },
                onClear: {
                    results = []
                    totalHits = 0
                }
            )
            .padding(.horizontal)
            .padding(.top, 8)

            HStack {
                FilterTagsBar(filterState: filterState) {
                    showFilters.toggle()
                }
                SortSelectorView(
                    options: SearchSampleData.sortOptions,
                    selectedID: $selectedSort
                )
                .padding(.trailing)
            }
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                if !suggestionEngine.suggestions.isEmpty && results.isEmpty {
                    SearchSuggestionsView(
                        suggestions: suggestionEngine.suggestions,
                        query: searchText,
                        onSelect: { suggestion in
                            searchText = suggestion
                            historyManager.addQuery(suggestion)
                            performSearch()
                        }
                    )
                }

                if searchText.isEmpty && results.isEmpty {
                    SearchHistoryView(historyManager: historyManager) { query in
                        searchText = query
                        performSearch()
                    }
                    .padding(.top, 12)
                }

                SearchResultsListView(
                    hits: results,
                    totalHits: totalHits,
                    isLoading: isLoading,
                    hasMore: currentPage < totalPages - 1,
                    onLoadMore: { loadMore() }
                ) { hit in
                    ProductRowView(product: hit.record, query: searchText)
                }

                PaginationIndicator(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    totalHits: totalHits
                )
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheetView(filterState: filterState) {
                performSearch()
            }
        }
        .onAppear {
            suggestionEngine.configure(terms: SearchSampleData.suggestionTerms)
        }
        .onChange(of: searchText) { _, newValue in
            suggestionEngine.updateSuggestions(for: newValue)
            if !newValue.isEmpty {
                performSearch()
            }
        }
        .onChange(of: selectedSort) { _, _ in
            performSearch()
        }
        .onChange(of: filterState.activeFilterTags.count) { _, _ in
            performSearch()
        }
    }

    private func performSearch() {
        currentPage = 0
        var allProducts = SearchSampleData.products

        if !searchText.isEmpty {
            allProducts = allProducts.filter { $0.matchesQuery(searchText) }
        }

        if let category = filterState.singleSelections["category"] {
            allProducts = allProducts.filter { $0.category == category }
        }
        if let brands = filterState.multiSelections["brand"], !brands.isEmpty {
            allProducts = allProducts.filter { brands.contains($0.brand) }
        }
        if let range = filterState.rangeValues["price"] {
            allProducts = allProducts.filter { $0.price >= range.lowerBound && $0.price <= range.upperBound }
        }
        if let rating = filterState.ratingValues["rating"], rating > 0 {
            allProducts = allProducts.filter { $0.rating >= rating }
        }

        switch selectedSort {
        case "price_asc": allProducts.sort { $0.price < $1.price }
        case "price_desc": allProducts.sort { $0.price > $1.price }
        case "rating": allProducts.sort { $0.rating > $1.rating }
        case "newest": allProducts.sort { $0.date > $1.date }
        default: break
        }

        let hitsPerPage = 10
        totalHits = allProducts.count
        totalPages = (totalHits + hitsPerPage - 1) / max(hitsPerPage, 1)
        let end = min(hitsPerPage, allProducts.count)
        results = allProducts.prefix(end).map { product in
            SearchHit(record: product, highlightedFields: ["_query": searchText], score: 1.0)
        }
    }

    private func loadMore() {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var allProducts = SearchSampleData.products
            if !searchText.isEmpty {
                allProducts = allProducts.filter { $0.matchesQuery(searchText) }
            }

            switch selectedSort {
            case "price_asc": allProducts.sort { $0.price < $1.price }
            case "price_desc": allProducts.sort { $0.price > $1.price }
            case "rating": allProducts.sort { $0.rating > $1.rating }
            case "newest": allProducts.sort { $0.date > $1.date }
            default: break
            }

            let hitsPerPage = 10
            let start = currentPage * hitsPerPage
            let end = min(start + hitsPerPage, allProducts.count)
            if start < allProducts.count {
                let newHits = allProducts[start..<end].map { product in
                    SearchHit(record: product, highlightedFields: ["_query": searchText], score: 1.0)
                }
                results.append(contentsOf: newHits)
            }
            isLoading = false
        }
    }
}

// MARK: - 筛选 Sheet

struct FilterSheetView: View {
    @ObservedObject var filterState: FilterStateManager
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SingleSelectFilterView(
                        title: "品类",
                        filterID: "category",
                        options: SearchSampleData.categoryOptions,
                        filterState: filterState
                    )

                    Divider()

                    MultiSelectFilterView(
                        title: "品牌",
                        filterID: "brand",
                        options: SearchSampleData.brandOptions,
                        filterState: filterState
                    )

                    Divider()

                    RangeSliderFilterView(
                        title: "价格范围",
                        filterID: "price",
                        bounds: 0...10000,
                        step: 100,
                        unit: "¥",
                        filterState: filterState
                    )

                    Divider()

                    RatingFilterView(
                        title: "最低评分",
                        filterID: "rating",
                        filterState: filterState
                    )
                }
                .padding()
            }
            .navigationTitle("筛选条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("重置") {
                        filterState.clearAll()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("应用") {
                        onApply()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

// MARK: - 行视图

struct ProductRowView: View {
    let product: ProductRecord
    let query: String

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "bag")
                        .foregroundColor(.blue)
                }

            VStack(alignment: .leading, spacing: 4) {
                HighlightedText(text: product.name, highlight: query)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                HStack {
                    Text(product.brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("·")
                        .foregroundColor(.secondary)
                    Text(product.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("¥\(Int(product.price))")
                        .font(.callout.bold())
                        .foregroundColor(.red)
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<product.rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ArticleRowView: View {
    let article: ArticleRecord
    let query: String

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "doc.text")
                        .foregroundColor(.green)
                }

            VStack(alignment: .leading, spacing: 4) {
                HighlightedText(text: article.title, highlight: query)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                HStack {
                    Text(article.author)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(article.category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct UserRowView: View {
    let user: UserRecord
    let query: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "person")
                        .foregroundColor(.purple)
                }

            VStack(alignment: .leading, spacing: 4) {
                HighlightedText(text: user.name, highlight: query)
                    .font(.subheadline.bold())

                HStack {
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(user.department)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
