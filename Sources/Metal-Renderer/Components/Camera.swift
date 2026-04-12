import simd

protocol Camera: Component {}

struct Camera2d: Camera {
    var size: Float
    var near: Float
    var far: Float

    var position: Vec3 = .zero
    var up: Vec3 = .up

    init(
        size: Float = 5,
        near: Float = -1,
        far: Float = 1
    ) {
        self.size = size
        self.near = near
        self.far = far
    }
}

struct Camera3d: Camera {
    var fov: Float
    var near: Float
    var far: Float

    var position: Vec3 = .zero
    var target: Vec3 = .zero
    var up: Vec3 = .up

    init(
        fov: Float = 45,
        near: Float = 0.1,
        far: Float = 100
    ) {
        self.fov = fov
        self.near = near
        self.far = far
    }
}
