import Metal


class Mesh: MeshProtocol, Renderable {
    var geometry: GeometryProtocol
    var material: Material?
   
    internal var buffer: MTLBuffer!
        
    init(geo: GeometryProtocol, mat: Material? = nil) {
        geometry = geo
        material = mat
    }
    
    func prepare(device: MTLDevice) {
        // create buffer in gpu and make default options array
        buffer = device.makeBuffer(bytes: geometry.vertices, length: geometry.vertices.count * MemoryLayout<Float>.size, options: [])
    }
    
    func draw(encoder: MTLRenderCommandEncoder, uniformsBuffer: MTLBuffer) {
        guard let buffer else { return }
        
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
        encoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 1)
        encoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: geometry.vertexCount,
            instanceCount: 1
        )
    }
}
