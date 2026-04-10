struct Vertex {
    var position: Vec3
    var color: Vec3
}

protocol Geometry {
    var vertices: [Vertex] { get set }
    var indices: [UInt16]? { get set }
}

struct Triangle: Geometry {
    var vertices: [Vertex]
    var indices: [UInt16]?

    init() {
        vertices = [
            Vertex(
                position: Vec3(0.0, 0.5, 0.0),
                color: Vec3(1, 0, 0)
            ),
            Vertex(
                position: Vec3(-0.5, -0.5, 0.0),
                color: Vec3(0, 1, 0)
            ),
            Vertex(
                position: Vec3(0.5, -0.5, 0.0),
                color: Vec3(0, 0, 1)
            ),
        ]
    }
}

struct Quad: Geometry {
    public var vertices: [Vertex]
    public var indices: [UInt16]?

    public init() {
        vertices = [
            Vertex(
                position: Vec3(-0.5, 0.5, 0.0),
                color: Vec3(1, 0, 0)
            ),
            Vertex(
                position: Vec3(-0.5, -0.5, 0.0),
                color: Vec3(0, 1, 0)
            ),
            Vertex(
                position: Vec3(0.5, -0.5, 0.0),
                color: Vec3(0, 0, 1)
            ),
            Vertex(
                position: Vec3(0.5, 0.5, 0.0),
                color: Vec3(0, 0, 1)
            ),
        ]

        indices = [
            0, 1, 2,
            0, 2, 3,
        ]
    }
}
