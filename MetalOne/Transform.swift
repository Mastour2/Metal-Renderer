import simd

struct Transform {
    let position = SIMD3<Float>(0, 0, 0)
    let scale = SIMD3<Float>(1, 1, 1)
    var modle = matrix_identity_half4x4
}
