//
//  GNavItemFactory.h
//  GNavigationBar
//
//  Created by GIKI on 2017/4/6.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GNavigationItem;

@interface GNavItemFactory : NSObject


#pragma mark - 常用工厂

/**
 快速创建图标按钮
 */
+ (GNavigationItem *)createImageButton:(UIImage*)image highlightImage:(UIImage*)highlightImage target:(id)target selctor:(SEL)selctor;

/**
 快速创建一个文字按钮
 */
+ (GNavigationItem *)createTitleButton:(NSString*)title target:(id)target selctor:(SEL)selctor;

+ (GNavigationItem *)createTitleButton:(NSString*)title titleColor:(UIColor*)color highlightColor:(UIColor*)highlightColor target:(id)target selctor:(SEL)selctor;

+ (GNavigationItem *)createTitleButton:(NSString*)title titleColor:(UIColor*)color highlightColor:(UIColor*)highlightColor font:(UIFont*)font target:(id)target selctor:(SEL)selctor;


/**
 创建一个自定义按钮
 自定义View 需要给如size, 如不给 会自动默认size为 G_NAVI_ITEM_SIZE
 */
+ (GNavigationItem *)createCustomView:(__kindof UIView*)view;

@end
