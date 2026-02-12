import Foundation

struct Vertex {
    var x, y, z: Float
}


// 2D Geometry

struct TriangleGeometry: GeometryProtocol {
    var vertices: [Vertex] = [
        Vertex(x: -0.5, y: -0.5, z: 0.0),
        Vertex(x: 0.5, y: -0.5, z: 0.0),
        Vertex(x: 0.0, y: 0.5, z: 0.0),
    ]
    
    var normals: [Float] = [
        0.0, 0.0, 1.0,
        0.0, 0.0, 1.0,
        0.0, 0.0, 1.0
    ]
    
    var indices: [UInt16] = [
      0, 1, 2
    ]
    
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
            Vertex(x: -hw, y: hh, z: 0.0),
             // triangle
            Vertex(x: hw, y: hh, z: 0.0),
            Vertex(x: -hw, y: hh, z: 0.0),
            Vertex(x: hw, y: -hh, z: 0.0),
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
            let a1 = (Float(i) * 2.0 * .pi) / Float(sides)
            let a2 = (Float(i + 1) * 2.0 * .pi) / Float(sides)

            
            vertices.append(contentsOf: [Vertex(x: 0, y: 0, z: 0)])
            
            vertices.append(contentsOf: [
                Vertex(x: cos(a1) * rad, y: sin(a1) * rad, z: 0)
            ])
            
            vertices.append(contentsOf: [
                Vertex(x: cos(a2) * rad, y: sin(a2) * rad, z: 0)
            ])
            
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
    
    init(size: Float) {
        let s = size * 0.5
        let p0 = Vertex(x: -s, y: -s, z:  s) // Front-Bottom-Left
        let p1 = Vertex(x:  s, y: -s, z:  s) // Front-Bottom-Right
        let p2 = Vertex(x:  s, y:  s, z:  s) // Front-Top-Right
        let p3 = Vertex(x: -s, y:  s, z:  s) // Front-Top-Left
        
        let p4 = Vertex(x: -s, y: -s, z: -s) // Back-Bottom-Left
        let p5 = Vertex(x:  s, y: -s, z: -s) // Back-Bottom-Right
        let p6 = Vertex(x:  s, y:  s, z: -s) // Back-Top-Right
        let p7 = Vertex(x: -s, y:  s, z: -s) // Back-Top-Left

        // 1. الوجه الأمامي (Front Face) - Z موجبة
//        vertices.append(contentsOf: [p0, p1, p2, p0, p2, p3])
                
        // 2. الوجه الخلفي (Back Face) - Z سالبة
//        vertices.append(contentsOf: [p5, p4, p7, p5, p7, p6])
                
        // 3. الوجه العلوي (Top Face) - Y موجبة
//        vertices.append(contentsOf: [p3, p2, p6, p3, p6, p7])
                
        // 4. الوجه السفلي (Bottom Face) - Y سالبة
//        vertices.append(contentsOf: [p4, p5, p1, p4, p1, p0])
                
        // 5. الوجه الأيمن (Right Face) - X موجبة
//        vertices.append(contentsOf: [p1, p5, p6, p1, p6, p2])
                
        // 6. الوجه الأيسر (Left Face) - X سالبة
//        vertices.append(contentsOf: [p4, p0, p3, p4, p3, p7])
        
        func addFace(p_a: Vertex, p_b: Vertex, p_c: Vertex, p_d: Vertex, p_e: Vertex, p_f: Vertex, n: [Float]) {
            vertices.append(contentsOf: [p_a, p_b, p_c, p_d, p_e, p_f])
            for _ in 0..<6 {
                normals.append(contentsOf: n)
            }
        }
        
        
        // 1. الوجه الأمامي (Z+)
        addFace(p_a: p0, p_b: p1, p_c: p2, p_d: p0, p_e: p2, p_f: p3, n: [0, 0, 1])
                
        // 2. الوجه الخلفي (Z-)
        addFace(p_a: p5, p_b: p4, p_c: p7, p_d: p5, p_e: p7, p_f: p6, n: [0, 0, -1])
                
        // 3. الوجه العلوي (Y+)
        addFace(p_a: p3, p_b: p2, p_c: p6, p_d: p3, p_e: p6, p_f: p7, n: [0, 1, 0])
                
        // 4. الوجه السفلي (Y-)
        addFace(p_a: p4, p_b: p5, p_c: p1, p_d: p4, p_e: p1, p_f: p0, n: [0, -1, 0])
                
        // 5. الوجه الأيمن (X+)
        addFace(p_a: p1, p_b: p5, p_c: p6, p_d: p1, p_e: p6, p_f: p2, n: [1, 0, 0])
                
        // 6. الوجه الأيسر (X-)
        addFace(p_a: p4, p_b: p0, p_c: p3, p_d: p4, p_e: p3, p_f: p7, n: [-1, 0, 0])
    }
}
