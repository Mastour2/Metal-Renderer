import Metal


class Mesh: MeshProtocol, Renderable {
    var geometry: GeometryProtocol
    var transform: Transform = Transform()
    var material: Material?
    
    var wireframe: Bool = false
   
    internal var vertexBuffer: MTLBuffer!
    internal var normalsBuffer: MTLBuffer!
    internal var materialBuffer: MTLBuffer!
        
    init(geo: GeometryProtocol, mat: Material? = nil) {
        geometry = geo
        material = mat
    }
    
    func prepare(device: MTLDevice) {
        // create buffer in gpu and make default options array
        self.vertexBuffer = device.makeBuffer(bytes: geometry.vertices, length: geometry.vertices.count * MemoryLayout<Vertex>.size, options: [])
        
        if !self.geometry.normals.isEmpty {
            self.normalsBuffer = device.makeBuffer(
                bytes: geometry.normals,
                length: geometry.normals.count * MemoryLayout<Float>.size,
                options: []
            )
        }
        
        self.materialBuffer = device.makeBuffer(
           length: MemoryLayout<Material>.stride,
           options: .storageModeShared
        );
        
        if var material = self.material {
            memcpy(
                materialBuffer.contents(),
                &material,
                MemoryLayout<Material>.stride
            )
        }
    }
    
    func draw(encoder: MTLRenderCommandEncoder) {
        guard let vertexBuffer else { return }
        
 
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
       
        if let normalsBuffer = normalsBuffer {
            encoder.setVertexBuffer(normalsBuffer, offset: 0, index: 1)
        }

        encoder.setFragmentBuffer(materialBuffer, offset: 0, index: 1)
        
        if wireframe {
            encoder.setTriangleFillMode(.lines)
        } else {
            encoder.setTriangleFillMode(.fill)
        }

        encoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: geometry.vertexCount,
            instanceCount: 1
        )
    }
}
