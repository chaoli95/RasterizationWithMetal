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
    VertexInputIndexViewportSize = 1,
    VertexInputIndexUniform = 2,
} VertexInputIndex;

typedef struct {
    vector_float4 position;
    vector_float4 color;
    vector_float4 normal;
} Vertex;

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 orthodoxMatrix;
} Uniform;

#endif /* ShaderTypes_h */
