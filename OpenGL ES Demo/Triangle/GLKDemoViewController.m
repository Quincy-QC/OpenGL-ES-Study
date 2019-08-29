//
//  GLKDemoViewController.m
//  OpenGL ES Demo
//
//  Created by Quincy-QC on 2019/7/23.
//  Copyright © 2019 Quincy-QC. All rights reserved.
//

#import "GLKDemoViewController.h"
#import <OpenGLES/ES3/gl.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


@interface GLKDemoViewController() <GLKViewDelegate> {
    GLuint vertexArrays;
}

@property (assign, nonatomic) GLKMatrix4 transformMatrix;
@property (assign, nonatomic) GLuint transformUniformLocation;
@property (assign, nonatomic) float elapsedTime;

@end

@implementation GLKDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredFramesPerSecond = 60;
    
    [self setupContext];
    [self setupVertices];
}


- (void)update {
    
    // 变换矩阵
    /*
    self.elapsedTime += self.timeSinceLastUpdate;
    float varyingFactor = sin(self.elapsedTime);
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(varyingFactor, varyingFactor, 1.0);
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(varyingFactor, 0, 0, 1.0);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(varyingFactor, 0, 0);
    self.transformMatrix = GLKMatrix4Multiply(translateMatrix, rotateMatrix);
    self.transformMatrix = GLKMatrix4Multiply(self.transformMatrix, scaleMatrix);
     */
    
    // 透视投影
    self.elapsedTime += self.timeSinceLastUpdate;
    float varyingFactor = self.elapsedTime;
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathRadiansToDegrees(90), aspect, 0.1, 10.0);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, -1.6);
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(varyingFactor, 0, 1, 0);
    self.transformMatrix = GLKMatrix4Multiply(translateMatrix, rotateMatrix);
    self.transformMatrix = GLKMatrix4Multiply(perspectiveMatrix, self.transformMatrix);
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0, 0, 0, 1.0);
    
    glUniformMatrix4fv(self.transformUniformLocation, 1, 0, self.transformMatrix.m);
    
    glBindVertexArray(vertexArrays);
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_SHORT, 0);
}


- (void)setupVertices {
//    GLfloat vertices[] = {
//        -0.75f, -0.5f, 0.0f,
//        1.0f, 0.0f, 0.0f, 1.0f,
//        -0.75f, 0.5f, 0.0f,
//        0.0f, 1.0f, 0.0f, 1.0f,
//        -0.25f, 0.5f, 0.0f,
//        0.0f, 0.0f, 1.0f, 1.0f,
//        -0.25f, -0.5f, 0.0f,
//        1.0f, 0.0f, 0.0f, 1.0f,
//    };
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        -0.5f, 0.5f, 0.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.5f, 0.5f, 0.0f,
        0.0f, 0.0f, 1.0f, 1.0f,
        0.5f, -0.5f, 0.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
    };
    GLushort indices[] = {
        0, 1, 2, 3
    };

    GLuint vbos[2];
    glGenBuffers(2, vbos);
    glBindBuffer(GL_ARRAY_BUFFER, vbos[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbos[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glGenVertexArrays(1, &vertexArrays);
    glBindVertexArray(vertexArrays);

    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 7, 0);
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 7, (const GLvoid *)(sizeof(GLfloat) * 3));
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbos[1]);

    glBindVertexArray(0);
}


- (void)setupContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    
    GLKView *glkView = (GLKView *)self.view;
    glkView.context = context;
    
    GLuint program = [self createProgram];
    glUseProgram(program);
    self.transformUniformLocation = glGetUniformLocation(program, "u_mvpMatrix");
}


- (GLuint)loadShaderWithShaderType:(GLenum)shaderType {
    NSString *shaderFile = [[NSBundle mainBundle] pathForResource:@"glsla" ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSString *shaderSource = [NSString stringWithContentsOfFile:shaderFile encoding:NSUTF8StringEncoding error:nil];
    if (!shaderSource) {
        NSAssert(false, @"load shader source failed");
        return 0;
    }
    GLuint shader = glCreateShader(shaderType);
    if (!shader) {
        NSAssert(false, @"create shader failed");
        return 0;
    }
    const GLchar *shaderSourceUTF8String = shaderSource.UTF8String;
    glShaderSource(shader, 1, &shaderSourceUTF8String, NULL);
    glCompileShader(shader);
    
    GLint shaderCompileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &shaderCompileStatus);
    if (!shaderCompileStatus) {
        GLint infoLogLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLogLength);
            glGetShaderInfoLog(shader, infoLogLength, NULL, infoLog);
            NSAssert(false, @"compile shader failed: %s", infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}


- (GLuint)createProgram {
    GLuint vertexShader = [self loadShaderWithShaderType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self loadShaderWithShaderType:GL_FRAGMENT_SHADER];
    if (!vertexShader || !fragmentShader) {
        return 0;
    }
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (!linkStatus) {
        GLint infoLogLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLogLength);
            glGetProgramInfoLog(program, infoLogLength, NULL, infoLog);
            NSAssert(false, @"link program failed: %s", infoLog);
        }
        glDeleteProgram(program);
        return 0;
    }
    return program;
}


- (void)dealloc {
    if ([EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:nil];
    }
}


- (GLint)getWidth {
    GLint width;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    return width;
}


- (GLint)getHeight {
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    return height;
}



@end

#pragma clang diagnostic pop
