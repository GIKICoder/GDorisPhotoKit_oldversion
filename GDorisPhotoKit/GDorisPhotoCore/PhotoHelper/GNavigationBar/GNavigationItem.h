//
//  GNavigationItem.h
//  GNavigationBar
//
//  Created by GIKI on 2017/4/5.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNavigationMacro.h"

@class GNavigationLayout;

@interface GNavigationItem : NSObject

/**
 当前导航容器内含子容器数组
 readonly ,通过addChild添加
 */
@property (nonatomic, strong) NSMutableArray<GNavigationItem *> * childern;

/**
 导航容器根视图,真正展示按钮的视图
 */
@property (nonatomic, strong) UIView * rootView;

/**
 导航容器 子容器的最小宽度
 */
@property (nonatomic, assign) CGFloat  minSubContainerWidth;

/**
 subview 自动调整frame default 为YES
 */
@property (nonatomic, assign) BOOL  subViewFrameAdjustChange;

/**
 指向父容器指针
 @breif: 弱引用
 */
@property (nonatomic, weak) GNavigationItem *superNavItemNode;

/**
 指向左兄弟容器指针
 */
@property (nonatomic, weak) GNavigationItem *leftNavItemNode;

/**
 指向右兄弟容器指针
 */
@property (nonatomic, weak) GNavigationItem *rightNavItemNode;

/**
 附着父容器的类型
 */
@property (nonatomic, assign) GNavItemAttachStyle attachStyle;

@property (nonatomic, assign) BOOL  customNavBar;

#pragma mark -- Method

/**
 构造器

 @param rootView 按钮视图
 @return GNavigationItem
 */
-(instancetype)initWithRootView:(UIView *)rootView;
-(instancetype)initWithRootView:(UIView *)rootView attachStyle:(GNavItemAttachStyle)style;
/**
 添加子容器

 @param navItem 子容器
 */
-(void)addChild:(GNavigationItem*)navItem;

/**
 导航栏子节点需要调整frame 根容器整体重新布局
 */
-(void)resetAndLayoutTheWholdContainersTree;

/**
 布局父容器
 */
- (void)layoutFatherContainers;

/**
 删除所有子容器
 */
-(void)removeAllChildContainer;

@end
