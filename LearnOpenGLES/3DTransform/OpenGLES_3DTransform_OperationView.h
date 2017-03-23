//
//  OpenGLES_3DTransform_OperationView.h
//  LearnOpenGLES
//
//  Created by aj on 2017/3/20.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TransformCallBackBlock)(NSInteger tag, NSInteger value);

typedef NS_ENUM(NSInteger, TransformMode) {
    
    TransformMode_Scale       = 0,
    TransformMode_Translation = 1,
    TransformMode_Rotation    = 2
};

@interface OpenGLES_3DTransform_OperationView : UIView

@property (nonatomic, copy) TransformCallBackBlock transformModeBlock;
@property (nonatomic, copy) TransformCallBackBlock transformBlock;

@end
