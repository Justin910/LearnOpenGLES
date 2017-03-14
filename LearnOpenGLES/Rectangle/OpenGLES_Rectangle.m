//
//  OpenGLES_Rectangle.m
//  LearnOpenGLES
//
//  Created by aj on 2017/2/21.
//  Copyright © 2017年 Zhen. All rights reserved.
//

#import "OpenGLES_Rectangle.h"

@interface OpenGLES_Rectangle () {

    GLuint _positionSlot;   //着色器中的顶点变量
    GLuint _colorSlot;      //着色器中的颜色变量
}

@end

//4个顶点(分别表示xyz轴)
static const float Vertices[] = {
    
    -0.5, -0.5, 0,  //左下
     0.5, -0.5, 0,  //右下
    -0.5,  0.5, 0,  //左上
     0.5,  0.5, 0,  //右上
};

//4个点的颜色(分别表示RGBA值)
static const float Colors[] = {
    1,0,0,1,
    0,1,0,1,
    0,0,1,1,
    0,0,0,1,
};


@implementation OpenGLES_Rectangle

- (instancetype)initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
    }
    return self;
}

/**
 *  设置渲染缓冲区
 */
- (void)setupRenderBuffer {
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

/**
 *  设置帧缓冲区
 */
- (void)setupFrameBuffer {
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

/**
 *  编译着色器
 */
- (void)compileShaders {
    
    //编译顶点着色器和片段着色器
    GLuint vertexShader   = [self compileShader:@"RectangleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"RectangleFragment" withType:GL_FRAGMENT_SHADER];
    
    //把顶点和片段着色器链接到一个完整的程序
    _program = glCreateProgram();
    glAttachShader(_program, vertexShader);
    glAttachShader(_program, fragmentShader);
    glLinkProgram(_program);
    
    //检查是否有错误, 有的话获取错误信息
    if(![self validateProgram:_program]) {
        
        glDeleteProgram(_program);
        exit(1);
    }
    
    //告诉OpenGL使用该程序
    glUseProgram(_program);
    
    //这里是获取刚才着色器里面的变量并使用
    _positionSlot = glGetAttribLocation(_program, "Position");
    _colorSlot    = glGetAttribLocation(_program, "InColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}

- (void)render:(CADisplayLink *)displayLink {
    
    //用指定的颜色清除,清除颜色被设置为(0.5f, 0.5f, 0.5f, 1.0f), 所以为黑色
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //设定窗口的范围(如果不是很明白, 可以自己动手修改下试试)
    //他这个是左下角为(0,0) 右上角为(width,height)
    glViewport(0, 0, _width, _height);
    
    //指定了渲染时索引值为 index 的顶点属性数组的数据格式和位置。
    /*
     *  indx:指定要修改的顶点属性的索引值
     *  size:指定每个顶点属性的组件数量。(必须坐标xyz轴就是3, 颜色rgba就是4)
     *  type:指定数组中每个组件的数据类型。(一般为GL_FLOAT)
     *  normalized:一般为GL_FALSE
     *  stride:指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0。
     *  ptr:指向数据的指针
     */
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, Vertices);
    glVertexAttribPointer(_colorSlot,    4, GL_FLOAT, GL_FALSE, 0, Colors);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(Vertices) / (sizeof(int) * 3));
    
    //把缓冲区的数据呈现到UIView上
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc {
    glDisableVertexAttribArray(_positionSlot);
    glDisableVertexAttribArray(_colorSlot);
}

@end
