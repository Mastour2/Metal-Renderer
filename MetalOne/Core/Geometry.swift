import Foundation

struct Vertex {
    var x, y, z: Float
}


// 2D Geometry

struct TriangleGeometry: GeometryProtocol {
    var vertices: [Vertex] = [
        Vertex(x: 0.0, y:  0.5, z: 0.0),
        Vertex(x: -0.5, y: -0.5, z: 0.0),
        Vertex(x: 0.5, y: -0.5, z: 0.0),
    ]
    
    // tmp 
    var normals: [Float] = [
        0.0, 0.0, 1.0,
        0.0, 0.0, 1.0,
        0.0, 0.0, 1.0
    ]
    
    var indices: [UInt16] = []
    
    var vertexCount: Int { vertices.count }
}

struct RectGeometry: GeometryProtocol {
    var vertices: [Vertex] = []
    var normals: [Float] = []
    var indices: [UInt16] = []

    var vertexCount: Int { vertices.count }
    
    init(w: Float, h: Float) {
        let hw = w * 0.5
        let hh = h * 0.5
        
        vertices = [
            Vertex(x: -hw, y: -hh, z: 0.0),
            Vertex(x:  hw, y: -hh, z: 0.0),
            Vertex(x:  hw, y:  hh, z: 0.0),
             // triangle
            Vertex(x: -hw, y: -hh, z: 0.0),
            Vertex(x:  hw, y:  hh, z: 0.0),
            Vertex(x: -hw, y:  hh, z: 0.0),
        ]
        
        for _ in 0..<6 {
            normals.append(contentsOf: [0.0, 0.0, 1.0])
        }
    }
}

struct RegularPolygonGeometry: GeometryProtocol {
    var vertices: [Vertex] = []
    var normals: [Float] = []
    
    var indices: [UInt16] = []


    var vertexCount: Int { vertices.count }

    init(sides: Int, rad: Float) {
        for i in 0..<sides {
            let a1 = (Float(i) / Float(sides)) * 2.0 * .pi
            let a2 = (Float(i + 1) / Float(sides)) * 2.0 * .pi
                    
            
            let p1 = Vertex(x: cos(a1) * rad, y: sin(a1) * rad, z: 0)
            let p2 = Vertex(x: cos(a2) * rad, y: sin(a2) * rad, z: 0)
                    
                    
            vertices.append(contentsOf: [Vertex(x: 0, y: 0, z: 0)])
            vertices.append(p1)
            vertices.append(p2)
            
            for _ in 0..<3 {
                normals.append(contentsOf: [0.0, 0.0, 1.0])
            }
        }
    }
}


// 3D Geometry

struct BoxGeometry: GeometryProtocol {
    var vertices: [Vertex] = []
    var normals: [Float] = []
    var indices: [UInt16] = []

    var vertexCount: Int { vertices.count }
    
    init(size: Float = 1.0) {
        let s = size * 0.5
        
        let p0 = Vertex(x: -s, y: -s, z:  s) // Front-Bottom-Left
        let p1 = Vertex(x:  s, y: -s, z:  s) // Front-Bottom-Right
        let p2 = Vertex(x:  s, y:  s, z:  s) // Front-Top-Right
        let p3 = Vertex(x: -s, y:  s, z:  s) // Front-Top-Left
        
        let p4 = Vertex(x: -s, y: -s, z: -s) // Back-Bottom-Left
        let p5 = Vertex(x:  s, y: -s, z: -s) // Back-Bottom-Right
        let p6 = Vertex(x:  s, y:  s, z: -s) // Back-Top-Right
        let p7 = Vertex(x: -s, y:  s, z: -s) // Back-Top-Left
        
        func addFace(_ a: Vertex, _ b: Vertex, _ c: Vertex,
                     _ d: Vertex, _ e: Vertex, _ f: Vertex,
                     normal: [Float]) {
            
            vertices.append(contentsOf: [a, b, c, d, e, f])
            for _ in 0..<6 {
                normals.append(contentsOf: normal)
            }
        }
        
      
        addFace(
            p0, p1, p2,
            p0, p2, p3,
            normal: [0, 0, 1]
        )
     
        addFace(
            p5, p4, p7,
            p5, p7, p6,
            normal: [0, 0, -1]
        )
     
        addFace(
            p3, p2, p6,
            p3, p6, p7,
            normal: [0, 1, 0]
        )
    
        addFace(
            p4, p5, p1,
            p4, p1, p0,
            normal: [0, -1, 0]
        )
       
        addFace(
            p1, p5, p6,
            p1, p6, p2,
            normal: [1, 0, 0]
        )
        
        addFace(
            p4, p0, p3,
            p4, p3, p7,
            normal: [-1, 0, 0]
        )
    }
}
