//
//  GNavigationButton
//  GNavigationBar
//
//  Created by GIKI on 2017/4/6.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import "GNavigationButton.h"

@interface GNavigationButton ()
@property (nonatomic, assign) BOOL  adjustHitEdgeIntsets;
@property (nonatomic, assign) UIEdgeInsets  hitEdgeIntsets;
@end

@implementation GNavigationButton

- (void)enlargeHitWithEdges:(UIEdgeInsets)edgeIntsets
{
    self.hitEdgeIntsets = edgeIntsets;
    self.adjustHitEdgeIntsets = YES;
}

- (CGRect)newHitRect
{
    if (self.adjustHitEdgeIntsets) {
        UIEdgeInsets edgeIntset = self.hitEdgeIntsets;
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
