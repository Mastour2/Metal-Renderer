import AppKit
import MetalKit

@MainActor
class Window {
    var title: String
    var width: UInt
    var height: UInt
    var view: MTKView

    private var app: NSApplication!
    private var window: NSWindow!
    private var context: Renderer?

    init(title: String, width: UInt, height: UInt) {
        self.title = title
        self.width = width
        self.height = height

        self.app = NSApplication.shared
        self.app.setActivationPolicy(.regular)

        self.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        self.view = MTKView(frame: self.window.contentView!.frame)
        self.window.contentView = self.view

        self.window.title = title
        self.window.center()
        self.window.makeKeyAndOrderFront(nil)
    }

    func append(_ label: NSControl) {
        self.view.addSubview(label)
    }

    func run() {
        NSApp.activate(ignoringOtherApps: true)
        self.app.run()
    }
}
