//
//  GLKBlendViewController.m
//  OpenGL ES Demo
//
//  Created by Quincy-QC on 2019/8/15.
//  Copyright © 2019 Quincy-QC. All rights reserved.
//

#import "GLKBlendViewController.h"
#import <OpenGLES/ES3/gl.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface GLKBlendViewController () {
    GLuint vao;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKBaseEffect *baseEffect1;
@property (strong, nonatomic) GLKTextureInfo *textureInfo1;

@end

@implementation GLKBlendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupTexture];
    [self setupVertices];
}


- (void)setupContext {
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
}


- (void)setupTexture {
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    UIImage *image = [UIImage imageNamed:@"1.png"];
    GLKTextureInfo *textureLoader = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:NULL];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = textureLoader.name;
    self.baseEffect.texture2d0.target = textureLoader.target;
    
    self.baseEffect1 = [[GLKBaseEffect alloc] init];
//    self.baseEffect1.light0.enabled = YES;
//    self.baseEffect1.light0.diffuseColor = GLKVector4Make(1.0, 0, 0, 1.0);
//    self.baseEffect1.light0.position = GLKVector4Make(0, 0, 0, 0);
    
    UIImage *image1 = [UIImage imageNamed:@"2.png"];
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:image1.CGImage options:options error:nil];
    
//    self.baseEffect.texture2d1.name = self.textureInfo1.name;
//    self.baseEffect.texture2d1.target = self.textureInfo1.target;
//    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}


- (void)setupVertices {
    GLfloat vertices[] = {
        -1.0, -0.8, 0.0, 0.0, 0.0,
        -1.0, 0.8, 0.0, 0.0, 1.0,
        1.0, 0.8, 0.0, 1.0, 1.0,
        1.0, -0.8, 0.0, 1.0, 0.0,
    };

    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLvoid *)(sizeof(GLfloat)*3));
    
//    glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
//    glVertexAttribPointer(GLKVertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLvoid *)(sizeof(GLfloat)*3));
    
    glBindVertexArray(0);
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    [self.baseEffect1 prepareToDraw];
    [self.baseEffect prepareToDraw];
    
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
//    self.baseEffect.texture2d0.name = self.textureInfo1.name;
//    self.baseEffect.texture2d0.target = self.textureInfo1.target;
//    [self.baseEffect prepareToDraw];
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}


@end

#pragma clang diagnostic pop
