import MetalKit
import SwiftUI
import simd


struct Uniforms {
    var mvp: simd_float4x4
}


final class Renderer {
    private var renderables: [any Renderable] = []
    
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState?
    var uniformBuffer: MTLBuffer?
    var color: Color = (r: 0.4, g: 0.4, b: 0.4, a: 1.0)

    
     init() {
         guard let device = MTLCreateSystemDefaultDevice() else {
             fatalError("GPU is not supported")
         }
         
         guard let commandQueue = device.makeCommandQueue() else {
             fatalError("Could not create a command queue")
         }
         
         self.device = device
         self.commandQueue = commandQueue
         self.uniformBuffer = device.makeBuffer(
            length: MemoryLayout<Uniforms>.stride,
            options: .storageModeShared
         );
         self.pipelineState = self.buildPipelineState()
    }
    
    func clearColor(r: Float, g: Float, b: Float) {
        color = (r: r, g: g, b: b, a: 1.0)
    }
    
   
    func insert(mesh: Mesh) {
        mesh.prepare(device: self.device)
        self.renderables.append(mesh)
    }

  
    func draw(view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let pipelineState = pipelineState
        else { return }
       
       
        descriptor.colorAttachments[0].clearColor = MTLClearColor(red: Double(color.r), green: Double(color.g), blue: Double(color.b), alpha: Double(color.a))
        descriptor.colorAttachments[0].loadAction = .clear

        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
       
       encoder?.setRenderPipelineState(pipelineState)
        
        for r in renderables {
            r.draw(encoder: encoder!, uniformsBuffer: uniformBuffer!)
        }
        
        encoder?.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    
    private func buildPipelineState() -> MTLRenderPipelineState? {
        // shader module
        guard let shader = createShaderLibrary() else {
            return nil
        }
        
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
        return try? self.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    private func createShaderLibrary(vertexSrc: String = "default_vertex", fragmentSrc: String = "default_fragment") -> (vertex: MTLFunction, fragment: MTLFunction)? {
        guard
            let library = self.device.makeDefaultLibrary(),
            let vertex = library.makeFunction(name: vertexSrc),
            let fragment = library.makeFunction(name: fragmentSrc)
        else {
            return nil
        }
        
        return (vertex, fragment)
    }
}

