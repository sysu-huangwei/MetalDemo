//
//  Shaders.metal
//  MetalDemo
//
//  Created by HW on 2019/2/13.
//  Copyright © 2019 meitu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "MyShaderTypes.h"

typedef struct
{
    float4 position [[position]];
    float4 color;
} RasterizerData;


/**
 顶点着色器
 */
vertex RasterizerData vertexShader(constant MyVertex *vertices [[buffer(MyVertexInputIndexVertices)]],
                                   uint vid [[vertex_id]]) {
    RasterizerData outVertex;
    
    outVertex.position = vector_float4(vertices[vid].position, 0.0, 1.0);
    outVertex.color = vertices[vid].color;
    
    return outVertex;
}


/**
 片段着色器
 */
fragment float4 fragmentShader(RasterizerData inVertex [[stage_in]]) {
    return inVertex.color;
}
