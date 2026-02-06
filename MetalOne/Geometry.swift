import Foundation


// 2D Geometry

struct TriangleGeometry: GeometryProtocol {
    var vertices: [Float] = [
        -0.5, -0.5, 0.0,
         0.5, -0.5, 0.0,
         0.0, 0.5, 0.0,
    ]
    var vertexCount: Int = 3
}

struct RectGeometry: GeometryProtocol {
    var vertices: [Float] = []
    var vertexCount: Int { vertices.count / 3 }
    
    init(w: Float, h: Float) {
        let hw = w * 0.5
        let hh = h * 0.5
        
        vertices = [
            -hw, -hh, 0.0,
             hw, -hh, 0.0,
            -hw,  hh, 0.0,
             // triangle
             hw,  hh, 0.0,
            -hw,  hh, 0.0,
             hw, -hh, 0.0
        ]
    }
}

struct RegularPolygonGeometry: GeometryProtocol {
    var vertices: [Float] = []
    var vertexCount: Int { vertices.count / 3 }

    init(sides: Int, rad: Float) {
        for i in 0..<sides {
            let a1 = (Float(i) * 2.0 * .pi) / Float(sides)
            let a2 = (Float(i + 1) * 2.0 * .pi) / Float(sides)

            
            vertices.append(contentsOf: [0.0, 0.0, 0.0])
            
            vertices.append(contentsOf: [
                cos(a1) * rad,
                sin(a1) * rad,
                0.0
            ])
            
            vertices.append(contentsOf: [
                cos(a2) * rad,
                sin(a2) * rad,
                0.0
            ])
        }
    }
}


// 3D Geometry
