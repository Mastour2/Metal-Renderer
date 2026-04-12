import Metal
import simd

struct CameraSystem {
    func update(for camera: any Camera, aspect: Float, encoder: MTLRenderCommandEncoder) {
        switch camera {
        case let cam as Camera2d:
            let (p, v) = makeOrthographic(camera: cam, aspect: aspect)
            upload(proj: p, view: v, encoder: encoder)
        case let cam as Camera3d:
            let (p, v) = makePerspective(camera: cam, aspect: aspect)
            upload(proj: p, view: v, encoder: encoder)
        default:
            break
        }
    }

    func makePerspective(camera: Camera3d, aspect: Float) -> (
        proj: simd_float4x4, view: simd_float4x4
    ) {
        let p = simd_float4x4(
            fov: camera.fov,
            aspect: aspect,
            near: camera.near,
            far: camera.far
        )

        let v = simd_float4x4(eye: camera.position, center: camera.target, up: camera.up)

        return (p, v)
    }

    func makeOrthographic(camera: Camera2d, aspect: Float) -> (
        proj: simd_float4x4, view: simd_float4x4
    ) {
        let p = simd_float4x4(
            orthographic: camera.size,
            aspect: aspect,
            near: camera.near,
            far: camera.far
        )

        let v = simd_float4x4(
            eye: camera.position, center: camera.position + [0, 0, -1], up: camera.up)

        return (p, v)
    }

    private func upload(proj: simd_float4x4, view: simd_float4x4, encoder: MTLRenderCommandEncoder)
    {
        var uniforms = FrameUniforms(view: view, projection: proj)
        encoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<FrameUniforms>.stride,
            index: 1)
    }
}
