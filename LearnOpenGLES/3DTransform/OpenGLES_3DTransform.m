//
//  OpenGLES_3DTransform.m
//  LearnOpenGLES
//
//  Created by aj on 2017/3/20.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import "OpenGLES_3DTransform.h"
#import <GLKit/GLKit.h>

#import "OpenGLES_3DTransform_OperationView.h"

@interface OpenGLES_3DTransform (){
    
    GLuint _depthRenderBuffer;  //深度缓冲
    
    GLuint _positionSlot;   //着色器中的顶点变量
    GLuint _colorSlot;      //着色器中的颜色变量
    
    GLuint _modelView;
    
    NSInteger _transformMode;   //当前操作的模式（缩放，位移，旋转）
    
    CGFloat _transformScale[3];         //缩放模式的XYZ轴
    CGFloat _transformTranslation[3];   //位移模式的XYZ轴
    CGFloat _transformRotation[3];      //旋转模式的XYZ轴
}

@end

//4个顶点(分别表示xyz轴)
static const float Vertices[] = {
    
    //前面4个坐标
    -0.5, -0.5,  0.5,
     0.5, -0.5,  0.5,
    -0.5,  0.5,  0.5,
     0.5,  0.5,  0.5,
    
    //后面4个坐标
    -0.5, -0.5, -0.5,
     0.5, -0.5, -0.5,
    -0.5,  0.5, -0.5,
     0.5,  0.5, -0.5,
    
    //后面4个坐标
    -0.5, -0.5, -0.5,
     0.5, -0.5, -0.5,
    -0.5,  0.5, -0.5,
     0.5,  0.5, -0.5,
};

//4个点的颜色(分别表示RGBA值)
static const float Colors[] = {
    
    1, 0, 0, 1,
    0, 1, 0, 1,
    0, 0, 1, 1,
    0, 0, 0, 1,
    
    1, 0, 0, 1,
    0, 1, 0, 1,
    0, 0, 1, 1,
    0, 0, 0, 1,
    
    1, 0, 0, 1,
    0, 1, 0, 1,
    0, 0, 1, 1,
    0, 0, 0, 1,
};

static const GLubyte Indices[] = {
    
    0,  1,  2,
    2,  3,  1,
    
    4,  5,  6,
    6,  7,  5,
    
    2,  3,  6,
    6,  7,  3,
    
    0,  1,  4,
    4,  5,  1,
    
    0,  4,  2,
    2,  6,  4,
    
    1,  5,  3,
    3,  7,  5
};



#define PI 3.1415926535898
#define ANGLE_TO_RADIAN(angle) angle * (PI / 180.0f)

@implementation OpenGLES_3DTransform

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _transformScale[0] = 1.0;
        _transformScale[1] = 1.0;
        _transformScale[2] = 1.0;
        
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

#pragma mark - OpenGLES Related

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
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);    //new
}


/**
 *  编译着色器
 */
- (void)compileShaders {
    
    //编译顶点着色器和片段着色器
    GLuint vertexShader   = [self compileShader:@"3DTransformVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"3DTransformFragment" withType:GL_FRAGMENT_SHADER];
    
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
    
    
    _modelView = glGetUniformLocation(_program, "ModelView");
}

- (void)render:(CADisplayLink *)displayLink {
    
    //用指定的颜色清除,清除颜色被设置为(0.5f, 0.5f, 0.5f, 1.0f), 所以为灰色
    glClearColor(0.8f, 0.8f, 0.8f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //设定窗口的范围(如果不是很明白, 可以自己动手修改下试试)
    //他这个是左下角为(0,0) 右上角为(width,height)
    glViewport(0, 0, _width, _width);
    
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

    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(_transformTranslation[0],
                                                     _transformTranslation[1],
                                                     _transformTranslation[2]);
    
    modelView = GLKMatrix4Rotate(modelView, _transformRotation[0], 1, 0, 0);
    modelView = GLKMatrix4Rotate(modelView, _transformRotation[1], 0, 1, 0);
    modelView = GLKMatrix4Rotate(modelView, _transformRotation[2], 0, 0, 1);
    
    modelView = GLKMatrix4Scale(modelView,
                                _transformScale[0],
                                _transformScale[1],
                                _transformScale[2]);
    
    //给着色器变量赋值
    /*
        location :  变量的位置
        count    :  要更改变量的个数
        transpose:  是否需要转置
        value    :  给出对应count个元素的指针
    */
    glUniformMatrix4fv(_modelView, 1, GL_FALSE, modelView.m);
    
    
    
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(Vertices) / (sizeof(float) * 3));
    //绘制
    /*
     *  mode   :    绘制的方式
     *  count  :    索引数组元素的数量
     *  type   :    索引值的类型
     *  indices:    索引数组的指针
     */
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, Indices);

    
    //把缓冲区的数据呈现到UIView上
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - Other

- (void)createOperationView {
    
    OpenGLES_3DTransform_OperationView *view = [[NSBundle mainBundle]
                                             loadNibNamed:@"OpenGLES_3DTransform_OperationView"
                                             owner:nil
                                             options:nil][0];
    
    view.frame = CGRectMake(0, 0, _width, 250.0f);
    
    [self addSubview:view];
    
    view.transformModeBlock = [self modifyTransformMode];
    view.transformBlock     = [self modifyTransform];
}

- (TransformCallBackBlock)modifyTransformMode {
    
    typeof(self) __weak _weakSelf = self;
    
    return ^(NSInteger tag, NSInteger value){
        typeof(_weakSelf) __strong _strongSelf = _weakSelf;
        
        _strongSelf->_transformMode = value;
    };
}

- (TransformCallBackBlock)modifyTransform {
    
    typeof(self) __weak _weakSelf = self;
    return ^(NSInteger tag, NSInteger value){
        
        typeof(_weakSelf) __strong _strongSelf = _weakSelf;
        
        switch (_strongSelf->_transformMode) {
            case TransformMode_Scale:{//缩放
                
                _strongSelf->_transformScale[tag] = value/180.0 + 1;
            }
            break;
            case TransformMode_Translation:{//位移
                
                _strongSelf->_transformTranslation[tag] = value / 180.0;
            }
            break;
            case TransformMode_Rotation:{//旋转
                
                _strongSelf->_transformRotation[tag] = ANGLE_TO_RADIAN(value);
            }
            break;
            default:
            break;
        }
    };
}


#pragma mark - Dealloc
- (void)dealloc {
    glDisableVertexAttribArray(_positionSlot);
    glDisableVertexAttribArray(_colorSlot);
}

@end
