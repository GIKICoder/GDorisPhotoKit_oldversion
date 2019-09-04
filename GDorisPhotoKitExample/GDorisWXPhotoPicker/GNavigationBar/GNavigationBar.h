//
//  GNavigationBar.h
//  GNavigationBar
//
//  Created by GIKI on 2017/4/5.
//  Copyright © 2017年 GIKI. All rights reserved.

#import <UIKit/UIKit.h>
#import "GNavigationItem.h"
#import "GNavigationMacro.h"
#import "GNavItemFactory.h"


@interface GNavigationBar : UIView

+ (instancetype)navigationBar;
- (instancetype)initWithFrame:(CGRect)frame customBar:(BOOL)customBar;

/**
 左边第一个按钮
 @breif:如果左边第一个存在按钮,会替换
 */
@property (nonatomic, strong) GNavigationItem * leftNavigationItem;

/**
 右边第一个按钮
 @breif:如果右边第一个存在按钮,会替换
 */
@property (nonatomic, strong) GNavigationItem * rightNavigationItem;

/**
 左右按钮数组
 */
@property (nonatomic, strong) NSArray<GNavigationItem*> * leftNavigaitonItems;
@property (nonatomic, strong) NSArray<GNavigationItem*> * rightNavigaitonItems;

/**
 导航栏标题设置项
 */
@property (nonatomic, copy  ) NSString * title;
@property (nonatomic, strong) UIColor * titleColor;
@property (nonatomic, assign) NSLineBreakMode  titleMode;
@property (nonatomic, strong) UIFont * titleFont;

/**
 导航栏背景图片设置项
 @breif:默认为空
 */
@property (nonatomic, strong,readonly) UIImageView * backgroundImageView;

/**
 增加导航栏左按钮
 @breif:会自动追加到相应侧按钮最后
 @param item 必须为GNavigationItem类型
 */
-(void)addLeftItem:(GNavigationItem*)item;

/**
 增加导航栏右按钮
 @breif:会自动追加到相应侧按钮最后
 @param item 必须为GNavigationItem类型
 */
-(void)addRightItem:(GNavigationItem*)item;

/**
 设置导航栏中间按钮
 centerView可通过此接口自定义
 
 @param item  必须为GNavigationItem类型
 */
-(void)setCenterItem:(GNavigationItem*)item;

/**
 移除导航左右按钮
 暂未实现
 -(void)removeLeftItem;
 -(void)removeRightItem;
 */

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated complete:(dispatch_block_t)block;

- (void)setNavigationEffectWithStyle:(UIBlurEffectStyle)style;

@end
