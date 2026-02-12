#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4x4 mvp;
    float4x4 modelMatrix;
    float3 cameraPosition;
} Camera;


typedef struct {
    float3 tint;
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
    float3 light_direction = normalize(float3(0.0, 0.0, -5));
    
    float3 light_color = float3(0.9, 0.8, 0.8);
    float3 specular_color = float3(1.0, 1.0, 1.0);
    
    // 1. Ambient
    float ambient_strength = 0.02;
    float3 ambient = ambient_strength * material.tint.rgb;
    
    // 2. Diffuse
    float intensity = max(0.0, dot(normal, light_direction));
    float3 diffuse = intensity * light_color;
    
    // 3. Specular
    float specular_strength = 0.25;
    float shininess = 256.0;
    
    // 4. Reflect
    float3 view_direction = normalize(camera.cameraPosition - in.worldPosition);
    float3 reflect_direction = reflect(-light_direction, normal);
    
    float spec = pow(max(0.0, dot(view_direction, reflect_direction)), shininess);
    float3 specular = specular_strength * spec * specular_color;
    
    float3 finalColor = ambient + diffuse + specular;
    
    return half4(half3(finalColor), 1.0);
}
