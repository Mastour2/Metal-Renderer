import Metal
import simd

typealias Color = SIMD3<Float>

protocol Renderable {
    func prepare(device: MTLDevice)
    func draw(encoder: MTLRenderCommandEncoder)
}

protocol GeometryProtocol {
    var vertices: [Vertex] { get }
    var indices: [UInt16] { get }
    var normals: [Float] { get }
    var vertexCount: Int { get }
}

protocol MeshProtocol {
    var geometry: GeometryProtocol { get }
    var material: Material? { get set }
    var vertexBuffer: MTLBuffer! { get set }
}

protocol TransformProtocol {
    var scale: simd_float3 {get set}
    var modle: simd_float4x4 {get set}
}
