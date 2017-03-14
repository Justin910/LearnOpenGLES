//
//  ParentView.m
//  LearnOpenGLES
//
//  Created by aj on 2017/2/21.
//  Copyright © 2017年 Zhen. All rights reserved.
//

#import "ParentView.h"

@implementation ParentView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        
        _width  = frame.size.width;
        _height = frame.size.height;
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

+(Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
}

/**
 *  设置上下文
 */
- (void)setupContext {
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}


- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 获取资源路径
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError  *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    
    if (!shaderString) {
        
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    /*
     *  GL_FRAGMENT_SHADER  创建一个片段着色器
     *  GL_VERTEX_SHADER    创建一个顶点着色器
     */
    GLuint shaderHandle          = glCreateShader(shaderType);
    
    // 转换成char*类型(给予OpenGL着色器)
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength       = (int)[shaderString length];
    
    /**
     *  @param shader      所产生的着色器名称
     *  @param count       表示多少资源传递一次(如果只上传一个着色代码,这里必须填1)
     *  @param string      C语言的资源路径
     *  @param length      C语言资源路径的字符长度
     */
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 调用运行时编译的着色器
    glCompileShader(shaderHandle);
    
    // 查看是否有错误,有的话获取错误信息
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        glDeleteShader(shaderHandle);
        exit(1);
    }
    
    return shaderHandle;
}

//验证链接程序是否有效
- (BOOL)validateProgram:(GLuint)prog {
    
    GLint linkSuccess;
    glGetProgramiv(prog, GL_LINK_STATUS, &linkSuccess);
    if(linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(prog, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        return NO;
    }
    
    return YES;
}

- (void)render:(CADisplayLink *)displayLink {}


- (void)destroyDisplayLink {
    
    if(self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

#pragma mark - Dealloc
- (void)dealloc {
    
    //删除绑定的渲染缓冲区
    if(_renderBuffer) {
        glDeleteRenderbuffers(GL_RENDERBUFFER, &_renderBuffer);
    }
    
    //删除绑定的帧缓冲区
    if(_frameBuffer) {
        glDeleteFramebuffers(GL_FRAMEBUFFER, &_frameBuffer);
    }
    
    //释放着色器
    if(_vertexShader) {
        
        //删除顶点着色器连接
        glDetachShader(_program, _vertexShader);
        
        //删除顶点着色器
        glDeleteShader(_vertexShader);
    }
    
    if(_fragmentShader) {
        
        //删除片段着色器连接
        glDetachShader(_program, _fragmentShader);
        
        //删除片段着色器
        glDeleteShader(_fragmentShader);
    }
    
    if(_program) {
        glDeleteProgram(_program);
    }
}

@end
