#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
};

struct VertexOut {
    float4 position [[position]];
};

typedef struct {
    float4x4 mvp;
} Uniforms;

vertex VertexOut default_vertex(VertexIn in [[stage_in]], constant Uniforms& uniforms [[buffer(1)]] ) {
    VertexOut out;
    out.position = float4(in.position, 1.0);
    return out;
}

fragment half4 default_fragment() {
  return half4(1.0);
}


fragment half4 red_fragment() {
  return half4(1.0, 0.0, 0.0, 1.0);
}
