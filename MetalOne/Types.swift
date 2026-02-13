import simd

typealias Vec3 = SIMD3<Float>
typealias Vec4 = SIMD4<Float>
typealias Mat4 = simd_float4x4


extension float4x4 {
    init(translation t: Vec3) {
        self = matrix_identity_float4x4
        columns.3 = SIMD4(t.x, t.y, t.z, 1)
    }
    
    init(rotation r: Vec3) {
        let rx = float4x4(rotationX: r.x)
        let ry = float4x4(rotationY: r.y)
        let rz = float4x4(rotationZ: r.z)
        self = rz * ry * rx
    }
    
    init(rotationX angle: Float) {
        let c = cos(angle)
        let s = sin(angle)
        self.init(SIMD4(1,0,0,0),
                  SIMD4(0,c,s,0),
                  SIMD4(0,-s,c,0),
                  SIMD4(0,0,0,1)
        )
    }
    
    init(rotationY angle: Float) {
        let c = cos(angle)
        let s = sin(angle)
        self.init(SIMD4(c,0,-s,0),
                  SIMD4(0,1,0,0),
                  SIMD4(s,0,c,0),
                  SIMD4(0,0,0,1)
        )
    }
    
    init(rotationZ angle: Float) {
        let c = cos(angle)
        let s = sin(angle)
        self.init(SIMD4(c,s,0,0),
                  SIMD4(-s,c,0,0),
                  SIMD4(0,0,1,0),
                  SIMD4(0,0,0,1)
        )
    }
    
    init(scale s: Vec3) {
        self.init(SIMD4(s.x, 0,   0,   0),
                  SIMD4(0,   s.y, 0,   0),
                  SIMD4(0,   0,   s.z, 0),
                  SIMD4(0,   0,   0,   1)
        )
    }
    
    init(uniformScale s: Float) {
        self.init(scale: Vec3(repeating: s))
    }
}
