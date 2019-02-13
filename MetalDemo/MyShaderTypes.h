//
//  MyShaderTypes.h
//  MetalDemo
//
//  Created by HW on 2019/2/13.
//  Copyright © 2019 meitu. All rights reserved.
//

#ifndef MyShaderTypes_h
#define MyShaderTypes_h

#include <simd/simd.h>


/**
 SIMD 库为图形处理定义了一系列常用数据类型，比如向量，矩阵，以及它们对应的一些便捷操作。
 SIMD 是独立于 Metal 和 MetalKit 的，但是为了便捷以及性能优势，强烈建议在 Metal 中使用 SIMD。
 它定义的数据类型，在工程中（.swift、.m）中可以直接使用，在着色器（.metal）中也可以直接使用，保证了类型、内存分布的一致。
 */
typedef struct
{
    vector_float2 position;
    vector_float4 color;
} MyVertex;


typedef enum MyVertexInputIndex
{
    MyVertexInputIndexVertices = 0,
    MyVertexInputIndexCount    = 1,
} MyVertexInputIndex;

#endif /* MyShaderTypes_h */
