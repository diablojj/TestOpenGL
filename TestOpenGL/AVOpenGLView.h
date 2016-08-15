//
//  AVOpenGLView.h
//  TestOpenGL
//
//  Created by wolf on 16/7/23.
//  Copyright © 2016年 wolf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>
//#include <CoreVideo/CVDisplayLink.h>

#define	COLOR_MAX_WIDTH     100//2
#define COLOR_MAX_HEIGHT	100//2
#define RGBA_SIZE           4
#define	MAX_WIDTH	2560
#define MAX_HEIGHT	1660

// 纹理属性
typedef struct {
    bool				isimg;
    GLuint				texture;
    int					width;//显示的宽度 像素
    int					height;
    int                 angle; // frameAngle 角度
    //    bool                isrotated;
    //    unsigned char		data[MAX_WIDTH * MAX_HEIGHT * RGBA_SIZE];
    unsigned char		*data;
    /*memory bitmap for image*/
    GLubyte*			imgdata;
    GLfloat             textureWidth;
    GLfloat             textureHeight;
    bool                islarge;
    bool                isvalid;
    bool                ishide;
    bool                ishover;
    GLfloat             pt[4][3];
    GLfloat             pttexture[4][2];
    unsigned long long  uin;
    int type;//video type
    bool  showBackGroud;
    bool  isReadyForVideoData;//增加一个状态，记录valid frame到video数据上来之间的一段过程
}vFrame;

@interface AVOpenGLView : NSOpenGLView {
    
    // 背景图片
    GLuint              _backGroudTexture;
    vFrame              backGroudFrame;
    unsigned char		_textureData[MAX_WIDTH * MAX_HEIGHT * RGBA_SIZE];
    int backGroudWidth;
    int backGroudHeight;
    
    // 背景颜色
    GLuint _colorBackGroudTexture;
    unsigned char		_colorBackGroudData[COLOR_MAX_WIDTH * COLOR_MAX_HEIGHT * RGBA_SIZE];
    
    // 着色器
    GLuint _positionSlot;
    GLuint _colorSlot;
    
    BOOL _testVBO;
    
    // 刷新控制
    CVDisplayLinkRef	_myDisplayLink;
}

- (id) initWithFrame:(NSRect)frameRect;

@end
