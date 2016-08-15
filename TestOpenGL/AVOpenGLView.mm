//
//  AVOpenGLView.m
//  TestOpenGL
//
//  Created by wolf on 16/7/23.
//  Copyright © 2016年 wolf. All rights reserved.
//

#import <OpenGL/glu.h>
#import "AVOpenGLView.h"

@implementation AVOpenGLView


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


#pragma mark C code

// c代码
unsigned char * readYUV(char *path)
{
    FILE *fp;
    unsigned char * buffer;
    long size = 1280 * 720 * 3 / 2;
    
    if((fp=fopen(path,"rb"))==NULL)
    {
        printf("cant open the file");
        exit(0);
    }
    
    buffer = new unsigned char[size];
    memset(buffer,'\0',size);
    fread(buffer,size,1,fp);
    fclose(fp);
    return buffer;
}

GLuint texYId;
GLuint texUId;
GLuint texVId;


void loadYUV(unsigned char* buffer){
    int width ;
    int height ;
    
    width = 640;
    height = 480;
    
//    unsigned char *buffer = NULL;
//    buffer = readYUV("1.yuv");
    
    glGenTextures ( 1, &texYId );
    glBindTexture ( GL_TEXTURE_2D, texYId );
    glTexImage2D ( GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, buffer );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    glGenTextures ( 1, &texUId );
    glBindTexture ( GL_TEXTURE_2D, texUId );
    glTexImage2D ( GL_TEXTURE_2D, 0, GL_LUMINANCE, width / 2, height / 2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, buffer + width * height);
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
    glGenTextures ( 1, &texVId );
    glBindTexture ( GL_TEXTURE_2D, texVId );
    glTexImage2D ( GL_TEXTURE_2D, 0, GL_LUMINANCE, width / 2, height / 2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, buffer + width * height * 5 / 4 );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    
}

// 输出日志
void MyProc(GLenum source, GLenum type, GLuint id, GLenum serverity, GLsizei length,
            
            const GLchar *message, const GLvoid *userParam)

{
    NSLog(@"123123123123");
}

#pragma mark OpenGL
// oc 代码

// 初始化OpenGL
- (void)initOpenGL {
    
    // 设置当前context
    [[self openGLContext] makeCurrentContext];
    
    
    // ------- 设置 -------
    
    // Synchronize buffer swaps with vertical refresh rate
    // 将刷新率和双缓存交互率同步？？
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    glEnable(GL_TEXTURE_2D);
    
    // --------- 纹理-->帧缓冲 ---------
    
    // 选择放大/缩小过滤的算法
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    // S方向上的贴图模式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    // --------- end  ---------
    
    glEnable(GL_DEPTH_TEST);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // ------- 纹理处理 -------
    
    // 背景图片纹理
    glGenTextures(1, &_backGroudTexture);
    [self initBackGroudTexture:@"bkg3.jpeg"];
    
    // 背景颜色纹理
    glGenTextures(1, &_colorBackGroudTexture);
    [self initColorBackGroundTexture];
    
    // ------- 本地YUV -------
    char* yuvPath = "/Users/wolf/Documents/SelfProj/TestOpenGL/TestOpenGL/jpgimage1_image_640_480.yuv";
    unsigned char* testBuf = readYUV(yuvPath);
    loadYUV(testBuf);
    
    _testVBO = NO;
    if (_testVBO) {
        // ------- 着色器 -------
        [self compileShaders];
        
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
    
    // ------- DEBUG -------
}

#pragma mar Init Texture
-(BOOL)initColorBackGroundTexture
{
    const unsigned char backColorData[4][4]=
    {
        {122, 12, 3, 255},
        {122, 12, 3, 255},
        {122, 12, 3, 255},
        {122, 12, 3, 255},
    };
    CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    // Bind the rectange texture
    glBindTexture(GL_TEXTURE_2D, _colorBackGroudTexture);
    
    // Set a CACHED or SHARED storage hint for requesting VRAM or AGP texturing respectively
    // GL_STORAGE_PRIVATE_APPLE is the default and specifies normal texturing path
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_STORAGE_HINT_APPLE , GL_STORAGE_CACHED_APPLE);
    
    // Eliminate a data copy by the OpenGL framework using the Apple client storage extension
    glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
    
    // Rectangle textures has its limitations compared to using POT textures, for example,
    // Rectangle textures can't use mipmap filtering
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // Rectangle textures can't use the GL_REPEAT warp mode
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
    
    //    memset(_colorBackGroudData,0,sizeof(_colorBackGroudData));
    memcpy(_colorBackGroudData,backColorData,sizeof(backColorData));
    // OpenGL likes the GL_BGRA + GL_UNSIGNED_INT_8_8_8_8_REV combination
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, COLOR_MAX_WIDTH, COLOR_MAX_HEIGHT, 0,
                 GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, _colorBackGroudData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    return YES;
}

-(BOOL)initBackGroudTexture:(NSString*)name
{
    
    NSUInteger				width, height;
    NSURL					*url = nil;
    CGImageSourceRef		src = nil;
    CGImageRef				image = nil;
    CGContextRef			context = nil;
    CGColorSpaceRef			colorSpace = nil;
    
    NSArray*				ns = [name componentsSeparatedByString:@"."];
    
    url = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:[ns objectAtIndex:0] ofType:[ns objectAtIndex:1]]];
    src = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    
    if (!src) {
        NSLog(@"No image");
        return NO;
    }
    
    image = CGImageSourceCreateImageAtIndex(src, 0, NULL);
    CFRelease(src);
    
    width = CGImageGetWidth(image);
    height = CGImageGetHeight(image);
    
    backGroudWidth = width;
    backGroudHeight = height;
    
    //初始化背景的坐标
    [self initBackGroundFrame];
    
    CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    //    _backGroudData = _textureData;//(unsigned char*)calloc(width * height * RGBA_SIZE, sizeof(GLubyte));
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(_textureData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    CGColorSpaceRelease(colorSpace);
    
    // Core Graphics referential is upside-down compared to OpenGL referential
    // Flip the Core Graphics context here
    // An alternative is to use flipped OpenGL texture coordinates when drawing textures
    CGContextTranslateCTM(context, 0.0, 0.0);
    CGContextScaleCTM(context, 1.0, 1.0);
    
    // Set the blend mode to copy before drawing since the previous contents of memory aren't used. This avoids unnecessary blending.
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    CGContextRelease(context);
    CGImageRelease(image);
    
    
    
    
    // Bind the rectange texture
    glBindTexture(GL_TEXTURE_2D, _backGroudTexture);
    
    // Set a CACHED or SHARED storage hint for requesting VRAM or AGP texturing respectively
    // GL_STORAGE_PRIVATE_APPLE is the default and specifies normal texturing path (可以关)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_STORAGE_HINT_APPLE , GL_STORAGE_CACHED_APPLE);
    
    // Eliminate a data copy by the OpenGL framework using the Apple client storage extension (可以关)
    glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
    
    // Rectangle textures has its limitations compared to using POT textures, for example,
    // Rectangle textures can't use mipmap filtering
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // Rectangle textures can't use the GL_REPEAT warp mode (可以关)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, 0); // 可以关
    
    //    memset(backGroudData,0,sizeof(backGroudData));
    // OpenGL likes the GL_BGRA + GL_UNSIGNED_INT_8_8_8_8_REV combination
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, backGroudWidth, backGroudHeight, 0,
                 GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, _textureData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    return YES;
}

-(void)initBackGroundFrame
{
    backGroudFrame.pt[0][0] =  1;
    backGroudFrame.pt[0][1] = -1;
    backGroudFrame.pt[0][2] = -2;
    
    backGroudFrame.pt[1][0] = 1;
    backGroudFrame.pt[1][1] = 1;
    backGroudFrame.pt[1][2] = -2;
    
    backGroudFrame.pt[2][0] = -1;
    backGroudFrame.pt[2][1] = 1;
    backGroudFrame.pt[2][2] = -2;
    
    backGroudFrame.pt[3][0] = -1;
    backGroudFrame.pt[3][1] = -1;
    backGroudFrame.pt[3][2] = -2;
    
    backGroudFrame.pttexture[0][0] = backGroudWidth;
    backGroudFrame.pttexture[0][1] = backGroudHeight;
    
    backGroudFrame.pttexture[1][0] = backGroudWidth;
    backGroudFrame.pttexture[1][1] = 0;
    
    backGroudFrame.pttexture[2][0] = 0;
    backGroudFrame.pttexture[2][1] = 0;
    
    backGroudFrame.pttexture[3][0] = 0;
    backGroudFrame.pttexture[3][1] = backGroudHeight;
    
    backGroudFrame.ishide = false;
    backGroudFrame.isvalid = true;
    backGroudFrame.islarge = true;
}

- (void)dealloc {
    
    if (_myDisplayLink) {
        
        CVDisplayLinkStop(_myDisplayLink);
        
        // Release the display link
        CVDisplayLinkRelease(_myDisplayLink);
        
        _myDisplayLink = nil;
    }
}

#pragma mark Init shader
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
//    NSString *extName = (shaderName);
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"vsh"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}


#pragma mark Draw
-(void)drawFrameBackGround {
    GLfloat vertices[4][3];
    GLfloat texcoords[4][2];
    glDisable( GL_BLEND );
    
    // 纹理属性
    vFrame tf;
    
    // 顶点
    float vetexX = 0.5;
    tf.pt[0][0] = vetexX;
    tf.pt[0][1] = vetexX * -1.0;
    tf.pt[0][2] = 0;
    
    tf.pt[1][0] = vetexX;
    tf.pt[1][1] = vetexX;
    tf.pt[1][2] = 0;
    
    tf.pt[2][0] = vetexX * -1.0;
    tf.pt[2][1] = vetexX;
    tf.pt[2][2] = 0;

    tf.pt[3][0] = vetexX * -1.0;
    tf.pt[3][1] = vetexX * -1.0;
    tf.pt[3][2] = 0;
    
    // 纹理顶点
    int textureSizeX = 100;
    tf.pttexture[0][0] = textureSizeX;
    tf.pttexture[0][1] = textureSizeX;
    
    tf.pttexture[1][0] = textureSizeX;
    tf.pttexture[1][1] = 0;
    
    tf.pttexture[2][0] = 0;
    tf.pttexture[2][1] = 0;
    
    tf.pttexture[3][0] = 0;
    tf.pttexture[3][1] = textureSizeX;
    
    for(int i  = 0;i < 4; i++)
    {
        GLfloat x = tf.pt[i][0];
        GLfloat y = tf.pt[i][1];
        GLfloat z = tf.pt[i][2];
        
        GLfloat tx = tf.pttexture[i][0];
        GLfloat ty = tf.pttexture[i][1];
        
        vertices[i][0]  = x;
        vertices[i][1]  = y;
        vertices[i][2]  = z;
        
        texcoords[i][0] = tx;
        texcoords[i][1] = ty;
    }
    
    //    [self bindBackGroundTexture:tf];
    glBindTexture(GL_TEXTURE_2D, _colorBackGroudTexture);
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_QUADS, 0, 4);
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
//        GLuint vboId = 0;
//        glGenBuffers(1,&vboId);
//        glBindBuffer(GL_ARRAY_BUFFER,vboId);
//        glBufferData(GL_ARRAY_BUFFER,sizeof(squareVertices),squareVertices,GL_STREAM_DRAW);
//        glBindBuffer(GL_ARRAY_BUFFER,0);
//        
//        glBindBuffer(GL_ARRAY_BUFFER,vboId);
//        glEnableVertexAttribArray(0);//启用顶点位置属性索引
//        glVertexAttribPointer(0,4,GL_FLOAT,GL_FALSE,0,0);
        
        // 启动着色器
        glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                              sizeof(Vertices), 0);
        glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                              sizeof(Vertices), (GLvoid*) (sizeof(float) *3));
        
//        glInterleavedArrays(GL_C4UB_V3F, 0, Vertices);
        
        glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
//        glDrawElements(GL_QUADS, 1, GL_UNSIGNED_BYTE, Indices);
    }
    // ------------------------------------------------
}

#pragma mark Logic

- (id) initWithFrame:(NSRect)frameRect {
    
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
        [self initDisplayLink];
    }
    
//    [self drawFrameBackGround];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
    
    // Drawing code here.

    // 锁定当前context， 并设置为当前context
    CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    [[self openGLContext] makeCurrentContext];
    
    // 清理颜色，清理深度缓存
//    glClearColor(0, 0, 0, 0);
//    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClearColor(1, 1, 1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 画点东西
//    drawAnObject();
    
    // 画个背景
    [self drawBackGround];
    
//    [[self openGLContext] presentRenderbuffer:GL_RENDERBUFFER];
    [[self openGLContext] flushBuffer];
    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

static void drawAnObject ()
{
    glColor3f(1.0f, 0.85f, 0.35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(  0.0,  0.6, 0.0);
        glVertex3f( -0.6, -0.3, 0.0);
        glVertex3f(  0.6, -0.6 ,0.0);
    }
    glEnd();
}

#pragma mark Update

- (void)initDisplayLink {
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&_myDisplayLink);
    
    // Set the renderer output callback function
//    CVDisplayLinkSetOutputCallback(_myDisplayLink, &MyDisplayLinkCallback, self);
//    CVDisplayLinkSetOutputCallback(
    
    // Set the display link for the current renderer
    CGLContextObj cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_myDisplayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(_myDisplayLink);
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = kCVReturnSuccess;//[(MAVBaseVideoView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

@end








