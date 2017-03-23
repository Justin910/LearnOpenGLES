//
//  JZMatrix4.h
//  LearnOpenGLES
//
//  Created by aj on 2017/3/21.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#ifndef JZMatrix4_h
#define JZMatrix4_h

#include "JZMatrixTypes.h"

//创建初等矩阵
JZMatrix4 JZMatrix4Identity(void){
    
    JZMatrix4 m = { 1, 0, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 0, 0, 1,};
    return m;
}


JZMatrix4 JZMatrix4MakeTranslation(float tx, float ty, float tz) {

    JZMatrix4 m = JZMatrix4Identity();
    m.m30 = tx;
    m.m31 = ty;
    m.m32 = tz;
    return m;
}

JZMatrix4 JZMatrix4MakeScale(float sx, float sy, float sz)
{
    JZMatrix4 m = JZMatrix4Identity();
    m.m00   = sx;
    m.m11   = sy;
    m.m22   = sz;
    return m;
}

JZMatrix4 JZMatrix4Translate(JZMatrix4 matrix, float tx, float ty, float tz) {
    
    JZMatrix4 m = { matrix.m[0],matrix.m[1], matrix.m[2], matrix.m[3],
                    matrix.m[4],matrix.m[5], matrix.m[6], matrix.m[7],
                    matrix.m[8],matrix.m[9],matrix.m[10],matrix.m[11],
                    matrix.m[0] * tx + matrix.m[4] * ty + matrix.m[8]  * tz + matrix.m[12],
                    matrix.m[1] * tx + matrix.m[5] * ty + matrix.m[9]  * tz + matrix.m[13],
                    matrix.m[2] * tx + matrix.m[6] * ty + matrix.m[10] * tz + matrix.m[14],
                    matrix.m[3] * tx + matrix.m[7] * ty + matrix.m[11] * tz + matrix.m[15]
    };
    return m;
}


#endif /* JZMatrix4_h */
