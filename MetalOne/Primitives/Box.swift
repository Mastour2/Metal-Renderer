struct Box {
    let mesh: Mesh
    
    init(x: Float, y: Float, z: Float, size: Float) {
        let geo =  BoxGeometry(size: size)
        let material = Material(tint: Color(0.65, 0.65, 0.65), specularStrength: 0.4, shininess: 256)

        self.mesh = Mesh(geo: geo, mat: material)
        self.mesh.transform.position = Vec3(x: x, y: y, z: z)
    }
}
