//
//  TriangleViewController.m
//  OpenGL ES Demo
//
//  Created by Quincy-QC on 2019/5/29.
//  Copyright © 2019 Quincy-QC. All rights reserved.
//

#import "TriangleViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/EAGL.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

typedef struct {
    GLKVector3 positionCoord;
//    GLKVector2 textureCoord;
} SenceVertex;

@interface TriangleViewController ()

@property (nonatomic, assign) SenceVertex *vertices;

@end

@implementation TriangleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initialize];
}


- (void)initialize {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];

//    self.vertices = malloc(sizeof(SenceVertex) * 3);
//    self.vertices[0] = (SenceVertex){{0.0, 0.5, 0.0}};
//    self.vertices[1] = (SenceVertex){{-0.5, -0.5, 0.0}};
//    self.vertices[2] = (SenceVertex){{0.5, -0.5, 0.0}};
    GLfloat vVertices[] = {
        0.0f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f
    };
    
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = self.view.bounds;
//    layer.contentsScale = [UIScreen mainScreen].scale;
    [self.view.layer addSublayer:layer];
    
    [self bindRenderLayer:layer context:context];
    
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    GLuint program = [self createProgram:@"glsl"];
    if (!program) {
        return;
    }
    glUseProgram(program);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    /*
    // 设置顶点数组
    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
    
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
    */
    
//    DrawPrimitiveWithoutVBOs();
//    glUniform1f(0, 1.0f);
//    DrawPrimitiveWithVBOs();
    DrawPrimitiveWithVAOs();
    [context presentRenderbuffer:GL_RENDERBUFFER];    
}

void DrawPrimitiveWithoutVBOs() {
    GLint vertex_position_size = 3;
    GLint vertex_color_size = 4;
    GLushort indices[3] = {0, 1, 2};
    GLfloat vertices[] = {
        -0.5f, 0.5f, 0.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        -1.0f, -0.5f, 0.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, -0.5f, 0.0f,
        0.0f, 0.0f, 1.0f, 1.0f
    };
    GLfloat *vtxBuf = vertices;
    GLsizei vtxStride = sizeof(GLfloat) * (vertex_color_size + vertex_position_size);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    
    glVertexAttribPointer(0, vertex_position_size, GL_FLOAT, GL_FALSE, vtxStride, vtxBuf);
    vtxBuf += vertex_position_size;
    glVertexAttribPointer(1, vertex_color_size, GL_FLOAT, GL_FALSE, vtxStride, vtxBuf);
    
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_SHORT, indices);
    
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
}


/*
void DrawPrimitiveWithVBOs() {
    GLvoid *offset = 0;
    GLuint vboIds[2];
    GLint vertex_position_size = 3;
    GLint vertex_color_size = 4;
    GLushort indices[3] = {0, 1, 2};
    GLint vtxStride = sizeof(GLfloat) * (vertex_position_size + vertex_color_size);
    GLfloat vertices[] = {
        -0.5f, 0.5f, 0.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        -1.0f, -0.5f, 0.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, -0.5f, 0.0f,
        0.0f, 0.0f, 1.0f, 1.0f
    };
    GLfloat *vtxBuf = vertices;

    glGenBuffers(2, vboIds);
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[0]);
    glBufferData(GL_ARRAY_BUFFER, vtxStride * 3, vtxBuf, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIds[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * 3, indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    
    glVertexAttribPointer(0, vertex_position_size, GL_FLOAT, GL_FALSE, vtxStride, offset);
    offset += vertex_position_size * sizeof(GLfloat);
    glVertexAttribPointer(1, vertex_color_size, GL_FLOAT, GL_FALSE, vtxStride, offset);
    
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_SHORT, 0);
    
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}
*/

void DrawPrimitiveWithVBOs() {
    GLuint vboIds[3];
    GLint vertex_position_size = 3;
    GLint vertex_color_size = 4;
    GLfloat position[] = {
        -0.5f, 0.5f, 0.0f,
        -1.0f, -0.5f, 0.0f,
        0.0f, -0.5f, 0.0f
    };
    GLfloat color[] = {
        1.0f, 0.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f
    };
    GLushort indices[3] = {0, 1, 2};

    glGenBuffers(3, vboIds);
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * vertex_position_size * 3, position, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * vertex_color_size * 4, color, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIds[2]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * 3, indices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[0]);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, vertex_position_size, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * vertex_position_size, 0);
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[1]);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, vertex_color_size, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * vertex_color_size, 0);
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_SHORT, 0);
    
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}


void DrawPrimitiveWithVAOs() {
    GLuint vboIds[2];
    GLint vertex_position_size = 3;
    GLint vertex_color_size = 4;
    GLfloat vertices[] = {
        0.0f, 0.5f, 0.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        -0.5f, -0.5f, 0.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.5f, -0.5f, 0.0f,
        0.0f, 0.0f, 1.0f, 1.0f
    };
    GLuint vaoId;
    GLushort indices[3] = { 0, 1, 2 };
    glGenBuffers(2, vboIds);
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIds[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glGenVertexArrays(1, &vaoId);
    glBindVertexArray(vaoId);
    
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[0]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIds[1]);

    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    
    glVertexAttribPointer(0, vertex_position_size, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * (vertex_position_size + vertex_color_size), 0);
    glVertexAttribPointer(1, vertex_color_size, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * (vertex_position_size + vertex_color_size), (const void *)(sizeof(GLfloat) * vertex_position_size));
    
    glBindVertexArray(0);
    
    glBindVertexArray(vaoId);
    glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_SHORT, 0);
}


- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer context:(EAGLContext *)context {
    
    GLuint renderbuffer;
    GLuint framebuffer;
    glGenRenderbuffers(1, &renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
}


- (GLuint)loadShaderWithName:(NSString *)name type:(GLenum)shaderType {
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取Shader失败，%@", error.localizedDescription);
        return 0;
    }
    
    // 创建shader对象
    GLuint shader = glCreateShader(shaderType);
    if (!shader) {
        return 0;
    }
    
    // 获取shader内容
    const GLchar *shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    
    // 编译shader
    glCompileShader(shader);
    
    // 查询shader编译状态
    GLint compiled;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
        GLint infoLen;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSAssert(NO, @"编译shader失败，%s", infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}


- (GLuint)createProgram:(NSString *)programName {
    GLuint vertexShader = [self loadShaderWithName:programName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self loadShaderWithName:programName type:GL_FRAGMENT_SHADER];
    
    // 创建program对象
    GLuint program = glCreateProgram();
    if (!program) {
        return 0;
    }
    
    // program关联shader
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // 链接program
    glLinkProgram(program);
    
    // 查询program状态
    GLint linked;
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLen);
            glGetProgramInfoLog(program, infoLen, NULL, infoLog);
            NSAssert(NO, @"program链接失败，%s", infoLog);
            free(infoLog);
        }
        glDeleteProgram(program);
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
