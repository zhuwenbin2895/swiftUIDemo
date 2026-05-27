import Foundation
import ObjectiveC
import UIKit

// MARK: - Safe Method Swizzling

final class MethodSwizzler {
    struct SwizzleRecord: Identifiable {
        let id = UUID()
        let className: String
        let originalSelector: String
        let swizzledSelector: String
        let timestamp: Date
        var isActive: Bool = true
    }

    static let shared = MethodSwizzler()
    private(set) var records: [SwizzleRecord] = []

    @discardableResult
    func swizzle(
        class targetClass: AnyClass,
        original originalSelector: Selector,
        swizzled swizzledSelector: Selector
    ) -> Bool {
        guard let originalMethod = class_getInstanceMethod(targetClass, originalSelector),
              let swizzledMethod = class_getInstanceMethod(targetClass, swizzledSelector) else {
            return false
        }

        let didAdd = class_addMethod(
            targetClass,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )

        if didAdd {
            class_replaceMethod(
                targetClass,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }

        let record = SwizzleRecord(
            className: NSStringFromClass(targetClass),
            originalSelector: NSStringFromSelector(originalSelector),
            swizzledSelector: NSStringFromSelector(swizzledSelector),
            timestamp: Date()
        )
        records.append(record)
        return true
    }

    func reset() {
        records.removeAll()
    }
}

// MARK: - Dynamic Property Binding (Associated Objects)

final class DynamicProperty {
    struct PropertyRecord: Identifiable {
        let id = UUID()
        let objectType: String
        let key: String
        let valueType: String
        let policy: String
        let timestamp: Date
    }

    static let shared = DynamicProperty()
    private(set) var records: [PropertyRecord] = []

    func setProperty<T>(
        on object: AnyObject,
        key: UnsafeRawPointer,
        value: T?,
        policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    ) {
        objc_setAssociatedObject(object, key, value, policy)

        let record = PropertyRecord(
            objectType: String(describing: type(of: object)),
            key: String(describing: key),
            valueType: String(describing: T.self),
            policy: policyName(policy),
            timestamp: Date()
        )
        records.append(record)
    }

    func getProperty<T>(from object: AnyObject, key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(object, key) as? T
    }

    func removeAllProperties(from object: AnyObject) {
        objc_removeAssociatedObjects(object)
    }

    func reset() {
        records.removeAll()
    }

    private func policyName(_ policy: objc_AssociationPolicy) -> String {
        switch policy {
        case .OBJC_ASSOCIATION_ASSIGN: return "ASSIGN"
        case .OBJC_ASSOCIATION_RETAIN_NONATOMIC: return "RETAIN_NONATOMIC"
        case .OBJC_ASSOCIATION_COPY_NONATOMIC: return "COPY_NONATOMIC"
        case .OBJC_ASSOCIATION_RETAIN: return "RETAIN"
        case .OBJC_ASSOCIATION_COPY: return "COPY"
        default: return "UNKNOWN"
        }
    }
}

// MARK: - Demo Helper Class

class RuntimeDemoObject: NSObject {
    @objc dynamic func originalMethod() -> String {
        return "原始方法被调用"
    }

    @objc dynamic func swizzledMethod() -> String {
        return "交换后的方法被调用 (原方法已被替换)"
    }
}

private var customNameKey: UInt8 = 0
private var customTagKey: UInt8 = 0
private var customDataKey: UInt8 = 0

extension UIView {
    var runtimeCustomName: String? {
        get { DynamicProperty.shared.getProperty(from: self, key: &customNameKey) }
        set { DynamicProperty.shared.setProperty(on: self, key: &customNameKey, value: newValue) }
    }

    var runtimeCustomTag: Int? {
        get { DynamicProperty.shared.getProperty(from: self, key: &customTagKey) }
        set { DynamicProperty.shared.setProperty(on: self, key: &customTagKey, value: newValue) }
    }

    var runtimeCustomData: [String: Any]? {
        get { DynamicProperty.shared.getProperty(from: self, key: &customDataKey) }
        set { DynamicProperty.shared.setProperty(on: self, key: &customDataKey, value: newValue) }
    }
}
