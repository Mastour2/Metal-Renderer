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

// GL Transmission Format
struct GLTFGeometry: Geometry {
    var vertices: [Vertex]
    var indices: [UInt16]?

    init?(named name: String, offset: OffsetPosition = .none) {
        guard
            let gltfURL = Bundle.module.url(forResource: name, withExtension: "gltf"),
            let gltfData = try? Data(contentsOf: gltfURL),
            let json = try? JSONSerialization.jsonObject(with: gltfData) as? [String: Any]
        else {
            print("GLTF not found: \(name)")
            return nil
        }

        guard
            let bufferViews = json["bufferViews"] as? [[String: Any]],
            let accessors = json["accessors"] as? [[String: Any]],
            let meshes = json["meshes"] as? [[String: Any]],
            let primitive = (meshes.first?["primitives"] as? [[String: Any]])?.first,
            let attributes = primitive["attributes"] as? [String: Int]
        else { return nil }

        // accessor indices
        guard
            let posIdx = attributes["POSITION"],
            let uvIdx = attributes["TEXCOORD_0"],
            let idxIdx = primitive["indices"] as? Int
        else { return nil }

        func bufferOffset(_ accessorIdx: Int) -> (offset: Int, count: Int) {
            let acc = accessors[accessorIdx]
            let bvIdx = acc["bufferView"] as! Int
            let bv = bufferViews[bvIdx]
            let bvOff = bv["byteOffset"] as? Int ?? 0
            let accOff = acc["byteOffset"] as? Int ?? 0
            let count = acc["count"] as! Int
            return (bvOff + accOff, count)
        }

        // bin file
        guard
            let buffers = json["buffers"] as? [[String: Any]],
            let binName = buffers.first?["uri"] as? String
        else { return nil }

        let binBase = String(binName.dropLast(4))
        guard
            let binURL = Bundle.module.url(forResource: binBase, withExtension: "bin"),
            let binData = try? Data(contentsOf: binURL)
        else {
            print("bin not found: \(binName)")
            return nil
        }

        // Positions
        let (posOff, posCount) = bufferOffset(posIdx)
        let positions: [Float] = binData.subdata(
            in: posOff..<posOff + posCount * 12
        ).withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }

        // UVs
        let (uvOff, _) = bufferOffset(uvIdx)
        let uvs: [Float] = binData.subdata(
            in: uvOff..<uvOff + posCount * 8
        ).withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }

        // Indices
        let (idxOff, idxCount) = bufferOffset(idxIdx)
        let rawIdx: [UInt32] = binData.subdata(
            in: idxOff..<idxOff + idxCount * 4
        ).withUnsafeBytes { Array($0.bindMemory(to: UInt32.self)) }

        // center
        let posAcc = accessors[posIdx]
        let minVals = posAcc["min"] as? [Double] ?? []
        let maxVals = posAcc["max"] as? [Double] ?? []
        let centerY =
            minVals.count > 2 && maxVals.count > 2
            ? Float((minVals[2] + maxVals[2]) / 2)
            : 0

        // Build vertices
        var verts: [Vertex] = []
        for i in 0..<posCount {
            verts.append(
                Vertex(
                    position: Vec3(
                        positions[i * 3],
                        positions[i * 3 + 1],
                        positions[i * 3 + 2] - centerY
                    ),
                    color: Vec3(1, 1, 1),
                    uv: Vec2(uvs[i * 2], uvs[i * 2 + 1])
                ))
        }

        self.vertices = verts
        self.indices = rawIdx.map { UInt16($0) }
    }
}
