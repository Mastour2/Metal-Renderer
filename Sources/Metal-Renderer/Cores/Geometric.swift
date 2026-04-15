import Foundation
import GLTFKit2

struct Vertex {
    var position: Vec3
    var color: Vec3
    var uv: Vec2
    var normal: Vec3 = .zero
}

protocol Geometry {
    var vertices: [Vertex] { get set }
    var indices: [UInt16]? { get set }
}

struct GLTFLoadResult {
    let vertices: [Vertex]
    let indices: [UInt16]
}

// GL Transmission Format
final class GLTFLoader {
    static func load(from url: URL) -> GLTFLoadResult? {
        guard let asset = try? GLTFAsset(url: url),
            let mesh = asset.meshes.first,
            let primitive = mesh.primitives.first
        else { return nil }

        let posAccessor = primitive.attributes.first(where: { $0.name == "POSITION" })?.accessor
        let uvAccessor = primitive.attributes.first(where: { $0.name == "TEXCOORD_0" })?.accessor

        guard let posAcc = posAccessor,
            let posBV = posAcc.bufferView,
            let posData = posBV.buffer.data
        else { return nil }

        let posOff = Int(posBV.offset) + Int(posAcc.offset)
        let count = posAcc.count

        let positions: [Float] = posData.subdata(in: posOff..<posOff + count * 12).withUnsafeBytes {
            Array($0.bindMemory(to: Float.self))
        }

        var uvs: [Float] = Array(repeating: 0, count: count * 2)
        if let uvAcc = uvAccessor,
            let uvBV = uvAcc.bufferView,
            let uvData = uvBV.buffer.data
        {
            let uvOff = Int(uvBV.offset) + Int(uvAcc.offset)
            uvs = uvData.subdata(in: uvOff..<uvOff + count * 8).withUnsafeBytes {
                Array($0.bindMemory(to: Float.self))
            }
        }

        var finalIndices: [UInt16] = []
        if let idxAcc = primitive.indices,
            let idxBV = idxAcc.bufferView,
            let idxData = idxBV.buffer.data
        {

            let idxOff = Int(idxBV.offset) + Int(idxAcc.offset)
            let isUInt32 = idxAcc.componentType == .unsignedInt

            if isUInt32 {
                let raw32: [UInt32] = idxData.subdata(in: idxOff..<idxOff + idxAcc.count * 4)
                    .withUnsafeBytes {
                        Array($0.bindMemory(to: UInt32.self))
                    }
                finalIndices = raw32.map { UInt16($0) }
            } else {
                finalIndices = idxData.subdata(in: idxOff..<idxOff + idxAcc.count * 2)
                    .withUnsafeBytes {
                        Array($0.bindMemory(to: UInt16.self))
                    }
            }
        }

        var centerZ: Float = 0

        if posAcc.minValues.count > 2 && posAcc.maxValues.count > 2 {
            let minZ = posAcc.minValues[2].floatValue
            let maxZ = posAcc.maxValues[2].floatValue
            centerZ = (minZ + maxZ) / 2.0
        }

        let vertices = (0..<count).map { i in
            Vertex(
                position: Vec3(
                    positions[i * 3],
                    positions[i * 3 + 1],
                    positions[i * 3 + 2] - centerZ
                ),
                color: Vec3(1, 1, 1),
                uv: Vec2(uvs[i * 2], uvs[i * 2 + 1])
            )
        }

        return GLTFLoadResult(
            vertices: vertices,
            indices: finalIndices
        )
    }
}

struct Triangle: Geometry {
    var vertices: [Vertex]
    var indices: [UInt16]?

    init() {
        vertices = [
            Vertex(
                position: Vec3(0.0, 0.5, 0.0),
                color: Vec3(1, 1, 1),
                uv: Vec2(0.5, 0)
            ),
            Vertex(
                position: Vec3(-0.5, -0.5, 0.0),
                color: Vec3(1, 1, 1),
                uv: Vec2(0, 1)
            ),
            Vertex(
                position: Vec3(0.5, -0.5, 0.0),
                color: Vec3(1, 1, 1),
                uv: Vec2(1, 1)
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
                color: Vec3(1, 1, 1),
                uv: Vec2(0, 0)
            ),
            Vertex(
                position: Vec3(-0.5, -0.5, 0.0),
                color: Vec3(1, 1, 1),
                uv: Vec2(0, 1)
            ),
            Vertex(
                position: Vec3(0.5, -0.5, 0.0),
                color: Vec3(1, 1, 1),
                uv: Vec2(1, 1)
            ),
            Vertex(
                position: Vec3(0.5, 0.5, 0.0),
                color: Vec3(1, 1, 1),
                uv: Vec2(1, 0)
            ),
        ]

        indices = [
            0, 1, 2,
            0, 2, 3,
        ]
    }
}

enum OffsetPosition {
    case none, center
}

struct ModelGeometry: Geometry {
    var vertices: [Vertex]
    var indices: [UInt16]?

    init?(named name: String, offset: OffsetPosition = .none) {
        guard
            let url = Bundle.module.url(forResource: name, withExtension: "gltf"),
            let res = GLTFLoader.load(from: url)
        else {
            print("GLTF Not Found: \(name)")
            return nil
        }

        self.vertices = res.vertices
        self.indices = res.indices
    }
}
