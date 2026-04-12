protocol Transformable {
    var transform: Transform { get set }
}

extension Transformable {
    var translation: Vec3 {
        get { transform.translation }
        set {
            let t = transform
            transform.translation = newValue
            transform = t
        }
    }
    var rotation: Vec3 {
        get { transform.rotation }
        set {
            let t = transform
            transform.rotation = newValue
            transform = t
        }
    }
    var scale: Vec3 {
        get { transform.scale }
        set {
            let t = transform
            transform.scale = newValue
            transform = t
        }
    }
}

struct Transform: Component {
    var translation: Vec3
    var rotation: Vec3
    var scale: Vec3

    init(
        translation: Vec3 = .zero,
        rotation: Vec3 = .zero,
        scale: Vec3 = .one,
    ) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
    }
}
