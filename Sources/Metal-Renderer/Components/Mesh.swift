import Metal

class Mesh: Component {
    let geometry: Geometry
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?

    init(geometry: Geometry) {
        self.geometry = geometry

    }

    func prepare(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(
            bytes: geometry.vertices,
            length: MemoryLayout<Vertex>.stride * geometry.vertices.count,
            options: .storageModeShared
        )

        if let indices = geometry.indices {
            indexBuffer = device.makeBuffer(
                bytes: indices,
                length: MemoryLayout<UInt16>.stride * indices.count,
                options: .storageModeShared
            )
        }
    }

    func draw(encoder: MTLRenderCommandEncoder) {
        guard let vbo = vertexBuffer else { return }

        encoder.setVertexBuffer(vbo, offset: 0, index: 0)

        if let ibo = indexBuffer {
            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: geometry.indices?.count ?? 0,
                indexType: .uint16,
                indexBuffer: ibo,
                indexBufferOffset: 0
            )
        } else {
            encoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: geometry.vertices.count
            )
        }
    }
}
