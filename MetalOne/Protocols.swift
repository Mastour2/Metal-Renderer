import Metal
import simd

protocol GeometryProtocol {
    var positions: [Float] { get }
    var vertexCount: Int { get }
}

protocol MeshProtocol {
    var geometry: GeometryProtocol { get }
    var modle: simd_half4x4 { get set }
    var buffer: MTLBuffer! { get set }
    var size: Int { get set }
    mutating func createBuffer(device: MTLDevice) -> Void
}

protocol TransformProtocol {
    var scale: simd_float3 {get set}
    var modle: simd_float4x4 {get set}
}
