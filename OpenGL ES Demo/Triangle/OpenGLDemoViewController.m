//
//  OpenGLDemoViewController.m
//  OpenGL ES Demo
//
//  Created by Quincy-QC on 2019/7/15.
//  Copyright © 2019 Quincy-QC. All rights reserved.
//

#import "OpenGLDemoViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface OpenGLDemoViewController () {
    EAGLContext *_context;
    GLuint vaos;
}

@end

@implementation OpenGLDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupRender];
    [self setupGLProgram];
    [self setupVertices];
}


- (void)setupRender {
    CAEAGLLayer *eaglLayer = [[CAEAGLLayer alloc] init];
    eaglLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:eaglLayer];
    
    GLuint renderBuffer;
    GLuint frameBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];

    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);

    glClearColor(0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

//    glEnable(GL_PRIMITIVE_RESTART_FIXED_INDEX);

    glBindVertexArray(vaos);
    glDrawElements(GL_TRIANGLE_STRIP, 10, GL_UNSIGNED_SHORT, 0);

//    glDisable(GL_PRIMITIVE_RESTART_FIXED_INDEX);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:_context];
}


- (void)update {
    
}


- (void)setupGLProgram {
    GLuint program = [self createProgram];
    glUseProgram(program);
}


- (void)setupVertices {

    GLfloat vertices[] = {
        -0.75f, 0, 0,
        -0.75f, 0.75f, 0,
        -0.25f, 0, 0,
        -0.25f, 0.75, 0,
        
        0.75f, 0, 0,
        0.75f, 0.75f, 0,
        0.25f, 0, 0,
        0.25f, 0.75, 0
    };
    GLfloat colors[] = {
        1.0f, 0.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        
        1.0f, 0.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f
    };
    GLushort indices[] = {0, 1, 2, 3, 3, 4, 4, 5, 6, 7};
    
    GLuint vbos[3];
    glGenBuffers(3, vbos);
    glBindBuffer(GL_ARRAY_BUFFER, vbos[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbos[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(colors), colors, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbos[2]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &vaos);
    glBindVertexArray(vaos);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbos[0]);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), 0);
    glBindBuffer(GL_ARRAY_BUFFER, vbos[1]);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbos[2]);
    
    glBindVertexArray(0);
}


- (GLuint)loadShaderWithShaderType:(GLenum)shaderType {
    GLuint shader = glCreateShader(shaderType);
    if (!shader) {
        NSLog(@"创建shader失败");
        return 0;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"glsl" ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSError *error;
    NSString *shaderSource = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderSource) {
        NSLog(@"获取shader资源失败，%@", error.localizedDescription);
        return 0;
    }
    
    const GLchar *shaderString = shaderSource.UTF8String;
    glShaderSource(shader, 1, &shaderString, NULL);
    glCompileShader(shader);
    
    GLint shaderCompileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &shaderCompileStatus);
    if (!shaderCompileStatus) {
        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *infolog = malloc(sizeof(GLchar) * logLength);
        glGetShaderInfoLog(shader, sizeof(infolog), NULL, infolog);
        NSLog(@"编译shader失败，%s", infolog);
        return 0;
    }
    return shader;
}


- (GLuint)createProgram {
    GLuint program = glCreateProgram();
    if (!program) {
        NSLog(@"创建program失败");
        return 0;
    }
    
    GLuint vertexShader = [self loadShaderWithShaderType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self loadShaderWithShaderType:GL_FRAGMENT_SHADER];
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glLinkProgram(program);
    
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (!linkStatus) {
        GLint logLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *infolog = malloc(sizeof(GLchar) * logLength);
        glGetProgramInfoLog(program, sizeof(infolog), NULL, infolog);
        NSLog(@"链接program失败，%s", infolog);
        return 0;
    }
    return program;
}


// 获取渲染缓存宽度
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    
    return backingWidth;
}

// 获取渲染缓存高度
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    return backingHeight;
}


- (void)dealloc {
    if ([EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:nil];
    }
}

@end

#pragma clang diagnostic pop
