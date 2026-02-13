import simd


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


extension Transform {
    var matrix: Mat4 {
        let t = float4x4(translation: position)
        let r = float4x4(rotationX: rotation.x) * float4x4(rotationY: rotation.y) * float4x4(rotationZ: rotation.z)
        let s = float4x4(scale: scale)
        
        return t * r * s
    }
}
