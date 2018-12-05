//
//  GDorisPhotoZoomAnimatedTransition.m
//  GDoris
//
//  Created by GIKI on 2018/8/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisScrollerPanGesutreRecognizer.h"

CGRect GImageAspectFitRectForSize(UIImage *image, CGSize size){
    CGFloat targetAspect = size.width / size.height;
    CGFloat sourceAspect = image.size.width / image.size.height;
    CGRect rect = CGRectZero;
    
    if (targetAspect > sourceAspect) {
        rect.size.height = size.height;
        rect.size.width = ceilf(rect.size.height * sourceAspect);
        rect.origin.x = ceilf((size.width - rect.size.width) * 0.5);
    }
    else {
        rect.size.width = size.width;
        rect.size.height = ceilf(rect.size.width / sourceAspect);
        rect.origin.y = ceilf((size.height - rect.size.height) * 0.5);
    }
    
    return rect;
}

@interface GDorisPhotoZoomAnimatedTransition ()
@property (nonatomic, weak  ) UIViewController<GDorisZoomPresentingControllerProtocol> * presentingController;
@property (nonatomic, weak  )  UIViewController<GDorisZoomPresentedControllerProtocol> * presentedController;
@property (nonatomic, assign) BOOL  isPresenting;
@property (nonatomic, assign) BOOL  isInteraction;
@property (nonatomic, strong) GDorisScrollerPanGesutreRecognizer *panGesture;
@end

@implementation GDorisPhotoZoomAnimatedTransition

+ (instancetype)zoomAnimatedWithPresenting:(UIViewController<GDorisZoomPresentingControllerProtocol> *)presentingController presented:(UIViewController<GDorisZoomPresentedControllerProtocol> *)presentedController
{
    GDorisPhotoZoomAnimatedTransition * transition = [[GDorisPhotoZoomAnimatedTransition alloc] initWithPresenting:presentingController presented:presentedController];
    return transition;
}

- (instancetype)initWithPresenting:(UIViewController<GDorisZoomPresentingControllerProtocol> *)presentingController presented:(UIViewController<GDorisZoomPresentedControllerProtocol> *)presentedController
{
    if (self = [super init]) {

        NSAssert(presentedController.modalPresentationStyle = UIModalPresentationCustom, @"presentedController 的modalPresentationStyle 必须为UIModalPresentationCustom");
        self.presentedController = presentedController;
        self.presentingController = presentingController;
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    self.transtionDuration = 0.25;
    self.translationDistance = CGRectGetWidth(self.presentedController.view.bounds);
    self.draggingEnable = YES;
    self.draggingUpEnable = YES;
    self.hiddenFromTargetView = YES;
}

- (void)addPanGesture
{
    self.panGesture = [[GDorisScrollerPanGesutreRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGesture.delegate = self;
    [self.presentedController.view addGestureRecognizer:self.panGesture];
}

- (void)removePanGesture
{
    if (self.panGesture && [self.presentedController.view.gestureRecognizers containsObject:self.panGesture]) {
        [self.presentedController.view removeGestureRecognizer:self.panGesture];
        self.panGesture = nil;
    }
}

- (void)setDraggingEnable:(BOOL)draggingEnable
{
    _draggingEnable = draggingEnable;
    if (draggingEnable) {
        [self removePanGesture];
        [self addPanGesture];
    } else {
        [self removePanGesture];
    }
}

#pragma mark - handlePanGestureRecognizer

- (void)processModalViewHidden:(BOOL)hidden
{
    if (!self.hiddenFromTargetView) return;
    
    UIViewController<GDorisZoomPresentingControllerProtocol> *toVC = self.presentingController;
    UIViewController<GDorisZoomPresentedControllerProtocol> *fromVC = self.presentedController;

    if ([toVC respondsToSelector:@selector(presentingViewAtIndex:)] && [fromVC respondsToSelector:@selector(indexOfPresentedView)]) {
        NSInteger index = [fromVC indexOfPresentedView];
        UIView * presentingView = [toVC presentingViewAtIndex:index];
        if(presentingView) presentingView.hidden = hidden;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateFailed ) {
        return;
    }
    CGPoint translationPoint = [recognizer translationInView:self.presentedController.view];
    
    if (!self.draggingEnable) return;
    UIView *presentedView = self.presentedController.view;
    if ([self.presentedController respondsToSelector:@selector(presentedView)]) {
        if (self.presentedController.presentedView.frame.size.height <= presentedView.frame.size.height) {
            presentedView = self.presentedController.presentedView;
        } else {
            presentedView = self.presentedController.presentedView.superview;
        }
    }
    UIView * backgroundView = self.presentedController.view;
    if ([self.presentedController respondsToSelector:@selector(presentedBackgroundView)]) {
        backgroundView = self.presentedController.presentedBackgroundView;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint locationPoint = [recognizer locationInView:self.presentedController.view];
        BOOL canGesure = [self canGestureEffective:locationPoint];
        if (!canGesure) {
            recognizer.state = UIGestureRecognizerStateFailed;
            return;
        }
        self.isInteraction = YES;
        if (self.hiddenFromTargetView) {
            [self processModalViewHidden:YES];
        }
    } else if(recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat progress = sqrt(pow(translationPoint.x, 2) + pow(translationPoint.y, 2)) / self.translationDistance;
        progress = MIN(1.0, MAX(0.0, progress));
        presentedView.transform = CGAffineTransformIdentity;
        presentedView.transform = CGAffineTransformScale(CGAffineTransformTranslate(CGAffineTransformIdentity, translationPoint.x, translationPoint.y), 1 - progress / 2., 1 - progress / 2.);
        [self processBeginGestureHandler:progress];
        if (!self.draggingUpEnable && translationPoint.y < 0) {
            backgroundView.backgroundColor = [backgroundView.backgroundColor colorWithAlphaComponent:1.f];
        } else {
            if (progress > 0.3) {
                CGFloat alpha = MAX((1 - progress+0.25), 0.45);
                backgroundView.backgroundColor = [backgroundView.backgroundColor colorWithAlphaComponent:alpha];
            }
        }
    }  else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat progress = sqrt(pow(translationPoint.x, 2) + pow(translationPoint.y, 2)) / self.translationDistance;
        progress = MIN(1.0, MAX(0.0, progress));
        if ((!self.draggingUpEnable && translationPoint.y < 0) || progress <= 0.5) {
            [UIView animateWithDuration:0.2 animations:^{
                backgroundView.backgroundColor = [backgroundView.backgroundColor colorWithAlphaComponent:1.f];
                presentedView.transform = CGAffineTransformIdentity;
            }];
            [self processModalViewHidden:NO];
            [self processEndGestureHandler:YES];
        } else {
            [self processEndGestureHandler:NO];
            [self.presentedController dismissViewControllerAnimated:YES completion:nil];
        }
        self.isInteraction = NO;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer
{
    if ([self.presentedController respondsToSelector:@selector(presentedScrollView)]) {
        self.panGesture.scrollview = self.presentedController.presentedScrollView;
    }
    return recognizer == self.panGesture;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.presentedController respondsToSelector:@selector(presentedScrollView)]) {
        UIScrollView * scrollview = self.presentedController.presentedScrollView;
        if (scrollview.scrollEnabled) {
            if (scrollview.contentSize.height > self.presentedController.view.frame.size.height) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.presentedController respondsToSelector:@selector(presentedScrollView)]) {
        UIScrollView * scrollview = self.presentedController.presentedScrollView;
        if (scrollview.scrollEnabled) {
            if (scrollview.contentSize.height > self.presentedController.view.frame.size.height) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)processBeginGestureHandler:(CGFloat)progress
{
    if (self.presentedController && [self.presentedController respondsToSelector:@selector(beginGestureHandler:)]) {
        [self.presentedController beginGestureHandler:progress];
    }
}

- (void)processEndGestureHandler:(BOOL)isCanceled
{
    if (self.presentedController && [self.presentedController respondsToSelector:@selector(endGestureHandler:)]) {
        [self.presentedController endGestureHandler:isCanceled];
    }
}

- (BOOL)canGestureEffective:(CGPoint)point
{
    if (self.presentedController && [self.presentedController respondsToSelector:@selector(gestureEffectiveFrame)]) {
        CGRect effective = [self.presentedController gestureEffectiveFrame];
        if (CGRectEqualToRect(effective, CGRectZero)) {
            return YES;
        } else {
            BOOL contains = CGRectContainsPoint(effective, point);
            return contains;
        }
    }
    return YES;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return self.transtionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresenting) {
        [self presentZoomTransition:transitionContext];
    } else {
        [self dismissZoomTransition:transitionContext];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isPresenting = YES;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isPresenting = NO;
    return self;
}


#pragma mark - zoom animated

- (void)presentZoomTransition:(id<UIViewControllerContextTransitioning>)transitioning
{
    UIViewController * fromViewController = (id)[transitioning viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toViewController = (id)[transitioning viewControllerForKey:UITransitionContextToViewControllerKey];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIView *containerView = [transitioning containerView];
    UIColor *windowBackgroundColor = [window backgroundColor];
    window.backgroundColor = [UIColor blackColor];
    
    UIView *fromTargetView = self.presentingController.view;
    if ([self.presentingController respondsToSelector:@selector(presentingView)]) {
        UIView * presentingView = self.presentingController.presentingView;
        if (presentingView) {
            fromTargetView = presentingView;
        }
    }
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.frame = [containerView convertRect:fromTargetView.frame fromView:fromTargetView];
    [containerView addSubview:imageView];
    [containerView sendSubviewToBack:[fromViewController view]];
    
    CGRect finalFrame = [transitioning finalFrameForViewController:toViewController];
    CGRect transitionViewFinalFrame = CGRectZero;
    if ([fromTargetView isKindOfClass:[UIImageView class]]) {
        UIImageView * targetImage = (UIImageView * )fromTargetView;
        UIImage * image = targetImage.image;
        imageView.image = image;
        transitionViewFinalFrame = GImageAspectFitRectForSize(image, finalFrame.size);
    } else if ([fromTargetView isKindOfClass:[UIButton class]]) {
        UIButton * targetButton = (UIButton * )fromTargetView;
        UIImage * image = [targetButton imageForState:UIControlStateNormal];
        if (!image) {
            image = targetButton.currentBackgroundImage;
        }
        if (image) {
            imageView.image = image;
            transitionViewFinalFrame = GImageAspectFitRectForSize(image, finalFrame.size);
        } else {
            image = [self captureView:targetButton];
            imageView.image = image;
            transitionViewFinalFrame = GImageAspectFitRectForSize(image, finalFrame.size);
        }
    } else {
        UIImage * image = [self captureView:fromTargetView];
        imageView.image = image;
        transitionViewFinalFrame = GImageAspectFitRectForSize(image, finalFrame.size);
    }

    NSTimeInterval duration = [self transitionDuration:transitioning];
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         fromViewController.view.alpha = 0;
                         imageView.frame = transitionViewFinalFrame;
                     }
                     completion:^(BOOL finished) {
                         window.backgroundColor = windowBackgroundColor;
                         fromViewController.view.alpha = 1;
                         [imageView removeFromSuperview];
                         if (![transitioning transitionWasCancelled]) {
                             [containerView addSubview:[toViewController view]];
                         }
                         [transitioning completeTransition:![transitioning transitionWasCancelled]];
                     }];
}

- (void)dismissZoomTransition:(id<UIViewControllerContextTransitioning>)transitioning
{
    UIViewController * fromViewController = (id)[transitioning viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toViewController = (id)[transitioning viewControllerForKey:UITransitionContextToViewControllerKey];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIView *containerView = [transitioning containerView];
    UIColor *windowBackgroundColor = [window backgroundColor];
    
    toViewController.view.frame = [transitioning finalFrameForViewController:toViewController];

    UIViewController<GDorisZoomPresentingControllerProtocol> *toVC = self.presentingController;
    UIViewController<GDorisZoomPresentedControllerProtocol> *fromVC = self.presentedController;
    
    if ([fromViewController modalPresentationStyle] == UIModalPresentationNone) {
        toViewController.view.alpha = 0;
        window.backgroundColor = [UIColor blackColor];
        [containerView addSubview:[toViewController view]];
        [containerView sendSubviewToBack:[toViewController view]];
    }
    
    UIView *toTargetView = self.presentingController.view;
    UIView *fromTargetView = self.presentedController.view;
    if ([fromVC respondsToSelector:@selector(indexOfPresentedView)] && [toVC respondsToSelector:@selector(presentingViewAtIndex:)]) {
        NSInteger index = [fromVC indexOfPresentedView];
        toTargetView = [toVC presentingViewAtIndex:index];
    }
    if ([fromVC respondsToSelector:@selector(presentedView)]) {
        fromTargetView = fromVC.presentedView;
    }
    UIImage * fromImage = nil;
    if ([fromTargetView isKindOfClass:[UIImageView class]]) {
        UIImageView * targetImage = (UIImageView * )fromTargetView;
        fromImage = targetImage.image;
    } else if ([fromTargetView isKindOfClass:[UIButton class]]) {
        UIButton * targetButton = (UIButton * )fromTargetView;
        fromImage = [targetButton imageForState:UIControlStateNormal];
        if (!fromImage) {
            fromImage = targetButton.currentBackgroundImage;
        }
        if (!fromImage) {
            fromImage = [self captureView:targetButton];
        }
    } else {
        fromImage = [self captureView:fromTargetView];
    }
    CGRect startTransitionFrame = GImageAspectFitRectForSize(fromImage, fromTargetView.bounds.size);
    startTransitionFrame = [containerView convertRect:startTransitionFrame fromView:fromTargetView];
    
    CGRect needTransitionFrame = [containerView convertRect:toTargetView.bounds fromView:toTargetView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:fromImage];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = toTargetView.layer.cornerRadius;
    imageView.layer.borderWidth = toTargetView.layer.borderWidth;
    imageView.layer.borderColor = toTargetView.layer.borderColor;
    imageView.clipsToBounds = YES;
    if (!CGRectIsEmpty(startTransitionFrame)) {
        imageView.frame = startTransitionFrame;
    }
    [containerView addSubview:imageView];
    fromTargetView.hidden = YES;
    if (self.hiddenFromTargetView) {
        toTargetView.hidden = YES;
    }
    NSTimeInterval duration = [self transitionDuration:transitioning];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         toViewController.view.alpha = 1.f;
                         fromViewController.view.alpha = 0.f;
                         imageView.frame = needTransitionFrame;
                     } completion:^(BOOL finished) {
                         
                         window.backgroundColor = windowBackgroundColor;
                         [imageView removeFromSuperview];
                         if (self.hiddenFromTargetView) {
                             toTargetView.hidden = NO;
                         }
                         if ([transitioning transitionWasCancelled]) {
                             fromTargetView.hidden = NO;
                             fromViewController.view.alpha = 1.f;
                             [toViewController.view removeFromSuperview];
                         }
                         [transitioning completeTransition:![transitioning transitionWasCancelled]];
                     }];
}

#pragma mark - help Method


- (__kindof UIViewController *)getZoomTransitionController:(UIViewController *)controller
{
    UIViewController *zoomVC = nil;
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController * tabbar = (UITabBarController *)controller;
        zoomVC = (id)tabbar.selectedViewController;
        if ([zoomVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController * nav = (UINavigationController *)zoomVC;
            zoomVC = (id)nav.topViewController;
        }
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController * nav = (UINavigationController *)controller;
        zoomVC = (id)nav.topViewController;
    } else {
        zoomVC = (id)controller;
    }
    return zoomVC;
}

- (UIImage *)captureView:(UIView *)view
{
    return [self captureView:view withFrame:view.bounds];
}

- (UIImage *)captureView:(UIView *)view withFrame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, CGRectZero)) {
        return nil;
    }
    BOOL temp = YES;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        temp = [view drawViewHierarchyInRect:frame afterScreenUpdates:NO];
    }else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!temp) {
        return nil;
    }
    return image;
}
@end

