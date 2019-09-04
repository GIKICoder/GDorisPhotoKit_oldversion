//
//  GScrollerGestureTransition.h
//  GScrollerGestureContainer
//
//  Created by GIKI on 2019/8/20.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ScrollerTransitionState) {
    ScrollerTransitionStateTop = 0,
    ScrollerTransitionStateBottom,
    ScrollerTransitionStateSuspend
};

@protocol GScrollerGestureTransitionDelegate <NSObject>
@optional
- (void)transitionChangedStateFinish:(ScrollerTransitionState)state offsetY:(CGFloat)offsetY animated:(BOOL)animated;
- (void)transitionChangedState:(ScrollerTransitionState)state offsetY:(CGFloat)offsetY;
- (void)transitionChangedStateBegin:(ScrollerTransitionState)state offsetY:(CGFloat)offsetY;
@end

@interface GScrollerGestureTransition : NSObject

+ (instancetype)transitionWithTargetView:(__kindof UIView*)targetView scroller:(__kindof UIScrollView *)scroller;

/**
 如果有scrollView需要处理scrollveiw滑动事件.
 在scrollview delegate方法中调用如下方法即可

 @param scrollView <#scrollView description#>
 */
- (void)__scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)__scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)__scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)transitionMove:(ScrollerTransitionState)state;
- (void)transitionMove:(ScrollerTransitionState)state animated:(BOOL)animated completion:(void (^__nullable)(void))completion;

@property (nonatomic, weak  ) id<GScrollerGestureTransitionDelegate>   delegate;

/**
 是否允许位置悬停效果
 如果允许,则滑动手势有三种状态,置顶->悬停->hidden
 如果禁止,则滑动手势只有置顶or隐藏
 Default:NO
 */
@property (nonatomic, assign) BOOL  allowSuspendPosition;

/**
 置顶状态位置
 Default:0
 */
@property (nonatomic, assign) CGFloat  transitionTopPosition;

/**
 下滑退出置顶状态的位置
 */
@property (nonatomic, assign) CGFloat  transitionBottomPosition;

/**
 悬停状态位置
 只有在 allowSuspendPosition->YES的情况下生效
 Default:0
 */
@property (nonatomic, assign) CGFloat  transitionSuspendPosition;

/**
 开始进入Transition State改变的位置
 */
@property (nonatomic, assign) CGFloat  beginTransitionPosition;

/**
 是否开启震动反馈
 */
@property (nonatomic, assign) BOOL  feedBackEnabled;
@end

NS_ASSUME_NONNULL_END
