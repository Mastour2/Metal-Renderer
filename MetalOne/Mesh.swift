import Metal
import simd


struct Transform {
    let position = SIMD3<Float>(0, 0, 0)
    let scale = SIMD3<Float>(1, 1, 1)
    var modle = matrix_identity_half4x4
}


struct Mesh: MeshProtocol {
    var geometry: GeometryProtocol
    var buffer: MTLBuffer!
    var size: Int = 0
    var modle = matrix_identity_half4x4
    
    init(geo: GeometryProtocol) {
        geometry = geo
    }
    
    mutating func createBuffer(device: MTLDevice) {
        // size of buffer
        size = geometry.positions.count * MemoryLayout.size(ofValue: geometry.positions[0])
        // create buffer in gpu and make default options array
        buffer = device.makeBuffer(bytes: geometry.positions, length: size, options: [])
    }
}
