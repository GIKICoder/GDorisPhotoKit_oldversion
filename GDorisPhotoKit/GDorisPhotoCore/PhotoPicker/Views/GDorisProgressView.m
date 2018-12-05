//
//  GDorisProgressView.m
//  GDoris
//
//  Created by GIKI on 2018/8/26.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisProgressView.h"

@interface GDorisProgressViewLayer : CALayer
@property(nonatomic, strong) UIColor *fillColor;
@property(nonatomic, assign) float progress;
@property(nonatomic, assign) CFTimeInterval progressDuration;
@end

@implementation GDorisProgressViewLayer
@dynamic fillColor;
@dynamic progress;

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    if ([event isEqualToString:@"progress"] && self.progressDuration>0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        animation.fromValue = [self.presentationLayer valueForKey:event];
        animation.duration = self.progressDuration;
        return animation;
    }
    return [super actionForKey:event];
}

- (void)drawInContext:(CGContextRef)context
{
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    // 绘制扇形进度区域
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(center.x, center.y);
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = M_PI * 2 * self.progress + startAngle;
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    [super drawInContext:context];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat scale = [UIScreen mainScreen].scale;
    self.cornerRadius =  ceil(((CGRectGetHeight(frame) / 2) * scale) / scale);
}

@end

@implementation GDorisProgressView

+ (Class)layerClass {
    return [GDorisProgressViewLayer class];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor lightGrayColor];
        self.progress = 0.0;
        self.progressDuration = 0.5;
        
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.borderWidth = 1.0;
        [self.layer setNeedsDisplay];
    }
    return self;
}

- (void)setProgress:(float)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    _progress = fmax(0.0, fmin(1.0, progress));
    GDorisProgressViewLayer *layer = (GDorisProgressViewLayer *)self.layer;
    if (animated) {
        layer.progressDuration = self.progressDuration;
    } else {
        layer.progressDuration = 0;
    }
    layer.progress = _progress;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    GDorisProgressViewLayer *layer = (GDorisProgressViewLayer *)self.layer;
    layer.fillColor = self.tintColor;
    layer.borderColor = self.tintColor.CGColor;
}
@end
