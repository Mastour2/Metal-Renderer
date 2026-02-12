import simd

typealias Vec3 = SIMD3<Float>
typealias Mat4 = simd_float4x4


struct Transform {
    var position: Vec3
    var rotation: Vec3
    var scale: Vec3
    
    init(
        position: Vec3 = .zero,
        rotation: Vec3 = .zero,
        scale: Vec3 = Vec3(1, 1, 1)
    ) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
}


func translation(_ t: Vec3) -> Mat4 {
    var m = matrix_identity_float4x4
    m.columns.3 = SIMD4<Float>(t, 1)
    return m
}

func scaleV(_ s: Vec3) -> Mat4 {
    simd_float4x4(
        SIMD4<Float>(s.x, 0,   0,   0),
        SIMD4<Float>(0,   s.y, 0,   0),
        SIMD4<Float>(0,   0,   s.z, 0),
        SIMD4<Float>(0,   0,   0,   1)
    )
}

func rotationX(_ a: Float) -> Mat4 {
    let c = cos(a), s = sin(a)
    return simd_float4x4(
        SIMD4<Float>(1, 0,  0, 0),
        SIMD4<Float>(0, c,  s, 0),
        SIMD4<Float>(0, -s, c, 0),
        SIMD4<Float>(0, 0,  0, 1)
    )
}

func rotationY(_ a: Float) -> Mat4 {
    let c = cos(a), s = sin(a)
    return simd_float4x4(
        SIMD4<Float>( c, 0, -s, 0),
        SIMD4<Float>( 0, 1,  0, 0),
        SIMD4<Float>( s, 0,  c, 0),
        SIMD4<Float>( 0, 0,  0, 1)
    )
}

func rotationZ(_ a: Float) -> Mat4 {
    let c = cos(a), s = sin(a)
    return simd_float4x4(
        SIMD4<Float>( c,  s, 0, 0),
        SIMD4<Float>(-s,  c, 0, 0),
        SIMD4<Float>( 0,  0, 1, 0),
        SIMD4<Float>( 0,  0, 0, 1)
    )
}

extension Transform {
    var matrix: Mat4 {
        let translationMat = translation(position)
        let rotationMat = rotationX(rotation.x) * rotationY(rotation.y) * rotationZ(rotation.z)
        let scaleMat = scaleV(self.scale)
        
        return translationMat * rotationMat * scaleMat
    }
}
