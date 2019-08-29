//
//  Cube3DViewController.m
//  OpenGL ES Demo
//
//  Created by Quincy-QC on 2019/8/16.
//  Copyright © 2019 Quincy-QC. All rights reserved.
//

#import "Cube3DViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/EAGL.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface Cube3DViewController () {
    GLuint vao;
    GLuint program;
    GLuint mvpMatrixlocation;
}

@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (assign, nonatomic) GLfloat elapsedTime;
@property (assign, nonatomic) GLKMatrix4 rotateMatrix;

@end

@implementation Cube3DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupVertices];
    
    mvpMatrixlocation = glGetUniformLocation(program, "v_mvpMatrix");
}


- (void)update {
    NSTimeInterval detalTime = self.timeSinceLastUpdate;
    self.elapsedTime += detalTime;
    
    float varyingFactor = (sin(self.elapsedTime) + 1) / 2.0;
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    /*
    self.rotateMatrix = GLKMatrix4MakeRotation(varyingFactor * M_PI * 2, 1, 1, 1);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, -5.0);
    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), aspect, 0.1, 100.0);
    GLKMatrix4 viewMatrix = GLKMatrix4Multiply(perspectiveMatrix, translateMatrix);
    self.projectionMatrix = GLKMatrix4Multiply(viewMatrix, self.rotateMatrix);
     */
    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), aspect, 0.1, 100.0);
    GLKMatrix4 cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 5 * (varyingFactor + 1), 0, 0, 0, 0, 1, 0);
    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(varyingFactor * M_PI * 2, 1, 1, 1);
    self.projectionMatrix = GLKMatrix4Multiply(cameraMatrix, rotateMatrix);
    self.projectionMatrix = GLKMatrix4Multiply(perspectiveMatrix, self.projectionMatrix);
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.0, 0.0, 0.0, 1.0);

    glUniformMatrix4fv(mvpMatrixlocation, 1, 0, self.projectionMatrix.m);
    
    glBindVertexArray(vao);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
//    glDrawArrays(GL_TRIANGLES, 0, 36);
}


- (void)setupContext {
    
    self.preferredFramesPerSecond = 60;
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    [EAGLContext setCurrentContext:view.context];
    
    glEnable(GL_DEPTH_TEST);
    
    program = [self createProgram];
    glUseProgram(program);
}


- (void)setupVertices {

    GLfloat vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    GLushort indices[] = {
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35
    };

    GLuint vbo;
    GLuint ebo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glGenBuffers(1, &ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, 0);

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLvoid *)(sizeof(GLfloat)*3));

    GLuint texture = [self loadTextureFromImage:[UIImage imageNamed:@"5"]];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    GLuint textureLoc = glGetUniformLocation(program, "s_texture");
    glUniform1i(textureLoc, 0);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBindVertexArray(0);
}


- (GLuint)loadTextureFromImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    GLuint width = (GLuint)CGImageGetWidth(imageRef);
    GLuint height = (GLuint)CGImageGetHeight(imageRef);
    
    GLubyte *imageData = malloc(sizeof(GLubyte) * width * height * 4);
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, rect, imageRef);

    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    glGenerateMipmap(GL_TEXTURE_2D);
    
    // 设置采样器
    GLuint sampler;
    glGenSamplers(1, &sampler);
    glBindSampler(0, sampler);
    glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glSamplerParameteri(sampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glSamplerParameteri(sampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGContextClearRect(context, rect);
    CGContextRelease(context);
    free(imageData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return texture;
}


- (GLuint)createProgram {
    NSString *vertexShaderString = @"\
    #version 300 es \
    layout(location = 0) in vec4 a_position; \
    layout(location = 1) in vec2 a_textureCoor; \
    out vec2 v_textureCoor; \
    uniform mat4 v_mvpMatrix; \
    void main() { \
        v_textureCoor = a_textureCoor; \
        gl_Position = v_mvpMatrix * a_position; \
    }";

    NSString *fragmentShaderString = @"\
    #version 300 es \
    precision mediump float; \
    in vec2 v_textureCoor; \
    uniform sampler2D s_texture; \
    layout(location = 0) out vec4 outcolor; \
    void main() { \
        outcolor = texture(s_texture, v_textureCoor); \
    } ";
    
    GLuint vertexShader = [self createShaderWithString:vertexShaderString shaderType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self createShaderWithString:fragmentShaderString shaderType:GL_FRAGMENT_SHADER];
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (!linkStatus) {
        GLint infologLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infologLength);
        if (infologLength > 0) {
            GLchar *infolog = malloc(sizeof(GLchar) * infologLength);
            glGetProgramInfoLog(program, infologLength, 0, infolog);
            NSAssert(NO, @"link program failed: %s", infolog);
        }
        glDeleteProgram(program);
        return 0;
    }
    return program;
}


- (GLuint)createShaderWithString:(NSString *)shaderString shaderType:(GLenum)shaderType {
    
    GLuint shader = glCreateShader(shaderType);
    const char *shaderSource = (GLchar *)shaderString.UTF8String;
    glShaderSource(shader, 1, &shaderSource, NULL);
    glCompileShader(shader);
    
    GLint compileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if (!compileStatus) {
        GLint infoLogLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0) {
            GLchar *infolog = malloc(sizeof(GLchar) * infoLogLength);
            glGetShaderInfoLog(shader, infoLogLength, 0, infolog);
            NSAssert(NO, @"compile shader failed: %s", infolog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}


- (void)dealloc {
    if ([EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:nil];
    }
}

@end

#pragma clang diagnostic pop
