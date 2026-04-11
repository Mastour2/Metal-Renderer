import AppKit

enum Key: UInt16, Sendable {
    case w = 13
    case a = 0
    case s = 1
    case d = 2
    case space = 49
    case escape = 53
    case up = 126
    case down = 125
    case left = 123
    case right = 124

    init?(code: UInt16) {
        self.init(rawValue: code)
    }
}

@MainActor
class Input {
    static let shared = Input()

    private var pressedKeys = Set<Key>()

    private init() {}

    func handle(event: NSEvent, isDown: Bool) {
        if let key = Key(code: event.keyCode) {
            if isDown {
                pressedKeys.insert(key)
            } else {
                pressedKeys.remove(key)
            }
        }
    }

    func isPressed(_ key: Key) -> Bool {
        return pressedKeys.contains(key)
    }
}
