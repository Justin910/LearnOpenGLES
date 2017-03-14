//
//  ShowViewController.m
//  LearnOpenGLES
//
//  Created by aj on 2017/2/21.
//  Copyright © 2017年 Zhen. All rights reserved.
//

#import "ShowViewController.h"
#import "ParentView.h"

@interface ShowViewController (){
    
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    ParentView *_openGLView;
}

@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _screenWidth  = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.navigationItem.title = self.viewName;
    
    [self setupOpenGLView];
}

- (void)setupOpenGLView {
    
    Class openGLViewClass = NSClassFromString(self.viewName);
    
    if([openGLViewClass isSubclassOfClass:[UIView class]]) {
        
        _openGLView = [[openGLViewClass alloc]
                        initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight - 64)];
        
        [self.view addSubview:_openGLView];
    }
}

- (void)dealloc {
    [_openGLView destroyDisplayLink];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
