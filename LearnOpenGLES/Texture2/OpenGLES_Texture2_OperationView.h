//
//  OpenGLES_Texture2_OperationView.h
//  LearnOpenGLES
//
//  Created by aj on 2017/3/16.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TextureModeCallBackBlock)(int value);

@interface OpenGLES_Texture2_OperationView : UIView

@property (nonatomic, copy) TextureModeCallBackBlock filterModeBlock;
@property (nonatomic, copy) TextureModeCallBackBlock cycleModeBlock;
@property (nonatomic, copy) TextureModeCallBackBlock coordinateOffsetBlock;

@end
