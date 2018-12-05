//
//  GDorisPhotoZoomAnimatedTransition.h
//  GDoris
//
//  Created by GIKI on 2018/8/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GDorisZoomGestureHandlerProtocol <NSObject>

@optional
- (void)beginGestureHandler:(CGFloat)progress;
- (void)endGestureHandler:(BOOL)isCanceled;
- (CGRect)gestureEffectiveFrame;
@end

@protocol GDorisZoomPresentingControllerProtocol <GDorisZoomGestureHandlerProtocol>
@optional
- (__kindof UIView *)presentingView;
- (__kindof UIView *)presentingViewAtIndex:(NSInteger)index;
@end

@protocol GDorisZoomPresentedControllerProtocol <GDorisZoomGestureHandlerProtocol>
@optional
- (__kindof UIView *)presentedView;
- (NSInteger)indexOfPresentedView;
- (__kindof UIView *)presentedBackgroundView;
- (__kindof UIScrollView *)presentedScrollView;
@end

@interface GDorisPhotoZoomAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

+ (instancetype)zoomAnimatedWithPresenting:(UIViewController<GDorisZoomPresentingControllerProtocol> *)presentingController
                                 presented:(UIViewController<GDorisZoomPresentedControllerProtocol> *)presentedController;
/**
 transtionDuration
 default:0.25
 */
@property (nonatomic, assign) NSTimeInterval  transtionDuration;

/**
 translationDistance
 default: controller.view.width
 */
@property (nonatomic, assign) CGFloat translationDistance;

/**
 zoom转场后是否隐藏转场View
 default: NO
 */
@property (nonatomic, assign) BOOL  hiddenFromTargetView;

/**
 是否开启拖拽手势
 default: YES
 */
@property (nonatomic, assign) BOOL  draggingEnable;

/**
 是否开启向上拖拽 Dismiss
 default: YES
 */
@property (nonatomic, assign) BOOL  draggingUpEnable;

@end

