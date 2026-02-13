import MetalKit
import SwiftUI
import simd

struct CameraUniforms {
    var mvp: matrix_float4x4
    var modelMatrix: matrix_float4x4
    var cameraPosition: Vec3
}


final class Renderer {
    private var renderables: [any Renderable] = []
   
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    var camera: Camera?
    var pipelineState: MTLRenderPipelineState?
    var color: Color = Color(0.0, 0.0, 0.0)
  
    
    init(camera: Camera) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU is not supported")
        }
        
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create a command queue")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        self.pipelineState = self.buildPipelineState()
        
        self.camera = camera
    }
    
    func clearColor(r: Float, g: Float, b: Float) {
        color = Color(r, g, b)
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
        
  
        guard
            let p = self.camera?.perspective(),
            let v = self.camera?.viewMat()
        else {return}
        
        self.camera?.updateAspect(view: view)
        
        descriptor.colorAttachments[0].clearColor = MTLClearColor(red: Double(color.x), green: Double(color.y), blue: Double(color.z), alpha: 1.0)
        descriptor.colorAttachments[0].loadAction = .clear
        
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        
        let depthState = device.makeDepthStencilState(descriptor: depthDescriptor)
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)

  
        encoder?.setDepthStencilState(depthState)
        encoder?.setRenderPipelineState(pipelineState)
      
        encoder?.setFrontFacing(.clockwise)
        encoder?.setCullMode(.back)
        
   
        for r in renderables {
            if let mesh = r as? Mesh {
               //mesh.transform.rotation.y += 0.01
                
                let m = mesh.transform.matrix
                let MVP = p * v * m
                
                var cameraUniforms = CameraUniforms(
                    mvp: MVP,
                    modelMatrix: m,
                    cameraPosition: (self.camera?.transform.position)!
                )
                
                encoder?.setVertexBytes(&cameraUniforms, length: MemoryLayout<CameraUniforms>.stride, index: 2)
                encoder?.setFragmentBytes(&cameraUniforms, length: MemoryLayout<CameraUniforms>.stride, index: 2)
                
                r.draw(encoder: encoder!)
            }
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
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        let vertexDescriptor = MTLVertexDescriptor()
      
        // Position (Attribute 0 -> Buffer 0)
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 3
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
        // Normals (Attribute 1 -> Buffer 1)
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[1].stride = MemoryLayout<Float>.size * 3
        
      
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

