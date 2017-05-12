//
//  CoordinateSystemInfoView.m
//  LearnOpenGLES
//
//  Created by aj on 2017/5/11.
//  Copyright © 2017年 Justin910. All rights reserved.
//

#import "CoordinateSystemInfoView.h"

@interface CoordinateSystemInfoView ()

@property (weak, nonatomic) IBOutlet UILabel *infoLabel1;

@end

@implementation CoordinateSystemInfoView

- (void)setObjectZ:(CGFloat)objectZ {
    self.infoLabel1.text = [NSString stringWithFormat:@"Z轴:%.2f", objectZ];
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

@end
