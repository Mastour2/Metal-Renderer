#include <metal_stdlib>
using namespace metal;

struct FrameUniforms {
  float4x4 view;
  float4x4 projection;
};

struct EntityUniforms {
  float4x4 model;
};

struct VertexIn {
  float3 position [[attribute(0)]];
  float3 color [[attribute(1)]];
};

struct VertexOut {
  float4 position [[position]];
  float4 color;
};

vertex VertexOut vertex_main(
    const VertexIn in [[stage_in]],
    constant FrameUniforms &frame [[buffer(1)]],
    constant EntityUniforms &entity [[buffer(2)]]
) {
  VertexOut out;

  out.position = frame.projection * frame.view * entity.model * float4(in.position, 1);
  out.color = float4(in.color, 1);

  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
  return in.color;
}
