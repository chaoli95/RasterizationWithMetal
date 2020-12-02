//
//  Shaders.metal
//  RasterizationWithMetal
//
//  Created by Chao Li on 11/30/20.
//

#include <metal_stdlib>

using namespace metal;

#include "ShaderTypes.h"

struct RasterizerData
{
    float4 position [[position]];
    float4 color [[center_perspective]];
};

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(VertexInputIndexViewportSize)]],
             constant Uniform *uniform [[buffer(VertexInputIndexUniform)]])
{
    RasterizerData out;
    
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    out.position = vertices[vertexID].position;
//    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
//    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
//    out.position.z = vertices[vertexID].position.z;
//    out.position = uniform->orthodoxMatrix * uniform->projectionMatrix * out.position;
    
    out.color = vertices[vertexID].color;
    
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    return in.color;
}
