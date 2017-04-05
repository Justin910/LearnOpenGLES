//
//  RootViewController.m
//  LearnOpenGLES
//
//  Created by aj on 2017/2/21.
//  Copyright © 2017年 Zhen. All rights reserved.
//

#import "RootViewController.h"
#import "ShowViewController.h"

@interface RootViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *ctls;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    self.ctls = @[@[@"OpenGLES_Rectangle",
                    @"OpenGLES_Texture",
                    @"OpenGLES_Texture2",
                    @"OpenGLES_3DTransform",
                    @"OpenGLES_Texture3"]
                  ];
}



#pragma mark - UITableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.ctls[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.ctls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell"];
    }
    
    NSString *viewName = self.ctls[indexPath.section][indexPath.item];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld. %@", indexPath.item + 1, viewName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ShowViewController *svc = [[ShowViewController alloc] init];
    
    svc.viewName = self.ctls[indexPath.section][indexPath.item];
    
    [self.navigationController pushViewController:svc animated:YES];
}

@end
