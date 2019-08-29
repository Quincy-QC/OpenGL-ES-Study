//
//  TextureViewController.m
//  OpenGL ES Demo
//
//  Created by Quincy-QC on 2019/7/26.
//  Copyright © 2019 Quincy-QC. All rights reserved.
//

#import "TextureViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES1/gl.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface TextureViewController ()

@property (strong, nonatomic) EAGLContext *context;

@end

@implementation TextureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self bindRender];
    [self setupVertices];
    
}


- (void)setupVertices {
    
//    GLfloat vertices[] = {
//        -1.0, -1.0, 0,
//        0, 0,
//        -1.0, 1.0, 0,
//        0, 1,
//        1.0, -1.0, 0,
//        1, 0,
//        1.0, 1.0, 0,
//        1, 1
//    };
    GLfloat vertices[] = {
        -0.5, -0.5, 0,
        0, 0,
        -0.5, 0.5, 0,
        0, 1,
        0.5, -0.5, 0,
        1, 0,
        .5, .5, 0,
        1, 1
    };
    GLuint program = [self createProgram];
    glUseProgram(program);
    glViewport(0, 0, [self getViewportWidth], [self getViewportHeight]);
    
    GLuint texture = [self createTextureWithImage:[UIImage imageNamed:@"9"]];
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    glActiveTexture(GL_TEXTURE0);

    int textureLocation = glGetUniformLocation(program, "s_texture");
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(textureLocation, 0);
    glTexStorage2D(GL_TEXTURE_2D, 0, GL_RGBA, [self getViewportWidth], [self getViewportHeight]);
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, 0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLvoid *)(sizeof(GLfloat)*3));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


- (GLuint)createTextureWithImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    GLuint width = (GLuint)CGImageGetWidth(imageRef);
    GLuint height = (GLuint)CGImageGetWidth(imageRef);
    
    GLubyte *imageData = malloc(sizeof(GLubyte) * width * height * 4);
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width*4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, width, height);
    CGContextRotateCTM(context, M_PI);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, rect, imageRef);
    
    GLuint textureId;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_G, GL_RED);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_B, GL_RED);
    
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
    
    return textureId;
}


//- (GLuint)getTexture:(UIImage *)image {
//    CGImageRef imageRef = image.CGImage;
//    GLuint width = (GLint)CGImageGetWidth(imageRef);
//    GLuint height = (GLint)CGImageGetHeight(imageRef);
//
//    GLubyte *imageData = malloc(sizeof(GLubyte)*width*height*4);
//    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
//    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width*4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
//    CGContextTranslateCTM(context, 0, height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGRect rect = CGRectMake(0, 0, width, height);
//    CGContextDrawImage(context, rect, imageRef);
//
//
//}


- (GLuint)createTextureWithImage1:(UIImage *)image {
    // 将 UIImage 转换为 CGImageRef
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 绘制图片
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, width, height);
    CGContextRotateCTM(context, M_PI);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    // 生成纹理
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData); // 将图片数据写入纹理缓存
    
    // 设置如何把纹素映射成像素
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 解绑
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // 释放内存
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}


- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
}


- (void)bindRender {
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = self.view.bounds;
    [self.view.layer addSublayer:layer];
    
    GLuint renderbuffer;
    GLuint framebuffer;
    glGenRenderbuffers(1, &renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];

    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
}


- (GLuint)loadShaderWithString:(NSString *)shaderString shaderType:(GLenum)shaderType {
    GLuint shader = glCreateShader(shaderType);
    if (!shader) {
        NSAssert(false, @"Create shader failed");
        return 0;
    }
    const GLchar *shaderSource = shaderString.UTF8String;
    glShaderSource(shader, 1, &shaderSource, NULL);
    glCompileShader(shader);
    
    GLint compileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if (!compileStatus) {
        GLint infoLogLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLength);
        if (infoLogLength > 0) {
            GLchar *infolog = malloc(sizeof(GLchar) * infoLogLength);
            glGetShaderInfoLog(shader, infoLogLength, NULL, infolog);
            NSAssert(false, @"Compile shader failed: %s", infolog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}


- (GLuint)createProgram {
    NSString *vertexShaderString = @"\
    #version 300 es \
    layout(location = 0) in vec4 a_position; \
    layout(location = 1) in vec2 a_texCoord; \
    out vec2 v_texCoord; \
    void main() \
    { \
        v_texCoord = a_texCoord; \
        gl_Position = a_position; \
    }";

    NSString *fragmentShaderString = @"\
    #version 300 es \
    precision mediump float; \
    in vec2 v_texCoord; \
    layout(location = 0) out vec4 outColor; \
    uniform sampler2D s_texture; \
    void main() \
    { \
        outColor = texture(s_texture, v_texCoord); \
    }";
    
    GLuint vertexShader = [self loadShaderWithString:vertexShaderString shaderType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self loadShaderWithString:fragmentShaderString shaderType:GL_FRAGMENT_SHADER];
    
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
            glGetProgramInfoLog(program, infologLength, NULL, infolog);
            NSAssert(false, @"Link program failed: %s", infolog);
        }
        glDeleteProgram(program);
        return 0;
    }
    return program;
}


- (GLint)getViewportWidth {
    GLint width;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    return width;
}


- (GLint)getViewportHeight {
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    return height;
}


- (void)dealloc {
    if ([EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:nil];
    }
}


@end

#pragma clang diagnostic pop
