struct Rect {
    let mesh: Mesh
    
    init(x: Float, y: Float, z: Float, w: Float, h: Float) {
        let geo = RectGeometry(w: w, h: h)
        let material = Material(tint: Color(1, 0, 0))
        

        self.mesh = Mesh(geo: geo, mat: material)
        self.mesh.transform.position = Vec3(x: x, y: y, z: z)
    }
}
