#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4x4 mvp;
    float4x4 modelMatrix;
    float3 cameraPosition;
} Camera;


typedef struct {
    float3 tint;
    float specular_strength;
    float shininess;
} Material;


struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldNormal;
    float3 worldPosition;
};


vertex VertexOut default_vertex(VertexIn in [[stage_in]], constant Camera& camera [[buffer(2)]] ) {
    VertexOut out;
    
    out.position = camera.mvp * float4(in.position, 1.0);
    out.worldNormal = (camera.modelMatrix * float4(in.normal, 0.0)).xyz;
    out.worldPosition = (camera.modelMatrix * float4(in.position, 1.0)).xyz;
    
    return out;
}


fragment half4 default_fragment(
                                VertexOut in [[stage_in]],
                                constant Material& material [[buffer(1)]],
                                constant Camera& camera [[buffer(2)]]
                                ) {
    float3 normal = normalize(in.worldNormal);
    float3 view_direction = normalize(camera.cameraPosition - in.worldPosition);
    
    float3 light_pos = float3(0.0, 0.0, -5.0);
    float3 light_dir = normalize(light_pos - in.worldPosition);
    
    float3 light_color = float3(0.9, 0.85, 0.7);
    float3 ambient_color = float3(0.1, 0.1, 0.1);
    
    // 1. Ambient
    float ambient_strength = 0.05;
    float3 ambient = ambient_strength * material.tint.rgb;
    
    // 2. Diffuse
    float intensity = max(0.0, dot(normal, light_dir));
    float3 diffuse = intensity * light_color * material.tint.rgb;;
    
    // 3. Specular
    float3 half_dir = normalize(light_dir + view_direction);
    float spec = pow(max(0.0, dot(normal, half_dir)), material.shininess);
    float3 specular = spec * material.specular_strength * light_color;
    
        
    float3 finalColor = ambient_color + ambient + diffuse + specular;
    
    finalColor = pow(finalColor, float3(1.0/2.2));
    
    return half4(half3(finalColor), 1.0);
}

fragment half4 frag_normal_debug(VertexOut in [[stage_in]]) {
    float3 normal = normalize(in.worldNormal);
    return half4(half3(normal * 0.5 + 0.5), 1.0);
}
