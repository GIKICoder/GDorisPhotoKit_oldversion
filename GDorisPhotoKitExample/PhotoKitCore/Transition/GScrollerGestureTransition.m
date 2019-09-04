//
//  GScrollerGestureTransition.m
//  GScrollerGestureContainer
//
//  Created by GIKI on 2019/8/20.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GScrollerGestureTransition.h"

#define GSCROLLER_ANIMATION_SPRINGCOMP(d,a,c) [UIView animateWithDuration:d delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:a completion:c]
#define GSCROLLER_ANIMATION_SPRING(d,a)       [UIView animateWithDuration:d delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionAllowUserInteraction animations:a completion:nil]

@interface GScrollerGestureTransition()<UIGestureRecognizerDelegate>

@property (nonatomic) BOOL portrait;
/// targetScrollView
@property (nonatomic, weak  ) __kindof UIScrollView * scrollView;
/// targetView
@property (nonatomic, weak  ) __kindof UIView * targetView;
/// record targetView position
@property (nonatomic, assign) CGFloat  recordTargetPosition;
/// when scrollview scrolling, record scrollview position
@property (nonatomic, assign) CGFloat startScrollPosition;
@property (nonatomic, assign) BOOL  bottomDeceleratingDisable;
@property (nonatomic, assign) BOOL onceEnded;
@property (nonatomic, assign) BOOL scrollBegin;

@property (nonatomic, assign) ScrollerTransitionState  transitionState;
@property (nonatomic, assign) BOOL  hasFeedback;

@end

@implementation GScrollerGestureTransition

+ (instancetype)transitionWithTargetView:(__kindof UIView*)targetView scroller:(__kindof UIScrollView *)scroller
{
    GScrollerGestureTransition * transition = [[GScrollerGestureTransition alloc] initWithTargetView:targetView scroller:scroller];
    return transition;
}

- (instancetype)initWithTargetView:(__kindof UIView*)targetView scroller:(__kindof UIScrollView *)scroller
{
    self = [super init];
    if (self) {
        self.targetView = targetView;
        self.scrollView = scroller;
        self.allowSuspendPosition = NO;
        self.transitionTopPosition = 0;
        self.transitionBottomPosition = [[UIScreen mainScreen] bounds].size.height;
        self.beginTransitionPosition = 220;
        [self addPanGesture];
    }
    return self;
}

- (void)addPanGesture
{
    UIPanGestureRecognizer * containerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    containerPan.delegate = self;
    [self.targetView addGestureRecognizer:containerPan];
}

#pragma mark - PanGesture Method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

/// Gesture Action Method
- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _recordTargetPosition = self.targetView.transform.ty;
        if ([self.delegate respondsToSelector:@selector(transitionChangedStateBegin:offsetY:)]) {
            [self.delegate transitionChangedStateBegin:ScrollerTransitionStateBottom offsetY:self.targetView.transform.ty];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGAffineTransform _transform = self.targetView.transform;
        _transform.ty = (_recordTargetPosition + [recognizer translationInView: self.targetView].y );
        
        if (_transform.ty < 0) {
            _transform.ty = 0;
        } else if (_transform.ty >= self.transitionBottomPosition) {
            _transform.ty = self.transitionBottomPosition;
        } else if( _transform.ty < self.transitionTopPosition) {
            _transform.ty = (self.transitionTopPosition / 2) + (_transform.ty / 2);
            CGFloat containerPositionBottom = (self.transitionState == ScrollerTransitionStateBottom) ?(self.transitionTopPosition) :0;
            
            if( (self.scrollView.contentOffset.y + self.scrollView.frame.size.height + containerPositionBottom) < (int)self.scrollView.contentSize.height) {
                [self calculationScrollViewHeight:(_transform.ty)];
            }
            self.targetView.transform = _transform;
        } else {
            self.targetView.transform = _transform;
        }
        CGPoint translationPoint = [recognizer translationInView:self.targetView];
        ///是否向上滚动
        BOOL isUpScroller = (translationPoint.y <= 0);
        if ([self.delegate respondsToSelector:@selector(transitionChangedState:offsetY:)]) {
            [self.delegate transitionChangedState:isUpScroller?ScrollerTransitionStateTop:ScrollerTransitionStateBottom offsetY:self.targetView.transform.ty];
        }
        if (self.targetView.transform.ty <= self.beginTransitionPosition && !self.hasFeedback) {
            self.hasFeedback = YES;
            [self feedback];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat velocityInViewY = [recognizer velocityInView:self.targetView].y;
        [self transitionMoveForVelocityInView:velocityInViewY];
        self.hasFeedback = NO;
       
    }
}


#pragma mark - Scroller Gesture Method

- (void)__scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat velocityInViewY    = [scrollView.panGestureRecognizer velocityInView:   self.targetView].y;
    CGFloat translationInViewY = [scrollView.panGestureRecognizer translationInView:self.targetView].y;
    
    if(scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [self.targetView endEditing:YES];
    }
    
    if((scrollView.panGestureRecognizer.state) && (scrollView.contentOffset.y <= 0)) {
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0 );
    } else {
        scrollView.showsVerticalScrollIndicator = YES;
    }
    
    BOOL bordersRunContainer = ( (scrollView.contentOffset.y == 0) && (0 < velocityInViewY));
    BOOL onceScrollingBeginDragging = NO;
    CGAffineTransform _transform = self.targetView.transform;
    CGFloat top = self.transitionTopPosition;

    if(scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded)
        onceScrollingBeginDragging = NO;
    
    if(bordersRunContainer) {
        _onceEnded = NO;
        onceScrollingBeginDragging = NO;
        
        _transform.ty = ((top - _startScrollPosition) + translationInViewY );
        if(_transform.ty < top) _transform.ty = top;
        
        if(_scrollBegin){
            GSCROLLER_ANIMATION_SPRING(.325, ^(void) {
                self.targetView.transform = _transform;
            });
            _scrollBegin = NO;
        } else {
            self.targetView.transform = _transform;
        }
    } else {
        
        if((top == _transform.ty) && !onceScrollingBeginDragging) {
            onceScrollingBeginDragging = YES;
            CGFloat headerHeight = 0;
            CGFloat top = (self.transitionTopPosition == 0) ? 0 : self.transitionTopPosition;

            CGFloat height = ([[UIScreen mainScreen] bounds].size.height - (top + headerHeight));
            
            if(scrollView.frame.size.height != height) {
//                GSCROLLER_ANIMATION_SPRING( .45, ^(void) {
//                    scrollView.frame = CGRectMake(
//                                                  scrollView.frame.origin.x, headerHeight ,
//                                                  scrollView.frame.size.width, height
//                                                  );
//                });
            }
        }
        if(top < _transform.ty) {
            if (velocityInViewY < 0. ) {
                if(self.transitionState == ScrollerTransitionStateTop) {
                    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0 );
                }
                _transform = self.targetView.transform;
                _transform.ty = ((top - _startScrollPosition) + translationInViewY );
                if(_transform.ty < top) _transform.ty = top;
                self.targetView.transform = _transform;
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(transitionChangedState:offsetY:)]) {
        [self.delegate transitionChangedState:ScrollerTransitionStateTop offsetY:self.targetView.transform.ty];
    }
    if (self.targetView.transform.ty >= self.beginTransitionPosition && !self.hasFeedback) {
        self.hasFeedback = YES;
        [self feedback];
    }
}

- (void)__scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _startScrollPosition = scrollView.contentOffset.y;
    if(self.bottomDeceleratingDisable) return;
    _scrollBegin = YES;
    if(_startScrollPosition < 0) _startScrollPosition = 0;
    if ([self.delegate respondsToSelector:@selector(transitionChangedStateBegin:offsetY:)]) {
        [self.delegate transitionChangedStateBegin:ScrollerTransitionStateTop offsetY:self.targetView.transform.ty];
    }
}

- (void)__scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.hasFeedback = NO;
    if(self.bottomDeceleratingDisable) return;
    ///todo by giki
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    CGFloat velocityInViewY = [scrollView.panGestureRecognizer velocityInView:window].y;
    if(!self.targetView) return;
    
    if(!_onceEnded){
        _onceEnded = YES;
        [self transitionMoveForVelocityInView:velocityInViewY];
    }
}

#pragma mark - Private Transition Method

- (void)transitionMoveForVelocityInView:(CGFloat)velocityInViewY
{
    ScrollerTransitionState transitionState;
    if( self.allowSuspendPosition) {
        if( self.targetView.transform.ty < self.transitionSuspendPosition ) {
            if(velocityInViewY < 0) {
                transitionState = ScrollerTransitionStateTop;
            } else {
//                transitionState = (2500 < velocityInViewY) ? ContainerMoveTypeBottom :ContainerMoveTypeMiddle;
                transitionState = ScrollerTransitionStateSuspend;
            }
        } else {
            if(velocityInViewY < 0) {
                transitionState = (velocityInViewY < (-2000)) ? ScrollerTransitionStateTop : ScrollerTransitionStateSuspend;
            } else {
                transitionState = ScrollerTransitionStateBottom;
            }
        }
    } else {
        CGFloat ty = self.targetView.transform.ty;
        if(self.targetView.transform.ty < self.transitionTopPosition) {
            transitionState = (750 < velocityInViewY) ? ScrollerTransitionStateBottom :ScrollerTransitionStateTop;
        } else {
            if (self.beginTransitionPosition <= 0) {
                  transitionState = (velocityInViewY < 0) ? ScrollerTransitionStateTop :ScrollerTransitionStateBottom;
            } else {
                if (ty < self.beginTransitionPosition) {
                    transitionState = ScrollerTransitionStateTop;
                } else {
                    transitionState = ScrollerTransitionStateBottom;
                }
            }
        }
    }
    [self transitionMove:transitionState animated:YES completion:nil];
}

- (void)transitionMove:(ScrollerTransitionState)state
{
    [self transitionMove:state animated:YES completion:nil];
}

- (void)transitionMove:(ScrollerTransitionState)state animated:(BOOL)animated completion:(void (^)(void))completion
{
    self.transitionState = state;
    CGFloat position = 0;
    switch (state) {
        case ScrollerTransitionStateTop:     position = self.transitionTopPosition; break;
        case ScrollerTransitionStateSuspend: position = self.transitionSuspendPosition; break;
        case ScrollerTransitionStateBottom:    position = self.transitionBottomPosition; break;
    }
    [self transitionMovePosition:position moveState:state animated:animated completion:completion];
}

- (void)transitionMovePosition:(CGFloat)position
                     moveState:(ScrollerTransitionState)state
                      animated:(BOOL)animated
                    completion:(void (^)(void))completion
{
    self.scrollView.scrollEnabled = (state == ScrollerTransitionStateTop);
    CGFloat containerPositionBottom = 0;
    CGAffineTransform _transform = CGAffineTransformMakeTranslation( 0, position);
    if(animated) {
        GSCROLLER_ANIMATION_SPRINGCOMP(.45, ^(void) {
            self.targetView.transform = _transform;
            if ([self.delegate respondsToSelector:@selector(transitionChangedState:offsetY:)]) {
                [self.delegate transitionChangedState:state offsetY:self.targetView.transform.ty];
            }
        }, ^(BOOL fin) {
            
            if(self.scrollView) {
                if( (self.scrollView.contentOffset.y + self.scrollView.frame.size.height + containerPositionBottom) < self.scrollView.contentSize.height) {
                    [self calculationScrollViewHeight:containerPositionBottom];
                }
            }
            if(completion) completion();
            if ([self.delegate respondsToSelector:@selector(transitionChangedStateFinish:offsetY:animated:)]) {
                [self.delegate transitionChangedStateFinish:state offsetY:self.targetView.transform.ty animated:NO];
            }
        });
    } else {
        self.targetView.transform = _transform;
        if(completion) completion();
        if ([self.delegate respondsToSelector:@selector(transitionChangedStateFinish:offsetY:animated:)]) {
            [self.delegate transitionChangedStateFinish:state offsetY:self.targetView.transform.ty animated:NO];
        }
    }
}

/// Calculation ScrollView
- (void)calculationScrollViewHeight:(CGFloat)containerPositionBottom
{
    return;
    if(self.scrollView) {
        CGFloat headerHeight = 0;
        CGFloat top = self.transitionTopPosition;

        CGFloat scrollIndicatorInsetsBottom = 0;
        
        CGFloat width = (self.portrait) ?([[UIScreen mainScreen] bounds].size.width) :([[UIScreen mainScreen] bounds].size.height);
        CGFloat height = ([[UIScreen mainScreen] bounds].size.height + containerPositionBottom - (top + headerHeight));
        
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, headerHeight, width, height);
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollIndicatorInsetsBottom, 0, 0 , 0);
    }
}

- (void)feedback
{
    if (!self.feedBackEnabled) {
        return;
    }
    if (@available(iOS 10.0,*)) {
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
        [generator prepare];
        [generator impactOccurred];
    }
}

@end
