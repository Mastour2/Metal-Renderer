import Metal

class RenderSystem {
    func prepare(mesh: inout Mesh, device: MTLDevice) {
        mesh.vertexBuffer = device.makeBuffer(
            bytes: mesh.geometry.vertices,
            length: MemoryLayout<Vertex>.stride * mesh.geometry.vertices.count,
            options: .storageModeShared
        )

        if let indices = mesh.geometry.indices {
            mesh.indexBuffer = device.makeBuffer(
                bytes: indices,
                length: MemoryLayout<UInt16>.stride * indices.count,
                options: .storageModeShared
            )
        }
    }

    func render(mesh: Mesh, encoder: MTLRenderCommandEncoder) {
        // if mesh.vertexBuffer == nil {
        //     var mutableMesh = mesh
        //     self.prepare(mesh: &mutableMesh, device: device)
        // }

        guard let vbo = mesh.vertexBuffer else { return }
        encoder.setVertexBuffer(vbo, offset: 0, index: 0)

        if let ibo = mesh.indexBuffer {
            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: mesh.geometry.indices?.count ?? 0,
                indexType: .uint16,
                indexBuffer: ibo,
                indexBufferOffset: 0
            )
        } else {
            encoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: mesh.geometry.vertices.count
            )
        }
    }
}
