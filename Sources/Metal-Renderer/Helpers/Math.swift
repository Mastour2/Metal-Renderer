import simd

typealias Vec3 = SIMD3<Float>
typealias Mat4x4 = simd_float4x4

extension simd_float4x4 {
    static var identity: Mat4x4 {
        matrix_identity_float4x4
    }

    init(translation: Vec3) {
        self = matrix_identity_float4x4
        columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)
    }

    init(scale: Vec3) {
        self = .identity
        self.columns.0.x = scale.x
        self.columns.1.y = scale.y
        self.columns.2.z = scale.z
    }

    init(rotation angle: Float) {
        self = .identity

        let c = cos(angle)
        let s = sin(angle)

        self.columns.0 = SIMD4<Float>(c, s, 0, 0)
        self.columns.1 = SIMD4<Float>(-s, c, 0, 0)
    }

    init(rotationX angle: Float) {
        self = .identity
        let c = cos(angle)
        let s = sin(angle)
        self.columns.1 = [0, c, s, 0]
        self.columns.2 = [0, -s, c, 0]
    }

    init(rotationY angle: Float) {
        self = .identity
        let c = cos(angle)
        let s = sin(angle)
        self.columns.0 = [c, 0, -s, 0]
        self.columns.2 = [s, 0, c, 0]
    }

    init(rotationZ angle: Float) {
        self = .identity
        let c = cos(angle)
        let s = sin(angle)
        self.columns.0 = [c, s, 0, 0]
        self.columns.1 = [-s, c, 0, 0]
    }

    init(fov: Float, aspect: Float, near: Float, far: Float) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = far / (far - near)
        let w = -(far * near) / (far - near)

        self.init()
        columns.0 = [x, 0, 0, 0]
        columns.1 = [0, y, 0, 0]
        columns.2 = [0, 0, z, 1]
        columns.3 = [0, 0, w, 0]
    }

    init(eye: Vec3, center: Vec3, up: Vec3) {
        let z = (center - eye).normalized
        let x = up.cross(z).normalized
        let y = z.cross(x)

        self.init()
        columns.0 = [x.x, y.x, z.x, 0]
        columns.1 = [x.y, y.y, z.y, 0]
        columns.2 = [x.z, y.z, z.z, 0]
        columns.3 = [-x.dot(eye), -y.dot(eye), -z.dot(eye), 1]
    }

    //init(orthographic: Any) {}
}

extension SIMD3 where Scalar == Float {
    var length: Float {
        return simd_length(self)
    }

    var normalized: SIMD3<Float> {
        return simd_normalize(self)
    }

    func dot(_ other: SIMD3<Float>) -> Float {
        return simd_dot(self, other)
    }

    func cross(_ other: SIMD3<Float>) -> SIMD3<Float> {
        return simd_cross(self, other)
    }
}
