import Metal

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor {
        let des = MTLVertexDescriptor()

        // position
        des.attributes[0].format = .float3
        des.attributes[0].offset = MemoryLayout<Vertex>.offset(of: \.position)!
        des.attributes[0].bufferIndex = 0

        // color
        des.attributes[1].format = .float3
        des.attributes[1].offset = MemoryLayout<Vertex>.offset(of: \.color)!
        des.attributes[1].bufferIndex = 0

        des.layouts[0].stride = MemoryLayout<Vertex>.stride

        return des
    }
}
