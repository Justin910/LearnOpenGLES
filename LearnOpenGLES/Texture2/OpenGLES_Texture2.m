//
//  OpenGLES_Texture2.m
//  LearnOpenGLES
//
//  Created by aj on 2017/3/15.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import "OpenGLES_Texture2.h"
#import "TextureManager.h"
#import "OpenGLES_Texture2_OperationView.h"

@interface OpenGLES_Texture2 (){
    
    GLuint _positionSlot;   //着色器中的顶点变量
    GLuint _textureSlot;    //着色器中的纹理变量
    
    GLuint _textureUniform; //纹理单元
    GLuint _texture;        //纹理对象
    
    
    GLfloat _sCoordinateOffset; //纹理坐标偏移
    GLint   _filterMode;        //过滤模式
    GLint   _cycleMode;         //循环模式
    
    
    GLfloat _uCoordinateOffset;
}

@end

//4个顶点(分别表示xyz轴)
static const float Vertices[] = {
    
//    x    y    z
    -0.7, -0.7, 0,  //左下
     0.7, -0.7, 0,  //右下
    -0.7,  0.7, 0,  //左上
     0.7,  0.7, 0,  //右上
};



static float Texture[] = {
    
     0,  0,
     1,  0,
     0,  1,
     1,  1,
};

static float DefaultTexture[] = {
    
     0,  0,
     1,  0,
     0,  1,
     1,  1,
};

@implementation OpenGLES_Texture2

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _sCoordinateOffset = 0.0f;
        _filterMode        = GL_REPEAT;
        _cycleMode         = GL_NEAREST;
        
        [self createOperationView];
        
        [self setupLayer];
        [self setupContext];
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
    GLuint vertexShader   = [self compileShader:@"Texture2Vertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"Texture2Fragment" withType:GL_FRAGMENT_SHADER];
    
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
    _textureSlot  = glGetAttribLocation(_program, "TexCoordIn");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_textureSlot);
    
    
    _textureUniform  = glGetUniformLocation(_program, "ourTexture");
    _texture = [TextureManager getTextureImageName:@"Texture2_1.png"];
    
    
    _uCoordinateOffset = glGetUniformLocation(_program, "uCoordinateOffset");
}

- (void)render:(CADisplayLink *)displayLink {
    
    //用指定的颜色清除,清除颜色被设置为(0.5f, 0.5f, 0.5f, 1.0f), 所以为黑色
    glClearColor(0.8f, 0.8f, 0.8f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //设定窗口的范围(如果不是很明白, 可以自己动手修改下试试)
    //他这个是左下角为(0,0) 右上角为(width,height)
    glViewport(0, 0, _width, _width);
    
    
    
    for(int i = 0; i < sizeof(Texture) / sizeof(float); i+=2 ) {
        Texture[i] = DefaultTexture[i] + _sCoordinateOffset;
    }
    
    
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
    
    //使用纹理单元
    glActiveTexture(GL_TEXTURE0);
    //绑定纹理对象
    glBindTexture(GL_TEXTURE_2D, _texture);
    //这里的参数要对应纹理单元(如果纹理单元为0,这里也要给0)
    glUniform1i(_textureUniform, 0);
    
    //设置纹理循环模式
    [TextureManager setParameterTextureName:_texture
                                     target:GL_TEXTURE_2D
                                      pname:GL_TEXTURE_WRAP_S
                                    paramID:_cycleMode];
    [TextureManager setParameterTextureName:_texture
                                     target:GL_TEXTURE_2D
                                      pname:GL_TEXTURE_WRAP_T
                                    paramID:_cycleMode];
    
    //设置纹理过滤模式
    [TextureManager setParameterTextureName:_texture
                                     target:GL_TEXTURE_2D
                                      pname:GL_TEXTURE_MIN_FILTER
                                    paramID:_filterMode];
    
    [TextureManager setParameterTextureName:_texture
                                     target:GL_TEXTURE_2D
                                      pname:GL_TEXTURE_MAG_FILTER
                                    paramID:_filterMode];
        
    // Uniforms
    glUniform2f(_uCoordinateOffset, _sCoordinateOffset, _sCoordinateOffset);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(Vertices) / (sizeof(float) * 3));
    
    //把缓冲区的数据呈现到UIView上
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - Other

- (void)createOperationView {
    
    OpenGLES_Texture2_OperationView *view = [[NSBundle mainBundle]
                                             loadNibNamed:@"OpenGLES_Texture2_OperationView"
                                             owner:nil
                                             options:nil][0];
    
    view.frame = CGRectMake(0, 0, _width, 200.0f);
    
    [self addSubview:view];
    
    view.filterModeBlock       = [self modifyfilterMode];
    view.cycleModeBlock        = [self modifyCycleMode];
    view.coordinateOffsetBlock = [self modifyCoordinateOffset];
}


- (TextureModeCallBackBlock)modifyfilterMode{
    
    typeof(self) __weak _weakSelf = self;
    return ^(int value) {
        typeof(_weakSelf) __strong _strongSelf = _weakSelf;
        
        _strongSelf->_filterMode = value;
    };
}
- (TextureModeCallBackBlock)modifyCycleMode {
    
    typeof(self) __weak _weakSelf = self;
    return ^(int value) {
        typeof(_weakSelf) __strong _strongSelf = _weakSelf;
        
        _strongSelf->_cycleMode = value;
    };
}
- (TextureModeCallBackBlock)modifyCoordinateOffset {
    
    typeof(self) __weak _weakSelf = self;
    return ^(int value){
        typeof(_weakSelf) __strong _strongSelf = _weakSelf;
        
        _strongSelf->_sCoordinateOffset = value / 100.0;
    };
}


#pragma mark - Dealloc
- (void)dealloc {
    
    glDisableVertexAttribArray(_positionSlot);
    glDisableVertexAttribArray(_textureSlot);
    
    glDeleteTextures(1, &_texture);
    
    glBindTexture(GL_TEXTURE_2D, 0);
}


@end
