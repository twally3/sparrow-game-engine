#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

struct GuiRasterizerData {
    float4 position [[ position ]];
    float2 textureCoordinate;
};

vertex GuiRasterizerData gui_vertex_shader(constant float2 *vertices [[ buffer(0) ]],
                                           constant ModelConstants &modelConstants [[ buffer(1) ]],
                                           uint vertexId [[ vertex_id ]]) {
    GuiRasterizerData rd;
    float2 pos = vertices[vertexId];
    
    rd.position = modelConstants.modelMatrix * float4(pos, 0, 1);
    rd.textureCoordinate = float2((pos.x + 1.0) / 2.0, 1 - (pos.y + 1.0) / 2.0);
    
    return rd;
}

fragment half4 gui_fragment_shader(GuiRasterizerData rd [[ stage_in ]],
                                   sampler sampler2d [[ sampler(0) ]],
                                   texture2d<float> texture [[ texture(0) ]]) {
    float4 colour = texture.sample(sampler2d, rd.textureCoordinate);
    return half4(colour.r, colour.g, colour.b, colour.a);
}
