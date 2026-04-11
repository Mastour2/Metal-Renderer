struct Transform: Component {
    var translation: Vec3
    var rotation: Vec3
    var scale: Vec3
    var isLocal: Bool

    init(
        translation: Vec3 = .zero,
        rotation: Vec3 = .zero,
        scale: Vec3 = .one,
        isLocal: Bool = false
    ) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale
        self.isLocal = isLocal
    }
}
