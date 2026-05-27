import Foundation
import UIKit

// MARK: - Layout Result

struct AsyncLayoutResult: Equatable {
    let frames: [String: CGRect]
    let contentSize: CGSize
    let textLayouts: [String: AsyncTextLayout]
    let timestamp: TimeInterval

    static func == (lhs: AsyncLayoutResult, rhs: AsyncLayoutResult) -> Bool {
        lhs.frames == rhs.frames && lhs.contentSize == rhs.contentSize
    }
}

struct AsyncTextLayout: Equatable {
    let attributedString: NSAttributedString
    let boundingRect: CGRect
    let lineCount: Int
}

// MARK: - Render Context

final class AsyncRenderContext: Equatable {
    let width: CGFloat
    let maxHeight: CGFloat
    let contentInsets: UIEdgeInsets
    let fontSize: CGFloat
    let imageSize: CGSize
    let spacing: CGFloat
    private(set) var version: Int = 0

    init(width: CGFloat = UIScreen.main.bounds.width,
         maxHeight: CGFloat = .greatestFiniteMagnitude,
         contentInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16),
         fontSize: CGFloat = 15,
         imageSize: CGSize = CGSize(width: 80, height: 80),
         spacing: CGFloat = 8) {
        self.width = width
        self.maxHeight = maxHeight
        self.contentInsets = contentInsets
        self.fontSize = fontSize
        self.imageSize = imageSize
        self.spacing = spacing
    }

    func invalidate() {
        version += 1
    }

    static func == (lhs: AsyncRenderContext, rhs: AsyncRenderContext) -> Bool {
        lhs.width == rhs.width &&
        lhs.maxHeight == rhs.maxHeight &&
        lhs.fontSize == rhs.fontSize &&
        lhs.imageSize == rhs.imageSize &&
        lhs.spacing == rhs.spacing &&
        lhs.version == rhs.version
    }
}

// MARK: - Layout Cache

final class AsyncLayoutCache {
    static let shared = AsyncLayoutCache()

    private var cache: [String: CacheEntry] = [:]
    private let lock = NSLock()
    private let maxEntries = 100

    struct CacheEntry {
        let result: AsyncLayoutResult
        let contextVersion: Int
        let accessTime: TimeInterval
    }

    func get(key: String, contextVersion: Int) -> AsyncLayoutResult? {
        lock.lock()
        defer { lock.unlock() }
        guard let entry = cache[key], entry.contextVersion == contextVersion else {
            return nil
        }
        cache[key] = CacheEntry(result: entry.result, contextVersion: entry.contextVersion, accessTime: CACurrentMediaTime())
        return entry.result
    }

    func set(key: String, result: AsyncLayoutResult, contextVersion: Int) {
        lock.lock()
        defer { lock.unlock() }
        if cache.count >= maxEntries {
            evictOldest()
        }
        cache[key] = CacheEntry(result: result, contextVersion: contextVersion, accessTime: CACurrentMediaTime())
    }

    func invalidate(key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache.removeValue(forKey: key)
    }

    func invalidateAll() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return cache.count
    }

    private func evictOldest() {
        guard let oldest = cache.min(by: { $0.value.accessTime < $1.value.accessTime }) else { return }
        cache.removeValue(forKey: oldest.key)
    }
}
