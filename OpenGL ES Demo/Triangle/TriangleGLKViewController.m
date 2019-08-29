//
//  TriangleGLKViewController.m
//  OpenGL ES Demo
//
//  Created by Quincy-QC on 2019/5/29.
//  Copyright © 2019 Quincy-QC. All rights reserved.
//

#import "TriangleGLKViewController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface TriangleGLKViewController () <GLKViewDelegate>

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation TriangleGLKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self initialize];
    [self initializeWithGLKView];
}


- (void)initializeWithGLKView {
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    TriangleGLKView *glkView = [[TriangleGLKView alloc] initWithFrame:self.view.bounds context:context];
    [self.view addSubview:glkView];
}


- (void)initialize {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];

    GLKView *glkView = [[GLKView alloc] initWithFrame:self.view.bounds context:context];
    glkView.backgroundColor = [UIColor clearColor];
    glkView.delegate = self;
    [self.view addSubview:glkView];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.constantColor = GLKVector4Make(0.0, 1.0, 0.0, 1.0);

    [glkView display];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    
    GLfloat vVertice[] = {
        0.0, 0.5, 0.0,
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0
    };
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vVertice);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}


@end


@interface TriangleGLKView ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation TriangleGLKView

- (instancetype)initWithFrame:(CGRect)frame context:(nonnull EAGLContext *)context {
    self = [super initWithFrame:frame context:context];
    if (self) {
        self.baseEffect = [[GLKBaseEffect alloc] init];
        self.baseEffect.constantColor = GLKVector4Make(0.0, 1.0, 0.0, 1.0);
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    
    GLfloat vVertice[] = {
        0.0, 0.5, 0.0,
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0
    };
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vVertice);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

@end

#pragma clang diagnostic pop
