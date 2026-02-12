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
        view.clearColor = MTLClearColor(red: Double(ctx.color.x), green: Double(ctx.color.y), blue: Double(ctx.color.z), alpha: 1.0)
        view.framebufferOnly = true
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        view.colorPixelFormat = .rgba8Unorm
        view.depthStencilPixelFormat = .depth32Float
       
        
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
        print("update")
    }
    
}
