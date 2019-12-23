//
//  GDorisEditerCropMaskView.m
//  GDoris
//
//  Created by GIKI on 2018/10/11.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisEditerCropMaskView.h"

@interface GDorisEditerCropMaskView ()
@property (nonatomic, strong) CAShapeLayer * fillLayer;
@property (nonatomic, assign) CGRect  holeRect;
@end

@implementation GDorisEditerCropMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        [self.layer addSublayer:fillLayer];
        self.fillLayer = fillLayer;
    }
    return self;
}

- (void)setMaskRect:(CGRect)maskRect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *clearPath = [UIBezierPath bezierPathWithRect:maskRect];
    [path appendPath:clearPath];
    [path setUsesEvenOddFillRule:YES];
    self.fillLayer.path = path.CGPath;
}

- (void)layoutSubviews
{
    self.fillLayer.frame = self.bounds;
}


@end
