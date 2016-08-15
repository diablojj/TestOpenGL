//
//  ViewController.m
//  TestOpenGL
//
//  Created by wolf on 16/7/23.
//  Copyright © 2016年 wolf. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    // 初始化OpenGLView
    _openGLView = [[TestOpenGLView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
    [self.view addSubview:_openGLView];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
