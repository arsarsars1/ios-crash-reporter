import Foundation

enum BreadcrumbBuffer {
    private static let capacity = 64
    private static let lock = NSLock()
    private static var items: [Breadcrumb] = []

    static func add(_ crumb: Breadcrumb) {
        lock.lock()
        defer { lock.unlock() }
        if items.count >= capacity {
            items.removeFirst()
        }
        items.append(crumb)
    }

    static func snapshot() -> [Breadcrumb] {
        lock.lock()
        defer { lock.unlock() }
        return items
    }

    static func clear() {
        lock.lock()
        defer { lock.unlock() }
        items.removeAll()
    }
}
