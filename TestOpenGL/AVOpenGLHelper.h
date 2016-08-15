//
//  AVOpenGLHelper.h
//  TestOpenGL
//
//  Created by wolf on 16/8/15.
//  Copyright © 2016年 wolf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/glu.h>
#import <OpenGL/CGLTypes.h>

#define RGBA_SIZE           4
#define	MAX_WIDTH	2560
#define MAX_HEIGHT	1660

@interface AVOpenGLHelper : NSObject {
    
    unsigned char		_textureData[MAX_WIDTH * MAX_HEIGHT * RGBA_SIZE];
}

// 属性
@property(readonly,assign) GLuint positionSlot;
@property(readonly,assign) GLuint colorSlot;

// 从图片创建纹理
- (GLuint) createTextureFromPic:(NSString*)picName;

// 创建着色器并编译和链接
- (void) createShaders:(NSString*)vShaderName fShader:(NSString*)fShaderName;




@end
