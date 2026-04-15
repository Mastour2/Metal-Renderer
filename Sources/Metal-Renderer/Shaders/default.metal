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
