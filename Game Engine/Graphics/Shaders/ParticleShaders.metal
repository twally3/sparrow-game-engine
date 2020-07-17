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

//vertex ParticleRasterizerData particle_vertex_shader(const VertexIn vIn [[ stage_in ]],
//                                                     constant SceneConstants &sceneConstants [[ buffer(1) ]],
//                                                     constant ModelConstants &modelConstants [[ buffer(2) ]],
//                                                     constant float4 &texOffset [[ buffer(3) ]],
//                                                     constant float &numberOfRows [[ buffer(4) ]],
//                                                     constant float &blendFactor [[ buffer(5) ]]) {
//    ParticleRasterizerData rd;
//
//    float4 worldPosition = modelConstants.modelMatrix * float4(vIn.position, 1);
//
//    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
//
//    float2 textureCoords = vIn.textureCoordinate;
//    textureCoords.y = 1.0 - textureCoords.y;
//    textureCoords /= numberOfRows;
//
//    rd.texCoords1 = textureCoords + texOffset.xy;
//    rd.texCoords2 =  textureCoords + texOffset.zw;
//    rd.blend = blendFactor;
//
//    return rd;
//}

vertex ParticleRasterizerData particle_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                                      constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                                      constant ModelConstants *modelConstants [[ buffer(2) ]],
                                                      constant float4 *offsets [[ buffer(3) ]],
                                                      constant float *blendFactors [[ buffer(4) ]],
                                                      constant float &numberOfRows [[ buffer(5) ]],
                                                      uint instanceId [[ instance_id ]]) {
    ParticleRasterizerData rd;

//    ModelConstants modelConstant = modelConstants[instanceId];
//
//    float4 worldPosition = modelConstant.modelMatrix * float4(vIn.position, 1);
//    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
//    rd.colour = vIn.colour;
//    rd.textureCoordinate = vIn.textureCoordinate;
//    rd.worldPosition = worldPosition.xyz;
//    rd.surfaceNormal = (modelConstant.modelMatrix * float4(vIn.normal, 1.0)).xyz;
//    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;

    ModelConstants modelConstant = modelConstants[instanceId];

    float4 worldPosition = modelConstant.modelMatrix * float4(vIn.position, 1);
    
    float2 textureCoords = vIn.textureCoordinate;
    textureCoords.y = 1.0 - textureCoords.y;
    textureCoords /= numberOfRows;

    rd.texCoords1 = textureCoords + offsets[instanceId].xy;
    rd.texCoords2 =  textureCoords + offsets[instanceId].zw;

    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
//    rd.texCoords1 = vIn.textureCoordinate;
//    rd.texCoords2 = vIn.textureCoordinate;
    rd.blend = blendFactors[instanceId];

    return rd;
}

fragment half4 particle_fragment_shader(ParticleRasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]],
                                     constant int &lightCount [[ buffer(2) ]],
                                     constant LightData *lightDatas [[ buffer(3)]],
                                     sampler sampler2d [[ sampler(0) ]],
                                     texture2d<float> baseColourMap [[ texture(0) ]],
                                     texture2d<float> baseNormalMap [[ texture(1) ]]) {
    
    
    float4 colour1 = baseColourMap.sample(sampler2d, rd.texCoords1);
    float4 colour2 = baseColourMap.sample(sampler2d, rd.texCoords2);
    
    float4 colour = mix(colour1, colour2, rd.blend);
    
    return half4(colour.r, colour.g, colour.b, colour.a);
}
