import Metal
import simd

struct MaterialSystem {
    func upload(material: Material, encoder: MTLRenderCommandEncoder, hasTexture: Bool = false) {
        var uniforms = MaterialUniforms(
            basicColor: simd_float4(material.basicColor, 1.0),
            hasMaterial: true,
            useTexture: hasTexture
        )

        encoder.setFragmentBytes(
            &uniforms,
            length: MemoryLayout<MaterialUniforms>.stride,
            index: 3
        )
    }

    func defaultMaterial(encoder: MTLRenderCommandEncoder, hasTexture: Bool = false) {
        var empty = MaterialUniforms(
            basicColor: .one,
            hasMaterial: false,
            useTexture: hasTexture
        )

        encoder.setFragmentBytes(
            &empty,
            length: MemoryLayout<MaterialUniforms>.stride,
            index: 3
        )
    }
}
