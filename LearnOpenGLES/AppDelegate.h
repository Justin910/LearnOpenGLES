//
//  AppDelegate.h
//  LearnOpenGLES
//
//  Created by aj on 2017/2/21.
//  Copyright © 2017年 Zhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

