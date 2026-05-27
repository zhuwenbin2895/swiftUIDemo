import Foundation

// MARK: - 索引数据模型

protocol SearchableRecord: Identifiable, Codable {
    var objectID: String { get }
    func matchesQuery(_ query: String) -> Bool
}

struct SearchHit<T: SearchableRecord>: Identifiable {
    var id: String { record.objectID }
    let record: T
    let highlightedFields: [String: String]
    let score: Double
}

struct SearchIndex<T: SearchableRecord> {
    let name: String
    var records: [T]

    func search(query: SearchQuery) -> SearchResult<T> {
        var filtered = records

        if !query.query.isEmpty {
            filtered = filtered.filter { $0.matchesQuery(query.query) }
        }

        for filter in query.filters {
            filtered = filter.apply(to: filtered)
        }

        if let sortBy = query.sortBy {
            filtered = sortBy.apply(to: filtered)
        }

        let total = filtered.count
        let startIndex = query.page * query.hitsPerPage
        let endIndex = min(startIndex + query.hitsPerPage, total)

        let pageRecords: [T]
        if startIndex < total {
            pageRecords = Array(filtered[startIndex..<endIndex])
        } else {
            pageRecords = []
        }

        let hits = pageRecords.map { record in
            SearchHit(
                record: record,
                highlightedFields: highlightFields(record: record, query: query.query),
                score: calculateScore(record: record, query: query.query)
            )
        }

        return SearchResult(
            hits: hits,
            totalHits: total,
            page: query.page,
            totalPages: (total + query.hitsPerPage - 1) / max(query.hitsPerPage, 1),
            query: query.query,
            processingTimeMS: Int.random(in: 1...50)
        )
    }

    private func highlightFields(record: T, query: String) -> [String: String] {
        guard !query.isEmpty else { return [:] }
        return ["_query": query]
    }

    private func calculateScore(record: T, query: String) -> Double {
        guard !query.isEmpty else { return 1.0 }
        return Double.random(in: 0.5...1.0)
    }
}

// MARK: - 查询模型

struct SearchQuery {
    var query: String = ""
    var filters: [AnySearchFilter] = []
    var sortBy: AnySortDescriptor?
    var page: Int = 0
    var hitsPerPage: Int = 20
}

struct SearchResult<T: SearchableRecord> {
    let hits: [SearchHit<T>]
    let totalHits: Int
    let page: Int
    let totalPages: Int
    let query: String
    let processingTimeMS: Int

    var hasMore: Bool { page < totalPages - 1 }

    static var empty: SearchResult {
        SearchResult(hits: [], totalHits: 0, page: 0, totalPages: 0, query: "", processingTimeMS: 0)
    }
}

// MARK: - 筛选模型

protocol SearchFilter {
    func apply<T: SearchableRecord>(to records: [T]) -> [T]
}

struct AnySearchFilter: SearchFilter {
    private let _apply: ([Any]) -> [Any]
    let id: String
    let displayName: String

    init<F: SearchFilter>(id: String, displayName: String, filter: F) {
        self.id = id
        self.displayName = displayName
        self._apply = { records in
            guard let typed = records as? [any SearchableRecord] else { return records }
            _ = typed
            return records
        }
    }

    func apply<T: SearchableRecord>(to records: [T]) -> [T] {
        return records
    }
}

// MARK: - 排序模型

struct AnySortDescriptor {
    let id: String
    let displayName: String
    private let _compare: (Any, Any) -> Bool

    init<T: SearchableRecord>(id: String, displayName: String, comparator: @escaping (T, T) -> Bool) {
        self.id = id
        self.displayName = displayName
        self._compare = { a, b in
            guard let ta = a as? T, let tb = b as? T else { return false }
            return comparator(ta, tb)
        }
    }

    func apply<T: SearchableRecord>(to records: [T]) -> [T] {
        records.sorted { _compare($0, $1) }
    }
}

// MARK: - 演示数据模型

struct ProductRecord: SearchableRecord {
    var id: String { objectID }
    let objectID: String
    let name: String
    let brand: String
    let category: String
    let price: Double
    let rating: Int
    let description: String
    let date: Date
    let imageURL: String

    func matchesQuery(_ query: String) -> Bool {
        let lowered = query.lowercased()
        return name.lowercased().contains(lowered)
            || brand.lowercased().contains(lowered)
            || category.lowercased().contains(lowered)
            || description.lowercased().contains(lowered)
    }
}

struct ArticleRecord: SearchableRecord {
    var id: String { objectID }
    let objectID: String
    let title: String
    let author: String
    let content: String
    let category: String
    let date: Date

    func matchesQuery(_ query: String) -> Bool {
        let lowered = query.lowercased()
        return title.lowercased().contains(lowered)
            || author.lowercased().contains(lowered)
            || content.lowercased().contains(lowered)
    }
}

struct UserRecord: SearchableRecord {
    var id: String { objectID }
    let objectID: String
    let name: String
    let email: String
    let department: String

    func matchesQuery(_ query: String) -> Bool {
        let lowered = query.lowercased()
        return name.lowercased().contains(lowered)
            || email.lowercased().contains(lowered)
            || department.lowercased().contains(lowered)
    }
}
