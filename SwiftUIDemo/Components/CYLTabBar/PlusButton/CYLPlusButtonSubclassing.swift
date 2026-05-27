import Foundation

final class CYLPlusButtonSubclassing {
    private(set) static var registeredPlusButton: CYLPlusButtonProtocol?

    static func registerPlusButton(_ button: CYLPlusButtonProtocol) {
        registeredPlusButton = button
    }

    static func unregisterPlusButton() {
        registeredPlusButton = nil
    }
}
