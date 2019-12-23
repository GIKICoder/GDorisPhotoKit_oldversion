//
//  GNavigationItem.m
//  GNavigationBar
//
//  Created by GIKI on 2017/4/5.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import "GNavigationItem.h"


@interface GNavigationItem ()

@end

@implementation GNavigationItem

#pragma mark -- init Method


- (void)doInit
{
    _childern = [NSMutableArray array];
    //锚点
    _minSubContainerWidth = 0;
    _superNavItemNode = nil;
}

/**
 构造器
 
 @param rootView 按钮视图
 @return GNavigationItem
 */
-(instancetype)initWithRootView:(UIView *)rootView
{
    return [[GNavigationItem alloc] initWithRootView:rootView attachStyle:GNavItemAttachStyle_left];
}

-(instancetype)initWithRootView:(UIView *)rootView attachStyle:(GNavItemAttachStyle)style
{
    self = [super init];
    if (self) {
        self.subViewFrameAdjustChange = YES;
        self.rootView = rootView;
        self.attachStyle = style;
        [self doInit];
    }
    return self;
}

#pragma mark -- public Method

- (void)setRootView:(UIView *)rootView
{
    _rootView = rootView;
}

/**
 构造一个item层级树,用来计算每个item的布局

 @param navItem GNavigationItem
 */
- (void)addChild:(GNavigationItem *)navItem
{
    NSAssert([NSThread mainThread], @"不能在多线程中追加navItem");
    NSAssert(navItem.rootView, @"当前追加的item 的rootView 为nil");
    NSAssert(self.rootView, @"当前item的rootView 为nil");
    navItem.superNavItemNode = self;
    if (self.childern.count > 0) {
        navItem.leftNavItemNode = [self.childern lastObject];
        [self.childern lastObject].rightNavItemNode = navItem;
    }
    [_childern addObject:navItem];
    if (navItem.attachStyle == GNavItemAttachStyle_right) {
        GNavigationItem *superItem = [self getSuperItemNode:self];
        [superItem.rootView addSubview:navItem.rootView];
    } else {
        [self.rootView addSubview:navItem.rootView];
    }
    
    [self layoutSubContainersWithItemNode:navItem];
}

- (void)layoutFatherContainers
{
    NSAssert(self.rootView, @"当前item的rootView 为nil");
    if (self.superNavItemNode == nil) { //父容器为nil 表示为maincontainer
        [self layoutFatherContainersWithMaxWidth:0 andChildern:self.childern];
    }
}

- (void)layoutFatherContainersWithMaxWidth:(CGFloat)width andChildern:(NSArray*)childern
{
    if (childern.count > 0) {
        __block GNavigationItem *centerItem = nil;
        [childern enumerateObjectsUsingBlock:^(GNavigationItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIView *targetView = obj.rootView;
            
            switch (obj.attachStyle) {
                case GNavItemAttachStyle_left:
                    targetView.frame = CGRectMake(0, 0, width, self.rootView.frame.size.height);
                    break;
                case GNavItemAttachStyle_right:
                    targetView.frame = CGRectMake(G_SCREEN_WIDTH - width, 0, width, self.rootView.frame.size.height);
                    break;
                case GNavItemAttachStyle_center:
                    centerItem = obj;
                    targetView.frame = CGRectMake(width, 0, G_SCREEN_WIDTH - width*2, self.rootView.frame.size.height);
                    break;
                default:
                    break;
            }
        }];
        
        [self layoutCenterSubContainers:[centerItem.childern firstObject]];
    }
}

/**
 布局子容器
 */
-(void)layoutSubContainers
{
    
}

-(void)resetAndLayoutTheWholdContainersTree
{
    GNavigationItem *superItem = [self getSuperItemNode:self];
     [self layoutFatherContainersWithMaxWidth:0 andChildern:superItem.childern];
    [superItem.childern enumerateObjectsUsingBlock:^(GNavigationItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.childern.count >0) {
            [obj.childern enumerateObjectsUsingBlock:^(GNavigationItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                [self layoutSubContainersWithItemNode:item];
            }];
        }
        
    }];
}

- (void)layoutSubContainersWithItemNode:(GNavigationItem*)itemNode
{
    NSAssert(itemNode.rootView, @"当前item的rootView 为nil");
    if (self.superNavItemNode != nil) { //父容器不为nil
        
        GNavigationItem *navigationItem = itemNode.superNavItemNode;
        switch (navigationItem.attachStyle) {
            case GNavItemAttachStyle_left:
                [self layoutLeftSubContainers:itemNode];
                break;
            case GNavItemAttachStyle_right:
                [self layoutRightSubContainers:itemNode];
                break;
            case GNavItemAttachStyle_center:
                [self layoutCenterSubContainers:itemNode];
                break;
            default:
                break;
        }
        
    }

}

- (void)layoutLeftSubContainers:(GNavigationItem*)headerItem
{
    CGSize size = headerItem.rootView.frame.size;
    if (CGSizeEqualToSize(size,CGSizeZero)) {
        size = G_NAVI_ITEM_SIZE;
    }
    CGFloat left = G_NAVI_LEFT_PADDING;
    if (headerItem.leftNavItemNode != nil) {
        left = headerItem.leftNavItemNode.rootView.frame.origin.x+headerItem.leftNavItemNode.rootView.frame.size.width + G_NAVI_RIGHTITEM_PADDING;
    }
    CGFloat totoalheight = GNavBarContentHeight;
    GNavigationItem * superItem = [headerItem superNavItemNode];
    if (superItem && superItem.customNavBar) {
        totoalheight = superItem.rootView.frame.size.height;
    }
    CGRect headerRect = CGRectMake(left, (totoalheight - size.height)*0.5, size.width, size.height);
    headerItem.rootView.frame = headerRect;
    CGFloat headerRight = headerItem.rootView.frame.origin.x + headerItem.rootView.frame.size.width;
    CGFloat superRight = headerItem.superNavItemNode.rootView.frame.origin.x +headerItem.superNavItemNode.rootView.frame.size.width;
    if (headerRight > superRight) {
        NSArray *childern = [self getSuperItemNode:headerItem].childern.copy;
        [self layoutFatherContainersWithMaxWidth:headerRight +5 andChildern:childern];
    }
}

- (void)layoutRightSubContainers:(GNavigationItem*)headerItem
{
    CGSize size = headerItem.rootView.frame.size;
    if (CGSizeEqualToSize(size,CGSizeZero)) {
        size = G_NAVI_ITEM_SIZE;
    }
    
    CGFloat right = G_SCREEN_WIDTH - G_NAVI_RIGHT_PADDING;
    if (headerItem.leftNavItemNode != nil) {
        right = headerItem.leftNavItemNode.rootView.frame.origin.x  - G_NAVI_RIGHTITEM_PADDING;
    }
    GNavigationItem * superItem = [headerItem superNavItemNode];
    CGFloat totoalheight = GNavBarContentHeight;
    if (superItem && superItem.customNavBar) {
        totoalheight = superItem.rootView.frame.size.height;
    }
    CGRect headerRect = CGRectMake(right - size.width, (totoalheight - size.height)*0.5, size.width, size.height);
    headerItem.rootView.frame = headerRect;
    headerItem.rootView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; //保持右边距不变
    CGFloat headerLeft = headerItem.rootView.frame.origin.x ;
    CGFloat superLeft = headerItem.superNavItemNode.rootView.frame.origin.x ;
    if (headerLeft < superLeft) {
        NSArray *childern = [self getSuperItemNode:headerItem].childern.copy;
        [self layoutFatherContainersWithMaxWidth:G_SCREEN_WIDTH - headerLeft+5 andChildern:childern];
    }

}

- (void)layoutCenterSubContainers:(GNavigationItem*)headerItem
{
    if (!headerItem.subViewFrameAdjustChange) {
        CGSize size = headerItem.rootView.frame.size;
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            if (size.width > headerItem.superNavItemNode.rootView.frame.size.width) {
                size.width = headerItem.superNavItemNode.rootView.frame.size.width;
            }
            if (size.height > headerItem.superNavItemNode.rootView.frame.size.height) {
                size.height = headerItem.superNavItemNode.rootView.frame.size.height;
            }
            headerItem.rootView.center = CGPointMake(headerItem.superNavItemNode.rootView.frame.size.width*0.5, headerItem.superNavItemNode.rootView.frame.size.height *0.5);
            if (G_NAVI_DEBUG) {
                headerItem.rootView.backgroundColor = GNAVRandomColor;
            }
            return;
        }
       
    }
    if (headerItem.rootView && headerItem.superNavItemNode.rootView) {
        headerItem.rootView.frame = headerItem.superNavItemNode.rootView.bounds;
    }
}

- (void)removeAllChildContainer
{
    [_childern enumerateObjectsUsingBlock:^(GNavigationItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.rootView removeFromSuperview];
    }];
    
    [_childern removeAllObjects];
    [self resetAndLayoutTheWholdContainersTree];

}

#pragma mark -- private Method

- (void)layoutNavigationBarFrame
{
    
}

- (GNavigationItem *)getHeaderItemNode:(NSArray*)children
{
    if (children.count > 0) {
        return [children firstObject];
    }
    return nil;
}

- (GNavigationItem *)getNextItemNode:(GNavigationItem*)headNode
{
    if (headNode.rightNavItemNode) {
        return headNode.rightNavItemNode;
    }
    return nil;
}

- (GNavigationItem*)getPreItemNode:(GNavigationItem *)currentNode
{
    if (currentNode.leftNavItemNode) {
        return currentNode.leftNavItemNode;
    }
    return nil;
}

- (GNavigationItem *)getLastItemNode:(GNavigationItem*)headNode
{
    if (headNode.rightNavItemNode) {
        [self getLastItemNode:headNode.rightNavItemNode];
    }
    return headNode;
}

- (GNavigationItem *)getSuperItemNode:(GNavigationItem*)currentNode
{
    GNavigationItem *item = currentNode;
    while (item.superNavItemNode) {
        item = item.superNavItemNode;
    }
    return item;
}
@end

