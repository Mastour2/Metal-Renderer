import Metal
import simd

typealias Color = (r: Float, g: Float, b: Float, a: Float)

protocol Renderable {
    func prepare(device: MTLDevice)
    func draw(encoder: MTLRenderCommandEncoder, uniformsBuffer: MTLBuffer)
}

protocol GeometryProtocol {
    var vertices: [Float] { get }
    var vertexCount: Int { get }
}

protocol MeshProtocol {
    var geometry: GeometryProtocol { get }
    var material: Material? { get set }
    var buffer: MTLBuffer! { get set }
}

protocol TransformProtocol {
    var scale: simd_float3 {get set}
    var modle: simd_float4x4 {get set}
}
