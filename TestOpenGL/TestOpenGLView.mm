//
//  TestOpenGLView.m
//  TestOpenGL
//
//  Created by wolf on 16/8/15.
//  Copyright © 2016年 wolf. All rights reserved.
//

#import <OpenGL/glu.h>
#import "TestOpenGLView.h"

// 全局定义
#define BUFFER_OFFSET(bytes) ((GLubyte*) NULL + (bytes))

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

// 

@implementation TestOpenGLView

#pragma mark Init

// init
- (id) initWithFrame:(NSRect)frameRect {
    
    // 创建帮助对象
    _OGHelper = [[AVOpenGLHelper alloc] init];
    
    // 初始化pixelFormat
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFAAccelerated,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize,	24,
        NSOpenGLPFAAlphaSize,	8,
        NSOpenGLPFADepthSize, 24,
        0
    };
    
    NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    
    // 创建view
    if ((self = [super initWithFrame:frameRect pixelFormat:pf])) {
        [self initOpenGL];
    }
    
    return self;
}

- (void) dealloc {
    // 先不管，demo
    
}

// 初始化OpenGL
- (void)initOpenGL {
    // 设置当前context
    [[self openGLContext] makeCurrentContext];
    
    // 使用2D类型纹理
    glEnable(GL_TEXTURE_2D);
    
    // 开启顶点和纹理
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // 创建纹理
    CGLLockContext([[self openGLContext] CGLContextObj]);
    _backGroudTexture = [_OGHelper createTextureFromPic:@"bkg3.jpeg"];
    CGLUnlockContext([[self openGLContext] CGLContextObj]);
    
    // 创建着色器和VBO
    _testVBO = YES;
    if (_testVBO) {
        [_OGHelper createShaders:@"SimpleVertex" fShader:@"SimpleFragment"];
        
        // VBO
        GLuint vertexBuffer;
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
        
        GLuint indexBuffer;
        glGenBuffers(1, &indexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    }
}


#pragma mark Draw

- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
    
    // 锁定当前context， 并设置为当前context
    CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    [[self openGLContext] makeCurrentContext];
    
    // 清理颜色并用默认色填充，清理深度缓存
    //    glClearColor(0, 0, 0, 0);
    //    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClearColor(1, 1, 1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 画个背景
    [self drawBackGround];
    
    [[self openGLContext] flushBuffer];
    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

-(void)drawBackGround
{
    // 顶点数组
    float step = 0.5f;
    static const GLfloat squareVertices[] = {
        -1.0f * step,   -1.0f * step,   0.0f,
        1.0f * step,    -1.0f * step,   0.0f,
        1.0f * step,    1.0f * step,    0.0f,
        -1.0f * step,   1.0f * step,    0.0f
    };
    
    // 纹理映射数组(需要和上面一一对应)
    static const GLfloat texCoords[] = {
        0.0f, 0.0f,     // left lower
        1.0f, 0.0f,     // right lower
        1.0f, 1.0f,     // left upper
        0.0f, 1.0f      // right upper
    };
    
    
    //    glEnable( GL_BLEND );				    // enable blending
    //    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );    // blend func for non premultiplied images
    
    // ------------------------------------------------
    if (!_testVBO) {
        // 1.普通顶点
        glVertexPointer(3, GL_FLOAT, 0, squareVertices);
        
        // 绑定纹理并设置纹理映射
        glBindTexture(GL_TEXTURE_2D, _backGroudTexture);
        glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
        
        // 调用渲染
        glDrawArrays(GL_POLYGON, 0, 4);
        
    }
    // ------------------------------------------------
    
    else {
        // 2.VBO
        
        // 启动着色器
        glVertexAttribPointer(_OGHelper.positionSlot, 3, GL_FLOAT, GL_FALSE,
                              sizeof(Vertices), 0);
        glVertexAttribPointer(_OGHelper.colorSlot, 4, GL_FLOAT, GL_FALSE,
                              sizeof(Vertices), (GLvoid*) (sizeof(float) *3));
        
        //        glInterleavedArrays(GL_C4UB_V3F, 0, Vertices);
        
        glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
        //        glDrawElements(GL_QUADS, 1, GL_UNSIGNED_BYTE, Indices);
    }
    // ------------------------------------------------
}

@end
