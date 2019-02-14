//
//  Shaders.metal
//  MetalDemo
//
//  Created by HW on 2019/2/13.
//  Copyright © 2019 meitu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


/**
 顶点着色器
 */
vertex float4 vertexShader(constant float2 *vertices,
                                   uint vid [[vertex_id]]) {
    return vector_float4(vertices[vid], 0.0, 1.0);
}


/**
 片段着色器
 */
fragment float4 fragmentShader(float4 inVertex [[stage_in]]) {
    return vector_float4(0.9, 0.5, 0.1, 1.0);
}
