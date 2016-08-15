//
//  AVOpenGLHelper.m
//  TestOpenGL
//
//  Created by wolf on 16/8/15.
//  Copyright © 2016年 wolf. All rights reserved.
//

#import "AVOpenGLHelper.h"

@implementation AVOpenGLHelper

// 创建图片纹理
- (GLuint) createTextureFromPic:(NSString*)picName {
    
    //
    GLuint textureID;
    
    //
    NSUInteger				width, height;
    NSURL					*url = nil;
    CGImageSourceRef		src = nil;
    CGImageRef				image = nil;
    CGContextRef			context = nil;
    CGColorSpaceRef			colorSpace = nil;
    
    NSArray*				ns = [picName componentsSeparatedByString:@"."];
    
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
    
    NSUInteger backGroudWidth = width;
    NSUInteger backGroudHeight = height;
    
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
    glBindTexture(GL_TEXTURE_2D, textureID);
    
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
    
    return textureID;
}

// 创建着色器并编译链接
- (void) createShaders:(NSString*)vShaderName fShader:(NSString*)fShaderName {
    // 1
    GLuint vertexShader = [self compileShader:vShaderName
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:fShaderName
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


#pragma mark Internal Function
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

@end
