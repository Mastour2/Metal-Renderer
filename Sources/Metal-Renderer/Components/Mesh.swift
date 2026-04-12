import Metal

struct Mesh: Component {
    let geometry: Geometry
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?

    var wirframe: Bool

    init(geometry: Geometry) {
        self.geometry = geometry
        self.wirframe = false
    }
}
