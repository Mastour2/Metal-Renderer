import SwiftUI
import MetalKit

class Coordinator: NSObject, MTKViewDelegate  {
    var ctx: Renderer
    
    init(ctx: Renderer) {
        self.ctx = ctx
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        ctx.draw(view: view)
    }
}


struct MetalView: NSViewRepresentable {
    let ctx: Renderer
    
    func makeCoordinator() -> Coordinator {
        Coordinator(ctx: ctx)
    }
    
    func makeNSView(context: Context) -> some NSView {
        let view = MTKView(frame: .zero, device: ctx.device)
        
        view.delegate = context.coordinator
        view.clearColor = MTLClearColor(red: Double(ctx.color.r), green: Double(ctx.color.g), blue: Double(ctx.color.b), alpha: Double(ctx.color.a))
        view.framebufferOnly = true
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        view.colorPixelFormat = .bgra8Unorm
       
        
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
    
}
