//
//  UIButton+GDoris.m
//  GDoris
//
//  Created by GIKI on 2018/9/17.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "UIButton+GDoris.h"
#import <objc/runtime.h>

static char KHitEdgeIntsets;

@implementation UIButton (GDoris)

- (void)enlargeHitWithEdges:(UIEdgeInsets)edgeIntsets
{
    objc_setAssociatedObject(self, &KHitEdgeIntsets, [NSValue valueWithUIEdgeInsets:edgeIntsets], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)newHitRect
{
    NSValue* edgeValue = objc_getAssociatedObject(self, &KHitEdgeIntsets);
    
    if (edgeValue) {
        UIEdgeInsets edgeIntset = [edgeValue UIEdgeInsetsValue];
        return CGRectMake(self.bounds.origin.x - edgeIntset.left,
                          self.bounds.origin.y - edgeIntset.top,
                          self.bounds.size.width + edgeIntset.left + edgeIntset.right,
                          self.bounds.size.height + edgeIntset.top + edgeIntset.bottom);
    } else {
        return self.bounds;
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self newHitRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? YES : NO;
}
@end
