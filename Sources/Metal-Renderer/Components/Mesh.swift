import Metal

struct Mesh: Component {
    let geometry: Geometry
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?

    init(geometry: Geometry) {
        self.geometry = geometry
    }
}
