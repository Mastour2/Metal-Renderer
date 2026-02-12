struct Box {
    let mesh: Mesh
    
    init(x: Float, y: Float, z: Float, w: Float, h: Float) {
        let geo =  BoxGeometry(size: 1.0)
        let material = Material(tint: Color(0.8, 0.8, 0.8))
        

        self.mesh = Mesh(geo: geo, mat: material)
        self.mesh.transform.position = Vec3(x: x, y: y, z: z)
    }
}
