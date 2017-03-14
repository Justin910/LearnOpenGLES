//
//  ParentView.h
//  LearnOpenGLES
//
//  Created by aj on 2017/2/21.
//  Copyright © 2017年 Zhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@import OpenGLES;

@interface ParentView : UIView{
    
    CGFloat _width;
    CGFloat _height;
    
    EAGLContext *_context;
    CAEAGLLayer *_eaglLayer;
    
    GLuint _renderBuffer;   //渲染缓冲
    GLuint _frameBuffer;    //帧缓冲
    
    GLuint       _program;
    GLuint       _vertexShader;     //顶点着色器
    GLuint       _fragmentShader;   //片段着色器
}

@property (nonatomic, strong) CADisplayLink *displayLink;

- (void)setupContext;
- (void)setupLayer;

/*
 *  获取顶点着色器和片段着色器
 *  shaderType:    GL_FRAGMENT_SHADER  片段着色器
 *                 GL_VERTEX_SHADER    顶点着色器
 */
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType;

/*
 *  验证链接程序是否有效
 */
- (BOOL)validateProgram:(GLuint)prog;

/*
 *  停止渲染
 */
- (void)destroyDisplayLink;

@end
