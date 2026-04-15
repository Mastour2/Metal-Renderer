import MetalKit

let shaders = """
    #include <metal_stdlib>
    using namespace metal;

    struct FrameUniforms {
      float4x4 view;
      float4x4 projection;
    };

    struct EntityUniforms {
      float4x4 model;
    };

    struct MaterialUniforms {
        float4 basicColor;
        bool hasMaterial;
        bool useTexture;
    };

    struct VertexIn {
      float3 position [[attribute(0)]];
      float3 color [[attribute(1)]];
      float2 uv [[attribute(2)]];
    };

    struct VertexOut {
      float4 position [[position]];
      float4 color;
      float2 uv;
    };

    vertex VertexOut vertex_main(
        const VertexIn in [[stage_in]],
        constant FrameUniforms &frame [[buffer(1)]],
        constant EntityUniforms &entity [[buffer(2)]]
    ) {
      VertexOut out;

      out.position = frame.projection * frame.view * entity.model * float4(in.position, 1);
      out.color = float4(in.color, 1);
      out.uv = in.uv;

      return out;
    }

    fragment float4 fragment_main(
        VertexOut in [[stage_in]],
        constant MaterialUniforms &material [[buffer(3)]],
        sampler texSampler [[sampler(0)]],
        texture2d<float> texture [[texture(0)]]
    ) {
        float4 color = in.color;

        if (material.hasMaterial) {
            color = material.basicColor;
        }

        if (material.useTexture) {
            color = texture.sample(texSampler, in.uv);
        }

        if (material.hasMaterial && material.useTexture) {
            color = material.basicColor * texture.sample(texSampler, in.uv);
        }

        return color;
    }
    """

// Data form Scene and Camera if has
struct FrameUniforms {
    var view: simd_float4x4 = .identity
    var projection: simd_float4x4 = .identity
}

// Data from Entity Transform if has
struct EntityUniforms {
    var model: simd_float4x4 = .identity
}

struct TextureUniforms {
    var texture: simd_float2
}

struct MaterialUniforms {
    var basicColor: simd_float4
    var hasMaterial: Bool
    var useTexture: Bool = false
}

@MainActor
class Renderer: NSObject {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var encoder: MTLRenderCommandEncoder!
    var pipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    var samplerState: MTLSamplerState!
    var view: MTKView!
    var world: World?

    var frame = Frame()

    var aspect: Float = 1

    var mesh: MTKMesh?

    init?(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue()
        else {
            fatalError("GPU is not supported")
            return nil
        }

        super.init()

        self.device = device
        self.commandQueue = commandQueue
        self.view = view

        self.aspect = Float(view.drawableSize.width / view.drawableSize.height)

        view.device = device
        view.clearColor = MTLClearColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        view.depthStencilPixelFormat = .depth32Float

        prepareRenderPipeline()

        view.delegate = self
    }

    func attach(world: World) {
        self.world = world
    }

    private func prepareRenderPipeline() {
        guard let library = try? device.makeLibrary(source: shaders, options: nil) else {
            fatalError("Could not find Metal library")
        }

        let vertexFunc = library.makeFunction(name: "vertex_main")
        let fragmentFunc = library.makeFunction(name: "fragment_main")
        let des = MTLRenderPipelineDescriptor()

        des.vertexFunction = vertexFunc
        des.fragmentFunction = fragmentFunc
        des.colorAttachments[0].pixelFormat = view.colorPixelFormat
        des.vertexDescriptor = MTLVertexDescriptor.defaultLayout

        des.depthAttachmentPixelFormat = view.depthStencilPixelFormat

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        self.depthStencilState = self.device.makeDepthStencilState(descriptor: depthDescriptor)

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.label = "texture"
        self.samplerState = self.device.makeSamplerState(descriptor: samplerDescriptor)

        do {
            pipelineState = try self.device.makeRenderPipelineState(descriptor: des)
        } catch let error {
            fatalError("Pipeline State Error: \(error)")
        }
    }
}

extension Renderer: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let pipeline = pipelineState,
            let depthState = depthStencilState
        else { return }

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor
        else { return }

        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = view.clearColor
        descriptor.depthAttachment.storeAction = .store
        descriptor.depthAttachment.clearDepth = 1.0

        frame.update()
        // frame.info()

        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }

        encoder.setRenderPipelineState(pipeline)
        encoder.setDepthStencilState(depthState)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        encoder.setDepthClipMode(.clip)

        // encoder.setFrontFacing(.counterClockwise)
        // encoder.setCullMode(.back)
        //encoder.setTriangleFillMode(.lines)

        self.encoder = encoder

        guard let world = self.world else { return }

        world.runUpdate(frame: frame)

        encoder.endEncoding()
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }

        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let w = size.width
        let h = size.height
        let aspect = Float(w / h)

        self.aspect = aspect

        print("width: \(w) - height: \(h)")
        print("aspect: \(aspect)")
    }
}
