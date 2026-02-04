import MetalKit
import SwiftUI
import simd


struct Uniforms {
    var mvp: simd_float4x4
}


class Renderer: NSObject, MTKViewDelegate {
    var entities: [Mesh] = []
    var device: MTLDevice!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    var color = (r: 0.4, g: 0.4, b: 0.4, a: 1.0)
    
    var geometry: GeometryProtocol
    var mesh: Mesh
    
    var uniformBuffer: MTLBuffer!
    
    override init() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device?.makeCommandQueue()
      
        geometry = RegularPolygonGeometry(sides: 32, rad: 0.5)
        mesh = Mesh(geo: geometry)
        
        uniformBuffer = device?.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: .storageModeShared);
        
        super.init()
        
        mesh.createBuffer(device: device)
        entities.append(mesh)
        
        buildPipelineState()
    }
    
    
   func add(mesh: Mesh) {
        entities.append(mesh)
    }
    
    private func buildPipelineState() {
        // shader module
        let shader = createShaderLibrary()
        
        // render Pass descriptor
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = shader.vertex
        pipelineStateDescriptor.fragmentFunction = shader.fragment
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // layout
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 3
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
      
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
    }
    
    private func createShaderLibrary() -> (vertex: MTLFunction, fragment: MTLFunction) {
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragment = defaultLibrary.makeFunction(name: "default_fragment")!
        let vertex = defaultLibrary.makeFunction(name: "default_vertex")!
        return (vertex, fragment)
    }


   func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue?.makeCommandBuffer()
        else { return }
        
        let pipelineState = pipelineState!
        
        descriptor.colorAttachments[0].clearColor = MTLClearColor(red: color.r, green: color.g, blue: color.b, alpha: color.a)
        descriptor.colorAttachments[0].loadAction = .clear

        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        
        for mesh in entities {
            encoder?.setRenderPipelineState(pipelineState)
            encoder?.setVertexBuffer(mesh.buffer, offset: 0, index: 0)
            encoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            encoder?.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
            encoder?.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: mesh.geometry.vertexCount,
                instanceCount: 1
            )
        }
        
        encoder?.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
        
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}


struct RendererWarpView: NSViewRepresentable {
    func makeCoordinator() -> Renderer { Renderer() }
    
    private func setupView(context: Context) -> MTKView {
        let view = MTKView()
        
        view.delegate = context.coordinator
        view.clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        view.device = context.coordinator.device
        view.framebufferOnly = true
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        
        return view
    }

    func makeNSView(context: Context) -> MTKView { setupView(context: context) }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
}
