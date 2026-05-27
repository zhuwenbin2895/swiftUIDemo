import SwiftUI
import Combine

// MARK: - 搜索客户端

@MainActor
class SearchClient: ObservableObject {
    @Published var query: String = ""
    @Published var isSearching: Bool = false
    @Published var currentPage: Int = 0
    @Published var totalPages: Int = 0
    @Published var totalHits: Int = 0
    @Published var processingTimeMS: Int = 0

    private let debounceInterval: TimeInterval
    private var debounceTask: Task<Void, Never>?
    private var searchHandler: ((String, Int) async -> Void)?

    init(debounceInterval: TimeInterval = 0.3) {
        self.debounceInterval = debounceInterval
    }

    func onSearch(_ handler: @escaping (String, Int) async -> Void) {
        self.searchHandler = handler
    }

    func search(query: String, page: Int = 0) {
        self.query = query
        self.currentPage = page

        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            guard !Task.isCancelled else { return }

            isSearching = true
            await searchHandler?(query, page)
            isSearching = false
        }
    }

    func loadNextPage() {
        guard currentPage < totalPages - 1 else { return }
        let nextPage = currentPage + 1
        currentPage = nextPage

        Task {
            isSearching = true
            await searchHandler?(query, nextPage)
            isSearching = false
        }
    }
}

// MARK: - 搜索历史管理

@MainActor
class SearchHistoryManager: ObservableObject {
    @Published var history: [String] = []
    private let maxCount: Int
    private let storageKey: String

    init(storageKey: String = "search_history", maxCount: Int = 20) {
        self.storageKey = storageKey
        self.maxCount = maxCount
        loadHistory()
    }

    func addQuery(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        history.removeAll { $0 == query }
        history.insert(query, at: 0)
        if history.count > maxCount {
            history = Array(history.prefix(maxCount))
        }
        saveHistory()
    }

    func removeQuery(_ query: String) {
        history.removeAll { $0 == query }
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    private func loadHistory() {
        history = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
    }

    private func saveHistory() {
        UserDefaults.standard.set(history, forKey: storageKey)
    }
}

// MARK: - 搜索建议引擎

@MainActor
class SearchSuggestionEngine: ObservableObject {
    @Published var suggestions: [String] = []

    private var allTerms: [String] = []

    func configure(terms: [String]) {
        self.allTerms = terms
    }

    func updateSuggestions(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        let lowered = query.lowercased()
        suggestions = allTerms
            .filter { $0.lowercased().contains(lowered) && $0.lowercased() != lowered }
            .prefix(8)
            .map { $0 }
    }
}
