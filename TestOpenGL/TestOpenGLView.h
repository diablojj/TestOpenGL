//
//  TestOpenGLView.h
//  TestOpenGL
//
//  Created by wolf on 16/8/15.
//  Copyright © 2016年 wolf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AVOpenGLHelper.h"

@interface TestOpenGLView : NSOpenGLView {
    // 是否测试VBO
    BOOL _testVBO;
    
    // 帮助对象
    AVOpenGLHelper* _OGHelper;
    
    // 纹理对象
    GLuint _backGroudTexture;
}

@end
