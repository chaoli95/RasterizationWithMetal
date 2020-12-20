//
//  ShaderTypes.h
//  RasterizationWithMetal
//
//  Created by Chao Li on 11/30/20.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef enum VertexInputIndex {
    VertexInputIndexVertices     = 0,
    VertexInputIndexUniform = 1,
} VertexInputIndex;

typedef struct {
    vector_float4 position;
    vector_float4 normal;
} Vertex;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 modelMatrixInverseTranspose;
    matrix_float4x4 cameraMatrix;
    vector_float3 cameraPosition;
    vector_float3 lightPosition;
    float lightIntensity;
    float ambient;
    float diffuse;
    float specular;
    float specular_exponent;
} Uniform;

#endif /* ShaderTypes_h */
