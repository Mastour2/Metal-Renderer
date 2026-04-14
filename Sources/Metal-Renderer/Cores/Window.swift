import AppKit
import MetalKit
import SwiftUI

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
        self.view.preferredFramesPerSecond = .bitWidth

        self.window.title = title
        self.window.center()
        self.window.makeKeyAndOrderFront(nil)
    }

    func overlay<Content: View>(_ swiftUIView: Content) {
        let hostingView = NSHostingView(rootView: swiftUIView)

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])

        // Transparent background so Metal renders through
        hostingView.layer?.backgroundColor = .clear
    }

    func run() {
        NSApp.activate(ignoringOtherApps: true)

        handleKeyboardEvent()
        app.run()
    }

    private func handleKeyboardEvent() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            Input.shared.handle(event: event, isDown: true)
            return event
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
            Input.shared.handle(event: event, isDown: false)
            return event
        }
    }
}
