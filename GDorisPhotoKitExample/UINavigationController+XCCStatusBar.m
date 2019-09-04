//
//  UINavigationController+XCCStatusBar.m
//  XCChat
//
//  Created by GIKI on 2019/4/28.
//  Copyright © 2019年 xiaochuankeji. All rights reserved.
//

#import "UINavigationController+XCCStatusBar.h"

@implementation UINavigationController (XCCStatusBar)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[self topViewController] preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [[self topViewController] preferredStatusBarUpdateAnimation];
}

- (BOOL)prefersStatusBarHidden
{
    return [[self topViewController] prefersStatusBarHidden];
}

@end
