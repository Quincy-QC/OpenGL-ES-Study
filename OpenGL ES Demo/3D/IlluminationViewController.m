//
//  IlluminationViewController.m
//  OpenGL ES Demo
//
//  Created by Quincy-QC on 2019/8/27.
//  Copyright © 2019 Quincy-QC. All rights reserved.
//

#import "IlluminationViewController.h"
#import <OpenGLES/ES3/gl.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface IlluminationViewController () {
    GLuint vao;
    GLuint lightvao;
    GLuint program1;
    GLuint program2;
    GLuint objectLocation;
    GLuint lightLocation;
    GLuint lightPosLocation;
    GLuint viewPosLocation;
    GLuint modelLocation;
    GLuint viewLocation;
    GLuint projectionLocation;
    GLuint modelLocation2;
    GLuint viewLocation2;
    GLuint projectionLocation2;
}

@property (strong, nonatomic) EAGLContext *context;
@property (assign, nonatomic) float elaspeTime;
@property (assign, nonatomic) float lightPosY;

@end

@implementation IlluminationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self useProgram];
    [self setupVertices];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    glUseProgram(program1);
    
    glBindVertexArray(vao);
//    glDrawElements(GL_TRIANGLE_STRIP, 14, GL_UNSIGNED_SHORT, 0);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(-0.3f, 0.2f, 1.0f);
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(-3.5f, 2.0f, 4.0f, 0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    GLKMatrix4 projectionMatrx = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), aspect, 0.1, 100.0);
    glUniformMatrix4fv(modelLocation, 1, GL_FALSE, modelMatrix.m);
    glUniformMatrix4fv(viewLocation, 1, GL_FALSE, viewMatrix.m);
    glUniformMatrix4fv(projectionLocation, 1, GL_FALSE, projectionMatrx.m);
    glUniform3f(objectLocation, 1.0f, 0.5f, 0.3f);  // objct color
    glUniform3f(lightLocation, 1.0f, 1.0f, 1.0f);   // light color
    glUniform3f(lightPosLocation, 3.0f, self.lightPosY, 2.5f);
    glUniform3f(viewPosLocation, -3.5f, 2.0f, 4.0f);
    
    glUseProgram(program2);
    glBindVertexArray(lightvao);
//    glDrawElements(GL_TRIANGLE_STRIP, 14, GL_UNSIGNED_SHORT, 0);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    GLKMatrix4 translateMatrix2 = GLKMatrix4MakeTranslation(3.0f, self.lightPosY, 2.5f);
    GLKMatrix4 scaleMatrix2 = GLKMatrix4MakeScale(0.2f, 0.2f, 0.2f);
    GLKMatrix4 modelMatrix2 = GLKMatrix4Multiply(scaleMatrix2, translateMatrix2);
    glUniformMatrix4fv(modelLocation2, 1, GL_FALSE, modelMatrix2.m);
    glUniformMatrix4fv(viewLocation2, 1, GL_FALSE, viewMatrix.m);
    glUniformMatrix4fv(projectionLocation2, 1, GL_FALSE, projectionMatrx.m);
}


- (void)update {
    NSTimeInterval updateTime = self.timeSinceLastUpdate;
    self.elaspeTime += updateTime;
    
    float varyingFactor = sin(self.elaspeTime);
    self.lightPosY = 6.6f + varyingFactor * 2.0;
}


- (void)setupVertices {
//    GLfloat vertices[] = {
//        0.5, 0.5, -0.5,
//        0.5, -0.5, -0.5,
//        -0.5, 0.5, -0.5,
//        -0.5, -0.5, -0.5,
//
//        -0.5, -0.5, 0.5,
//        0.5, -0.5, 0.5,
//        0.5, 0.5, 0.5,
//        -0.5, 0.5, 0.5,
//    };
//    GLushort indices[] = {
//        0, 1, 2, 3, 4, 1, 5, 0, 6, 2, 7, 4, 6, 5
//    };
    
    float vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f, 1.0f,
        
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//    GLuint ebo;
//    glGenBuffers(1, &ebo);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, 0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (GLvoid *)(sizeof(GLfloat)*3));
    
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    
    glBindVertexArray(0);
    
    glGenVertexArrays(1, &lightvao);
    glBindVertexArray(lightvao);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, 0);
    
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    
    glBindVertexArray(0);
}


- (void)getLocation {
    modelLocation = glGetUniformLocation(program1, "modelMatrix");
    viewLocation = glGetUniformLocation(program1, "viewMatrix");
    projectionLocation = glGetUniformLocation(program1, "projectionMatrix");
    objectLocation = glGetUniformLocation(program1, "objectColor");
    lightLocation = glGetUniformLocation(program1, "lightColor");
    lightPosLocation = glGetUniformLocation(program1, "lightPos");
    viewPosLocation = glGetUniformLocation(program1, "viewPos");
}


- (void)getLocation2 {
    modelLocation2 = glGetUniformLocation(program2, "modelMatrix");
    viewLocation2 = glGetUniformLocation(program2, "viewMatrix");
    projectionLocation2 = glGetUniformLocation(program2, "projectionMatrix");
}


- (void)setupContext {
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:view.context];
    
    glEnable(GL_DEPTH_TEST);
    
    self.preferredFramesPerSecond = 60;
}


- (void)useProgram {
    NSString *vertexShaderString = @" \
    #version 300 es \
    layout(location = 0) in vec3 a_position; \
    layout(location = 1) in vec3 a_normal; \
    uniform mat4 modelMatrix; \
    uniform mat4 viewMatrix; \
    uniform mat4 projectionMatrix; \
    out vec3 v_normal; \
    out vec3 FragPos; \
    void main() { \
    FragPos = vec3(modelMatrix * vec4(a_position, 1.0)); \
    v_normal = mat3(transpose(inverse(modelMatrix))) * a_normal; \
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(a_position, 1.0); \
    }";
    NSString *fragmentShaderString = @"\
    #version 300 es \
    precision mediump float; \
    uniform vec3 objectColor; \
    uniform vec3 lightColor; \
    uniform vec3 lightPos; \
    uniform vec3 viewPos; \
    in vec3 FragPos; \
    in vec3 v_normal; \
    out vec4 fragColor; \
    void main() { \
    float ambientStrength = 0.1; \
    vec3 ambient = ambientStrength * lightColor; \
    vec3 norm = normalize(v_normal); \
    vec3 lightDir = normalize(lightPos - FragPos); \
    float diff = max(dot(norm, lightDir), 0.0); \
    vec3 diffuse = diff * lightColor; \
    float specularStrength = 0.5; \
    vec3 viewDir = normalize(viewPos - FragPos); \
    vec3 reflectDir = reflect(-lightDir, norm); \
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0); \
    vec3 specular = specularStrength * spec * lightColor; \
    vec3 result = (ambient + diffuse + specular) * objectColor; \
    fragColor = vec4(result, 1.0); \
    }";
    program1 = [self createProgramWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString];
    [self getLocation];
    
    NSString *vertexShaderString2 = @" \
    #version 300 es \
    layout(location = 0) in vec3 a_position; \
    uniform mat4 modelMatrix; \
    uniform mat4 viewMatrix; \
    uniform mat4 projectionMatrix; \
    void main() { \
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(a_position, 1.0); \
    }";
    NSString *fragmentShaderString2 = @"\
    #version 300 es \
    precision mediump float; \
    out vec4 fragColor; \
    void main() { \
    fragColor = vec4(1.0); \
    }";
    program2 = [self createProgramWithVertexShaderString:vertexShaderString2 fragmentShaderString:fragmentShaderString2];
    [self getLocation2];
}


- (GLuint)createProgramWithVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString {
    GLuint vertexShader = [self createShaderWithType:GL_VERTEX_SHADER shaderString:vertexShaderString];
    GLuint fragmentShader = [self createShaderWithType:GL_FRAGMENT_SHADER shaderString:fragmentShaderString];
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (!linkStatus) {
        GLint infologLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infologLength);
        if (infologLength) {
            GLchar *infolog = malloc(sizeof(GLchar) * infologLength);
            glGetProgramInfoLog(program, infologLength, NULL, infolog);
            NSAssert(NO, @"Link program failed: %s", infolog);
        }
        glDeleteProgram(program);
        return 0;
    }
    
    return program;
}


- (GLuint)createShaderWithType:(GLenum)shaderType shaderString:(NSString *)shaderString {
    GLuint shader = glCreateShader(shaderType);
    const char *shaderStr = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderStr, NULL);
    glCompileShader(shader);
    GLint compileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if (!compileStatus) {
        GLint infologLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infologLength);
        if (infologLength) {
            GLchar *infolog = malloc(sizeof(GLchar) * infologLength);
            glGetShaderInfoLog(shader, infologLength, NULL, infolog);
            NSAssert(NO, @"Compile shader failed: %s", infolog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

@end

#pragma clang diagnostic pop
