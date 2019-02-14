//
//  MyMetalView.m
//  MetalDemo
//
//  Created by HW on 2019/2/13.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "MyMetalView.h"
#import <Metal/Metal.h>
#include <simd/simd.h>

@interface MyMetalView ()

/**
 一个 MTLDevice 对象代表一个可以执行指令的 GPU。
 MTLDevice 协议提供了查询设备功能、创建 Metal 其他对象等方法。
 */
@property (strong, nonatomic) id <MTLDevice> device;



/**
 一个管理队列，由 Device 创建。它持有一串需要被执行的 Command Buffer， Command Buffer 由 Command Queue 创建，它又包含多个特定的 Command Encoder 。
 */
@property (strong, nonatomic) id <MTLCommandQueue> commandQueue;



/**
 MTLRenderPipelineState 对渲染管线的描述。它的具体配置需要依赖 MTLRenderPipelineDescriptor 对象来完成。
 */
@property (strong, nonatomic) id <MTLRenderPipelineState> pipelineState;


@end

@implementation MyMetalView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        if (_device) {
            _commandQueue = [_device newCommandQueue];
            /**
             Metal着色器文件 *.metal 在工程编译的时候就被编译成 .metallib 文件，打包进App中
             MTLLibrary 对象是对 编译后的metal文件 metallib 的抽象。通过 newDefaultLibrary 方法返回工程中默认的 library
             */
            id <MTLLibrary> library = [_device newDefaultLibrary];
            id <MTLFunction> vertexFunction = [library newFunctionWithName:@"vertexShader"];
            id <MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
            // 对渲染管线的描述，用这个描述来创建MTLRenderPipelineState
            MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
            pipelineDescriptor.vertexFunction = vertexFunction;
            pipelineDescriptor.fragmentFunction = fragmentFunction;
            pipelineDescriptor.colorAttachments[0].pixelFormat = [[self metalLayer] pixelFormat];
            _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:nil];
        }
    }
    return self;
}


/**
 把原先 UIView 对应的 CALayer 改成 CAMetalLayer
 */
+ (Class) layerClass {
    return [CAMetalLayer class];
}



/**
 重写 didMoveToWindow，当 view 出现的时候，会被调用一次
 */
- (void) didMoveToWindow {
    [super didMoveToWindow];
    [self render];
}


- (CAMetalLayer*) metalLayer {
    return (CAMetalLayer*)self.layer;
}


- (void) render {
    
    /**
     CAMetalLayer: 负责渲染，继承自CALayer，由Metal进行渲染
     CAMetalDrawable 协议是 Core Animation 中定义的，它表示某个对象是可被显示的资源。它继承自 MTLDrawable，并扩展了一个实现 MTLTexture 协议的 texture 对象，这个 texture 用来表示渲染指令执行的目标。即之后的渲染操作，会画在这个 texture 上。
     */
    id <CAMetalDrawable> drawable = [[self metalLayer] nextDrawable];
    
    
    if (drawable) {
        
        /**
         MTLRenderPassDescriptor 是一个渲染过程的描述，包含了一组附件（attachment）的集合。
         所谓的 attachment，可以简单理解成渲染操作要应用到的渲染目标，比如我们要渲染到的纹理。
         常见的有：
         colorAttachments，用于写入颜色数据
         depthAttachment，用于写入深度信息
         stencilAttachment，允许我们基于一些条件丢弃指定片段
         */
        MTLRenderPassDescriptor* renderPassDescripor = [[MTLRenderPassDescriptor alloc] init];
        
        
        /**
         MTLRenderPassDescriptor 里面的 colorAttachments，支持多达 4 个 用来存储颜色像素数据的 attachment。 在 2D 图像处理时，我们一般只会关联一个。即 colorAttachments[0]。
         texture：关联的纹理，即渲染目标。必须设置，不然内容不知道要渲染到哪里。不设置会报错：failed assertion `No rendertargets set in RenderPassDescriptor.'
         loadAction：决定前一次 texture 的内容需要清除、还是保留
         storeAction：决定这次渲染的内容需要存储、还是丢弃
         clearColor：当 loadAction 是 MTLLoadActionClear 时，则会使用对应的颜色来覆盖当前 texture（用某一色值逐像素写入）
         */
        renderPassDescripor.colorAttachments[0].clearColor = MTLClearColorMake(0.48, 0.74, 0.92, 1);
        renderPassDescripor.colorAttachments[0].texture = drawable.texture;
        renderPassDescripor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescripor.colorAttachments[0].storeAction = MTLStoreActionStore;
        
        /**
         Command Encoder 由 Command Buffer 创建，MTLCommandBuffer 协议支持以下几种 Encoder 类型，它们被用于编码不同的 GPU 任务：
         MTLRenderCommandEncoder ，该类型的 Encoder 为一个 render pass 编码3D图形渲染指令。
         MTLComputeCommandEncoder ，该类型的 Encoder 编码并行数据计算任务。
         MTLBlitCommandEncoder ，该类型的 Encoder 支持在 buffer 和 texture 之间进行简单的拷贝操作，以及类似 mipmap 生成操作。
         MTLParallelRenderCommandEncoder ，该类型的 Encoder 为并行图形渲染任务编码指令。
         */
        id <MTLCommandBuffer> commandBuffer = _commandQueue.commandBuffer;
        id <MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescripor];
        
        
        //把渲染管线和commandEncoder关联起来，表示commandEncoder的指令要作用到哪个渲染管线上
        [commandEncoder setRenderPipelineState:_pipelineState];
        
        //三角形顶点
        simd_float2 vertices[3] = {
            vector2(0.5f, -0.5f),
            vector2(-0.5f, -0.5f),
            vector2(0.0f, 0.5f)
        };
        
        //传递顶点数据
        [commandEncoder setVertexBytes:vertices length:sizeof(simd_float2) * 3 atIndex:0];
        //画三角形
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        
        
        //当当前 Command Encoder 配置完毕，调用 endEncoding
        [commandEncoder endEncoding];
        //把渲染结果，显示到屏幕上(确保渲染完毕后才画到屏幕上)
        [commandBuffer presentDrawable:drawable];
        //一旦所有的编码工作结束， Command Buffer 执行 commit() 操作
        [commandBuffer commit];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
