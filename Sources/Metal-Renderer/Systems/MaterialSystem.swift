import Metal
import simd

struct MaterialSystem {
    func upload(material: Material, encoder: MTLRenderCommandEncoder) {
        var uniforms = MaterialUniforms(
            basicColor: simd_float4(material.basicColor, 1.0), hasMaterial: true)

        encoder.setFragmentBytes(
            &uniforms,
            length: MemoryLayout<MaterialUniforms>.stride,
            index: 3
        )
    }

    func defaultMaterial(encoder: MTLRenderCommandEncoder) {
        var empty = MaterialUniforms(basicColor: .one, hasMaterial: false)
        encoder.setFragmentBytes(&empty, length: MemoryLayout<MaterialUniforms>.stride, index: 3)
    }
}
