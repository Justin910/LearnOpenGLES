//
//  OpenGLES_3DTransform_OperationView.m
//  LearnOpenGLES
//
//  Created by aj on 2017/3/20.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import "OpenGLES_3DTransform_OperationView.h"

@implementation OpenGLES_3DTransform_OperationView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
}

- (IBAction)takeShouldTransformModeFrom:(UISegmentedControl *)sender {
    
    if(self.transformModeBlock) {
        self.transformModeBlock(sender.tag, sender.selectedSegmentIndex);
    }
}

- (IBAction)takeShouldTransformFrom:(UISlider *)sender {
    
    if(self.transformBlock) {
        self.transformBlock(sender.tag, sender.value);
    }
}

- (void)dealloc {
    
}


@end
