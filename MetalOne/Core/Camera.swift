import simd
import MetalKit

enum CameraType {
    case Debug
}

struct Camera {
    var fovy: Float = 60
    var aspect: Float = 1
    var near: Float = 0.1
    var far: Float = 100
    
    var transform: Transform = Transform()
    var target: Vec3?
    
    mutating func updateAspect(view: MTKView) {
        let size = view.drawableSize
        if size.height > 0 {
            aspect = Float(size.width / size.height)
        }
    }
    
    func perspective() -> Mat4 {
        return projectionMat()
    }
    
    
    func lookAtMat(eye: Vec3, center: Vec3, up: Vec3) -> Mat4 {
        let z = normalize(center - eye)
        let x = normalize(cross(z, up))
        let y = cross(x, z)
        
        return Mat4(
            Vec4(x.x, y.x, -z.x, 0),
            Vec4(x.y, y.y, -z.y, 0),
            Vec4(x.z, y.z, -z.z, 0),
            Vec4(-dot(x, eye), -dot(y, eye), dot(z, eye), 1)
        )
    }
   
   
    func projectionMat() -> Mat4 {
        let r = fovy * (.pi / 180)
        let y = 1 / tan(r * 0.5)
        let x = y / aspect
        let z = far / (far - near)
        
        return Mat4(
            Vec4(x, 0, 0, 0),
            Vec4(0, y, 0, 0),
            Vec4(0, 0, z, 1),
            Vec4(0, 0, -near * z, 0)
        )
  
    }
    
    
    func viewMat() -> Mat4 {
        if let target = target {
            return lookAtMat(
                eye: transform.position,
                center: target,
                up: Vec3(0, 1, 0)
            )
        }
        
        return float4x4(translation: -transform.position) * float4x4(rotation: -transform.rotation)
    }
    
}
