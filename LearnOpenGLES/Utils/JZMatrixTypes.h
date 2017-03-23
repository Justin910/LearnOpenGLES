//
//  JZMatrixTypes.h
//  LearnOpenGLES
//
//  Created by aj on 2017/3/21.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#ifndef JZMatrixTypes_h
#define JZMatrixTypes_h

union _JZMatrix4
{
    struct
    {
        float m00, m01, m02, m03;
        float m10, m11, m12, m13;
        float m20, m21, m22, m23;
        float m30, m31, m32, m33;
    };
    float m[16];
} __attribute__((aligned(16)));
typedef union _JZMatrix4 JZMatrix4;




#endif /* JZMatrixTypes_h */
