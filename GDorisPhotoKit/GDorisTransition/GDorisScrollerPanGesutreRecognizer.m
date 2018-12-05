//
//  GDorisScrollerPanGesutreRecognizer.m
//  GDoris
//
//  Created by GIKI on 2018/9/16.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisScrollerPanGesutreRecognizer.h"

@interface GDorisScrollerPanGesutreRecognizer ()
@property (nonatomic, strong) NSNumber *isFail;
@end

@implementation GDorisScrollerPanGesutreRecognizer

- (void)reset
{
    [super reset];
    self.isFail = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (!self.scrollview) {
        return;
    }
    
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint velocity = [self velocityInView:self.view];
    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    CGPoint prevPoint = [touches.anyObject previousLocationInView:self.view];
    
    if (self.isFail) {
        if (self.isFail.boolValue) {
            self.state = UIGestureRecognizerStateFailed;
        }
        return;
    }
    
    CGFloat topVerticalOffset = -self.scrollview.contentInset.top;

    CGFloat height = self.scrollview.frame.size.height;
    CGFloat contentYoffset = self.scrollview.contentOffset.y;
    CGFloat distanceFromBottom = self.scrollview.contentSize.height - contentYoffset;
    if ((fabs(velocity.x) < fabs(velocity.y)) && (nowPoint.y > prevPoint.y) && (self.scrollview.contentOffset.y <= topVerticalOffset)) {
        self.isFail = @NO;
    } else if (((self.scrollview.contentSize.height > self.scrollview.bounds.size.height) && (distanceFromBottom < height)) || ((self.scrollview.contentSize.height <= self.scrollview.bounds.size.height) && (distanceFromBottom <= height))) {
        self.isFail = @NO;
    } else if (self.scrollview.contentOffset.y >= topVerticalOffset) {
        self.state = UIGestureRecognizerStateFailed;
        self.isFail = @YES;
    } else {
        self.isFail = @NO;
    }
}


@end
