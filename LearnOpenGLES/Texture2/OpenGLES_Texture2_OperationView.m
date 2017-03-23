
//
//  OpenGLES_Texture2_OperationView.m
//  LearnOpenGLES
//
//  Created by aj on 2017/3/16.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import "OpenGLES_Texture2_OperationView.h"
#import <OpenGLES/ES3/gl.h>

@implementation OpenGLES_Texture2_OperationView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
}

- (IBAction)takeShouldfilterModeFrom:(UISegmentedControl *)sender {
    
    if(self.filterModeBlock) {
        
        NSInteger selectIndex = sender.selectedSegmentIndex;
        
        self.filterModeBlock(selectIndex ? GL_LINEAR : GL_NEAREST);
    }
}

- (IBAction)takeShouldCycleModeFrom:(UISegmentedControl *)sender {
    
    if(self.cycleModeBlock) {
        
        NSInteger selectIndex = sender.selectedSegmentIndex;
        
        int mode = 0;
        
        if(selectIndex == 0) {
            mode = GL_REPEAT;
        }else if(selectIndex == 1) {
            mode = GL_MIRRORED_REPEAT;
        }else {
            mode = GL_CLAMP_TO_EDGE;
        }
        
        self.cycleModeBlock(mode);
    }
}

- (IBAction)takeSCoordinateOffsetFrom:(UISlider *)sender {
    
    if(self.coordinateOffsetBlock) {
        self.coordinateOffsetBlock(sender.value);
    }
}


@end
