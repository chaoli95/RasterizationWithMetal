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
    float2 textureCoordinate [[center_perspective]];
};

vertex RasterizerData
wireFrameShaderTriangle(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
             constant Uniform *uniform [[buffer(VertexInputIndexUniform)]])
{
    RasterizerData out;
    out.position = uniform->cameraMatrix * uniform->modelMatrix * vertices[vertexID].position;
    out.color = float4(1, 1, 1, 1);
    return out;
}

vertex RasterizerData
wireFrameShaderBackLine(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
                        constant Uniform *uniform [[buffer(VertexInputIndexUniform)]]) {
    RasterizerData out;
    out.position = uniform->cameraMatrix * uniform->modelMatrix * vertices[vertexID].position;
    out.position[2] -= 0.001 * out.position[3];
    out.color = float4(0, 0.5, 0.5, 1);
    return out;
}

vertex RasterizerData
wireFrameShaderFrontLine(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
                        constant Uniform *uniform [[buffer(VertexInputIndexUniform)]]) {
    RasterizerData out;
    out.position = uniform->cameraMatrix * uniform->modelMatrix * vertices[vertexID].position;
    out.position[2] -= 0.001 * out.position[3];
    out.color = float4(0, 0, 0, 1);
    return out;
}

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
             constant Uniform *uniform [[buffer(VertexInputIndexUniform)]])
{
    RasterizerData out;
//    out.position = uniform->cameraMatrix * uniform->modelMatrix * vertices[vertexID].position;
    float4 position = uniform->modelMatrix * vertices[vertexID].position;
    float color = uniform->ambient;
    float4 v = normalize(float4(uniform->cameraPosition, 1) - position);
    float4 n = normalize(uniform->modelMatrixInverseTranspose * vertices[vertexID].normal);
    
    assert(dot(n, v) >= 0);
    if (dot(n, v) < 0) {
        n = -n;
    }
    assert(dot(n, v) >= 0);
    float4 d = float4(uniform->lightPosition, 1) - position;
    float4 l = normalize(d);
    float diffuse = uniform->diffuse * max(dot(l, n), 0.0);
    float4 h = normalize(l + v);
    float specular = uniform->specular * pow(max(dot(h, n), 0.0), uniform->specular_exponent);
    color += (diffuse + specular) * uniform->lightIntensity / length_squared(d);
    out.color = float4(min(color, 1.0));
    out.position = uniform->cameraMatrix * position;
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    return in.color;
}

vertex RasterizerData
textureShaderTriangle(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
             constant Uniform *uniform [[buffer(VertexInputIndexUniform)]])
{
    RasterizerData out;
    out.position = uniform->cameraMatrix * uniform->modelMatrix * vertices[vertexID].position;
    out.textureCoordinate = vertices[vertexID].textureCoordinate;
    return out;
}

fragment float4 textureFragmentShader(RasterizerData in [[stage_in]],
                                      texture2d<half> colorTexture [[ texture(TextureIndexBaseColor) ]])
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    return float4(colorSample);
}
