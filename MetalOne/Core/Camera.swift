import simd
import MetalKit

struct Camera {
    var fovy: Float
    var aspect: Float = 1.0
    var near: Float = 0.1
    var far: Float = 100.0
    
    var target: Vec3 = Vec3(0, 1, 0)
    var transform: Transform = Transform(position: Vec3(0, 0, -5))
    
    
    private var fovyRadians: Float {
        return fovy * (.pi / 180.0)
    }
    
    func lookAt() {
        
    }
    
    mutating func updateAspect(view: MTKView) {
        let size = view.drawableSize
        if size.height > 0 {
            self.aspect = Float(size.width / size.height)
        }
    }
    
    func perspectiveProjection() -> Mat4 {
        let ys = 1 / tanf(fovyRadians * 0.5)
        let xs = ys / aspect
        let zs = far / (far - near)
        
        return Mat4(
            [xs,  0,  0,  0],
            [0,  ys,  0,  0],
            [0,   0, zs,  1],
            [0,   0, -near * zs, 0]
        )
    }
    
    func viewMatrix() -> Mat4 {
        let translateMat = translation(-transform.position)
        
        let rotX = rotationX(-transform.rotation.x)
        let rotY = rotationY(-transform.rotation.y)
        let rotZ = rotationZ(-transform.rotation.z)
            
        let rotateMat = rotZ * rotY * rotX
            
        return rotateMat * translateMat
    }
 
}
