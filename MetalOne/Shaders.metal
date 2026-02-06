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
} Transform;


typedef struct {
    half3 tint;
} Material;


vertex VertexOut default_vertex(VertexIn in [[stage_in]], constant Transform& transform [[buffer(1)]] ) {
    VertexOut out;
    out.position = float4(in.position, 1.0);
    return out;
}


fragment half4 default_fragment(constant Material& material [[buffer(2)]]) {
    Material mat;
    mat.tint = half3(1.0);
    
  return half4(mat.tint, 1.0);
}


fragment half4 red_fragment() {
  return half4(1.0, 0.0, 0.0, 1.0);
}
