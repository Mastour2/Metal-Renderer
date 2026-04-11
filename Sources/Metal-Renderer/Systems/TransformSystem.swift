import Metal
import simd

class TransformSystem {
    func update(for transform: Transform, encoder: MTLRenderCommandEncoder) {
        var model: simd_float4x4 {
            let t = simd_float4x4(translation: transform.translation)
            let s = simd_float4x4(scale: transform.scale)

            let rx = simd_float4x4(rotationX: transform.rotation.x)
            let ry = simd_float4x4(rotationY: transform.rotation.y)
            let rz = simd_float4x4(rotationZ: transform.rotation.z)

            let r = rz * rx * ry

            return t * r * s
        }

        upload(model: model, encoder: encoder)
    }

    private func upload(model: simd_float4x4, encoder: MTLRenderCommandEncoder) {
        var uniforms = EntityUniforms(model: model)

        encoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<EntityUniforms>.stride,
            index: 2
        )
    }
}
