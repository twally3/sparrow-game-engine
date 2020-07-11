#include <metal_stdlib>
#include "Lighting.metal"
#include "Shared.metal"
using namespace metal;

struct ParticleRasterizerData {
    float4 position [[ position ]];
    float2 texCoords1;
    float2 texCoords2;
    float blend;
};

vertex ParticleRasterizerData particle_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                                     constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                                     constant ModelConstants &modelConstants [[ buffer(2) ]],
                                                     constant float2 &texOffset1 [[ buffer(3) ]],
                                                     constant float2 &texOffset2 [[ buffer(4) ]],
                                                     constant float2 &texCoordInfo [[ buffer(5) ]]) {
    ParticleRasterizerData rd;
    
    float4 worldPosition = modelConstants.modelMatrix * float4(vIn.position, 1);
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    
//    float2 textureCoords = vIn.position.xy + float2(0.5, 0.5);
    float2 textureCoords = vIn.textureCoordinate;// + float2(0.5, 0.5);
    textureCoords.y = 1.0 - textureCoords.y;
    textureCoords /= texCoordInfo.x;
    
    rd.texCoords1 = textureCoords + texOffset1;
    rd.texCoords2 =  textureCoords + texOffset2;
    rd.blend = texCoordInfo.y;
    
//    rd.texCoords1 = vIn.textureCoordinate;
//    rd.texCoords2 = vIn.textureCoordinate;
//    rd.blend = 0.5;
    
//    rd.colour = vIn.colour;
//    rd.textureCoordinate = vIn.textureCoordinate;
//    rd.worldPosition = worldPosition.xyz;
//    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
//
//    rd.surfaceNormal = (modelConstants.modelMatrix * float4(vIn.normal, 0.0)).xyz;
//    rd.surfaceTangent = (modelConstants.modelMatrix * float4(vIn.tangent, 0.0)).xyz;
//    rd.surfaceBitangent = (modelConstants.modelMatrix * float4(vIn.bitangent, 0.0)).xyz;
    
    return rd;
}

fragment half4 particle_fragment_shader(ParticleRasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]],
                                     constant int &lightCount [[ buffer(2) ]],
                                     constant LightData *lightDatas [[ buffer(3)]],
                                     sampler sampler2d [[ sampler(0) ]],
                                     texture2d<float> baseColourMap [[ texture(0) ]],
                                     texture2d<float> baseNormalMap [[ texture(1) ]]) {
    
//    float2 textCoord = rd.textureCoordinate;
//
//    float4 colour = material.colour;
//    if (!is_null_texture(baseColourMap)) {
//        colour = baseColourMap.sample(sampler2d, textCoord);
//    }
//
//    return half4(1, 1, 1, 1);
    
    float4 colour1 = baseColourMap.sample(sampler2d, rd.texCoords1);
    float4 colour2 = baseColourMap.sample(sampler2d, rd.texCoords2);
    
    float4 colour = mix(colour1, colour2, rd.blend);
    
    return half4(colour.r, colour.g, colour.b, colour.a);
}
