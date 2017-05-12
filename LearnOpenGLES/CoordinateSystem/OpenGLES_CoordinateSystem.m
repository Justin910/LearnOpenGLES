//
//  OpenGLES_CoordinateSystem.m
//  LearnOpenGLES
//
//  Created by aj on 2017/5/9.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import "OpenGLES_CoordinateSystem.h"
#import <GLKit/GLKit.h>

#import "TextureManager.h"

#import "CoordinateSystemInfoView.h"

@interface OpenGLES_CoordinateSystem (){
    
    GLuint _depthRenderBuffer;  //深度缓冲
    
    GLuint _positionSlot;    //着色器中的顶点变量
    GLuint _textureSlot;     //着色器中的纹理变量
    
    GLuint _texture;          //纹理对象
    GLuint _textureUniform;   //纹理单元
    
    GLuint _texture1;         //纹理对象
    GLuint _textureUniform1;  //纹理单元
    
    GLuint _projection;      //投影
    GLuint _model;           //模型
    GLuint _view;            //观察
    
    
    CGPoint _touchPoint;
    CGFloat _objectZ;
}

@property (nonatomic, strong) CoordinateSystemInfoView *infoView;

@end

//4个顶点(分别表示xyz轴)
static const float Vertices[] = {
    
    //前面4个坐标
    -1, -1,  1,
     1, -1,  1,
    -1,  1,  1,
     1,  1,  1,
    
    //后面4个坐标
    -1, -1, -1,
     1, -1, -1,
    -1,  1, -1,
     1,  1, -1,
    
    //左边4个坐标
    -1, -1, -1,
    -1, -1,  1,
    -1,  1, -1,
    -1,  1,  1,
    
    //右边4个坐标
     1, -1, -1,
     1, -1,  1,
     1,  1, -1,
     1,  1,  1,
    
    //上边4个坐标
     1,  1, -1,
    -1,  1, -1,
     1,  1,  1,
    -1,  1,  1,
    //下边4个坐标
     1, -1, -1,
    -1, -1, -1,
     1, -1,  1,
    -1, -1,  1,
    
};

static const float Texture[] = {
    
    0, 0,
    1, 0,
    0, 1,
    1, 1,
    
    0, 0,
    1, 0,
    0, 1,
    1, 1,
    
    0, 0,
    1, 0,
    0, 1,
    1, 1,
    
    0, 0,
    1, 0,
    0, 1,
    1, 1,
    
    0, 0,
    1, 0,
    0, 1,
    1, 1,
    
    0, 0,
    1, 0,
    0, 1,
    1, 1,
};


static const GLubyte Indices[] = {
    
    //前面
    0,  1,  2,
    2,  3,  1,
    
    //后面
    4,  5,  6,
    6,  7,  5,
    
    //左面
    8,  9, 10,
    10, 11, 9,
    
    //右面
    12, 13, 14,
    14, 15, 13,
    
    //上面
    16, 17, 18,
    18, 19, 17,
    
    //下面
    20, 21, 22,
    22, 23, 21
};

@implementation OpenGLES_CoordinateSystem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initData];
        
        [self createOperationView];
        
        [self setupLayer];
        [self setupContext];
        
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
    }
    return self;
}

- (void)initData {
    
    _objectZ = -6.0f;
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
 *  设置深度缓冲区
 */
- (void)setupDepthBuffer {
    
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
}

/**
 *  设置帧缓冲区
 */
- (void)setupFrameBuffer {
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,  GL_RENDERBUFFER, _depthRenderBuffer);
}

/**
 *  编译着色器
 */
- (void)compileShaders {
    
    //编译顶点着色器和片段着色器
    GLuint vertexShader   = [self compileShader:@"CoordinateSystemVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"CoordinateSystemFragment" withType:GL_FRAGMENT_SHADER];
    
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
    _textureSlot = glGetAttribLocation(_program, "TexCoordIn");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_textureSlot);

    _texture  = [TextureManager getTextureImageName:@"CoordinateSystem_1.jpg"];
    _texture1 = [TextureManager getTextureImageName:@"CoordinateSystem_2.png"];
    
    
    _textureUniform   = glGetUniformLocation(_program, "ourTexture");
    _textureUniform1  = glGetUniformLocation(_program, "ourTexture1");
    
    
    _projection = glGetUniformLocation(_program, "Projection");
    _model      = glGetUniformLocation(_program, "Model");
    _view       = glGetUniformLocation(_program, "View");
}


static const float cubePositions[10][3] = {
    { 0.0f,  0.0f,   0.0f},
    { 2.0f,  5.0f, -15.0f},
    {-1.5f, -2.2f,  -2.5f},
    {-3.8f, -2.0f, -12.3f},
    { 2.4f, -0.4f,  -3.5f},
    {-1.7f,  3.0f,  -7.5f},
    { 1.3f, -2.0f,  -2.5f},
    { 1.5f,  2.0f,  -2.5f},
    { 1.5f,  0.2f,  -1.5f},
    {-1.3f,  1.0f,  -1.5f},
};

- (void)render:(CADisplayLink *)displayLink {
    
    //用指定的颜色清除,清除颜色被设置为(0.5f, 0.5f, 0.5f, 1.0f), 所以为灰色
    glClearColor(0.8f, 0.8f, 0.8f, 1.0f);
    //    glClear(GL_COLOR_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
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
    glVertexAttribPointer(_textureSlot,  2, GL_FLOAT, GL_FALSE, 0, Texture);
    
    
    [self renderTexture];
    
    
    GLKMatrix4 view       = GLKMatrix4MakeTranslation(0.0, 0.0, _objectZ);
    glUniformMatrix4fv(_view,  1, GL_FALSE, view.m);
    
#if 1
    //设置透视投影
    /*
     *  fovyRadians: 设置观察空间的大小
     *  aspect     : 设置宽高比
     *  nearZ      : 设置平截头体的近平面
     *  farZ       : 设置平截头体的远平面
     *  在近平面和远平面内且处于平截头体内的顶点才会被渲染
     */
    GLKMatrix4 projection = GLKMatrix4MakePerspective(45.0f, _width / _height, 0.1f, 100.0f);
    glUniformMatrix4fv(_projection, 1, GL_FALSE, projection.m);
#else
    
    //设置正射投影
    /*
     *  由上、下、左、右、近平面、远平面控制平截面的区域
     */
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(1, -1, 1, -1, 0.1f, 100.0f);
    glUniformMatrix4fv(_projection, 1, GL_FALSE, projection.m);
#endif
    
    //循环创建10个立方体
    for(int i = 0; i < 10; i++) {
        
        CGFloat angle = 20.0f * i;
        
        GLKMatrix4 model      = GLKMatrix4MakeTranslation(cubePositions[i][0] * 2.0f,
                                                          cubePositions[i][1] * 2.0f,
                                                          cubePositions[i][2] * 2.0f);
        
        model = GLKMatrix4Rotate(model, angle, 1.0f, 0.3f, 0.5f);
        glUniformMatrix4fv(_model, 1, GL_FALSE, model.m);
        
        glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, Indices);
    }
    
    //把缓冲区的数据呈现到UIView上
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)renderTexture {
    
    //使用纹理单元
    glActiveTexture(GL_TEXTURE0);
    //绑定纹理对象
    glBindTexture(GL_TEXTURE_2D, _texture);
    //这里的参数要对应纹理单元(如果纹理单元为0,这里也要给0)
    glUniform1i(_textureUniform, 0);
    
    
    //使用纹理单元
    glActiveTexture(GL_TEXTURE1);
    //绑定纹理对象
    glBindTexture(GL_TEXTURE_2D, _texture1);
    //这里的参数要对应纹理单元(如果纹理单元为0,这里也要给0)
    glUniform1i(_textureUniform1, 1);
}

#pragma mark - Other

- (void)createOperationView {
    
    _infoView = [[NSBundle mainBundle]
                     loadNibNamed:@"CoordinateSystemInfoView"
                     owner:nil
                     options:nil][0];
    
    _infoView.frame = CGRectMake(0, 0, _width, 250.0f);
    
    [self addSubview:_infoView];
    

    _infoView.objectZ = _objectZ;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint  point = [touch locationInView:[touch view]];
    
    _touchPoint = point;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    
    _objectZ += ((point.y - _touchPoint.y)/100.0);
    
    _infoView.objectZ = _objectZ;
    
    _touchPoint = point;
}

#pragma mark - Dealloc
- (void)dealloc {
    
    glDisableVertexAttribArray(_positionSlot);
    glDisableVertexAttribArray(_textureSlot);
    
    glDeleteTextures(1, &_texture);
    glDeleteTextures(1, &_texture1);
    glBindTexture(GL_TEXTURE_2D, 0);
}

@end
