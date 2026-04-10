import simd

struct Transform: Component {
    var translation: Vec3
    var rotation: Vec3
    var scale: Vec3

    init(
        translation: Vec3 = .zero,
        rotation: Vec3 = .zero,
        scale: Vec3 = .one
    ) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
    }
}

extension Transform {
    var model: simd_float4x4 {
        let t = simd_float4x4(translation: translation)
        let s = simd_float4x4(scale: scale)

        let rx = simd_float4x4(rotationX: rotation.x)
        let ry = simd_float4x4(rotationY: rotation.y)
        let rz = simd_float4x4(rotationZ: rotation.z)

        let r = rz * rx * ry

        return t * r * s
    }
}
