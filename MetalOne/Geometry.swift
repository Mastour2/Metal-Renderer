import Foundation



struct TriangleGeometry: GeometryProtocol {
    var positions: [Float] = [
        -0.5, -0.5, 0.0,
         0.5, -0.5, 0.0,
         0.0, 0.5, 0.0,
    ]
    var vertexCount: Int = 3
}

struct RectGeometry: GeometryProtocol {
    var positions: [Float] = []
    var vertexCount: Int { positions.count / 3 }
    
    init(w: Float, h: Float) {
        let hw = w * 0.5
        let hh = h * 0.5
        
        positions = [
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
    var positions: [Float] = []
    var vertexCount: Int { positions.count / 3 }

    init(sides: Int, rad: Float) {
        for i in 0..<sides {
            let a1 = (Float(i) * 2.0 * .pi) / Float(sides)
            let a2 = (Float(i + 1) * 2.0 * .pi) / Float(sides)

            
            positions.append(contentsOf: [0.0, 0.0, 0.0])
            
            positions.append(contentsOf: [
                cos(a1) * rad,
                sin(a1) * rad,
                0.0
            ])
            
            positions.append(contentsOf: [
                cos(a2) * rad,
                sin(a2) * rad,
                0.0
            ])
        }
    }
}
