import Foundation

struct SearchSampleData {
    static let products: [ProductRecord] = {
        let categories = ["手机", "电脑", "耳机", "平板", "手表", "相机", "音箱", "键盘"]
        let brands = ["Apple", "Samsung", "Sony", "Huawei", "Xiaomi", "Google", "Microsoft", "Bose"]

        return (0..<80).map { i in
            let category = categories[i % categories.count]
            let brand = brands[i % brands.count]
            let price = Double(Int.random(in: 99...9999))
            let rating = Int.random(in: 1...5)
            let date = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0...365), to: Date()) ?? Date()

            return ProductRecord(
                objectID: "product_\(i)",
                name: "\(brand) \(category) \(["Pro", "Air", "Max", "Ultra", "Lite", "Plus"][i % 6])",
                brand: brand,
                category: category,
                price: price,
                rating: rating,
                description: "这是一款高品质的\(brand)\(category)，具有出色的性能和设计。",
                date: date,
                imageURL: ""
            )
        }
    }()

    static let articles: [ArticleRecord] = {
        let titles = [
            "SwiftUI 最佳实践指南", "iOS 18 新特性详解", "Combine 框架深度解析",
            "Swift 并发编程入门", "UIKit 与 SwiftUI 混合开发", "Core Data 性能优化",
            "网络请求最佳实践", "动画效果实现技巧", "测试驱动开发实战",
            "App Store 审核指南", "内存管理与性能调优", "设计模式在 iOS 中的应用"
        ]
        let authors = ["张三", "李四", "王五", "赵六", "孙七", "周八"]
        let articleCategories = ["教程", "技术", "新闻", "评测", "经验"]

        return (0..<30).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0...180), to: Date()) ?? Date()
            return ArticleRecord(
                objectID: "article_\(i)",
                title: titles[i % titles.count],
                author: authors[i % authors.count],
                content: "这是一篇关于\(titles[i % titles.count])的详细文章，包含丰富的代码示例和实践经验分享。",
                category: articleCategories[i % articleCategories.count],
                date: date
            )
        }
    }()

    static let users: [UserRecord] = {
        let names = ["Alice Wang", "Bob Zhang", "Carol Li", "David Chen", "Eva Liu", "Frank Wu"]
        let departments = ["工程部", "产品部", "设计部", "市场部", "运营部"]

        return (0..<20).map { i in
            let name = names[i % names.count]
            return UserRecord(
                objectID: "user_\(i)",
                name: "\(name) \(i)",
                email: "\(name.lowercased().replacingOccurrences(of: " ", with: ".")).\(i)@example.com",
                department: departments[i % departments.count]
            )
        }
    }()

    static let suggestionTerms: [String] = [
        "Apple iPhone", "Apple MacBook", "Samsung Galaxy",
        "Sony 耳机", "Huawei 手表", "Xiaomi 手机",
        "蓝牙耳机", "机械键盘", "智能手表", "平板电脑",
        "无线充电", "降噪耳机", "游戏键盘", "运动手表",
        "SwiftUI", "iOS开发", "Swift编程", "性能优化"
    ]

    static let categoryOptions: [FilterOption] = [
        FilterOption(id: "手机", label: "手机", count: 10),
        FilterOption(id: "电脑", label: "电脑", count: 10),
        FilterOption(id: "耳机", label: "耳机", count: 10),
        FilterOption(id: "平板", label: "平板", count: 10),
        FilterOption(id: "手表", label: "手表", count: 10),
        FilterOption(id: "相机", label: "相机", count: 10),
        FilterOption(id: "音箱", label: "音箱", count: 10),
        FilterOption(id: "键盘", label: "键盘", count: 10),
    ]

    static let brandOptions: [FilterOption] = [
        FilterOption(id: "Apple", label: "Apple", count: 10),
        FilterOption(id: "Samsung", label: "Samsung", count: 10),
        FilterOption(id: "Sony", label: "Sony", count: 10),
        FilterOption(id: "Huawei", label: "Huawei", count: 10),
        FilterOption(id: "Xiaomi", label: "Xiaomi", count: 10),
        FilterOption(id: "Google", label: "Google", count: 10),
        FilterOption(id: "Microsoft", label: "Microsoft", count: 10),
        FilterOption(id: "Bose", label: "Bose", count: 10),
    ]

    static let cascadeCategories: [CascadeCategory] = [
        CascadeCategory(id: "category", name: "品类", options: categoryOptions),
        CascadeCategory(id: "brand", name: "品牌", options: brandOptions),
        CascadeCategory(id: "price_range", name: "价格", options: [
            FilterOption(id: "0-500", label: "500以下"),
            FilterOption(id: "500-1000", label: "500-1000"),
            FilterOption(id: "1000-3000", label: "1000-3000"),
            FilterOption(id: "3000-5000", label: "3000-5000"),
            FilterOption(id: "5000+", label: "5000以上"),
        ]),
    ]

    static let sortOptions: [SortOption] = [
        SortOption(id: "relevance", label: "相关性"),
        SortOption(id: "price_asc", label: "价格从低到高"),
        SortOption(id: "price_desc", label: "价格从高到低"),
        SortOption(id: "rating", label: "评分最高"),
        SortOption(id: "newest", label: "最新上架"),
    ]
}
