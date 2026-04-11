import simd

protocol Camera {}

struct Camera2d: Camera, Component {
    var size: Float = 5
    var near: Float = -1
    var far: Float = 1
    var position: Vec3 = .zero
    var up: Vec3 = [0, 1, 0]
}

struct Camera3d: Camera, Component {
    var fov: Float = 45
    var near: Float = 0.1
    var far: Float = 100
    var position: Vec3 = .zero
    var target: Vec3 = .zero
    var up: Vec3 = [0, 1, 0]
}
