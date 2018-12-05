//
//  GNavItemFactory.m
//  GNavigationBar
//
//  Created by GIKI on 2017/4/6.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import "GNavItemFactory.h"
#import "GNavigationMacro.h"
#import "GNavigationButton.h"
#import "GNavigationItem.h"

@implementation GNavItemFactory

+ (GNavigationItem *)createImageButton:(UIImage*)image highlightImage:(UIImage*)highlightImage target:(id)target selctor:(SEL)selctor
{
    GNavigationButton *btn = [GNavigationButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    if (highlightImage) {
        [btn setImage:highlightImage forState:UIControlStateHighlighted];
    } else {
        [btn setImage:image forState:UIControlStateHighlighted];
    }
  
    [btn addTarget:target action:selctor forControlEvents:UIControlEventTouchUpInside];
    if (G_NAVI_DEBUG) {
        btn.backgroundColor  = GNAVRandomColor;
    }
    [btn enlargeHitWithEdges:UIEdgeInsetsMake(10, 10, 10, 10)];
    GNavigationItem *item = [[GNavigationItem alloc] initWithRootView:btn];
    return item;
}

+ (GNavigationItem *)createTitleButton:(NSString*)title target:(id)target selctor:(SEL)selctor
{
    return [self createTitleButton:title titleColor:G_NAVI_TITLEBUTTON_COLOR highlightColor:G_NAVI_TITLEBUTTON_COLOR_HIGH target:target selctor:selctor];
}

+ (GNavigationItem *)createTitleButton:(NSString*)title titleColor:(UIColor*)color highlightColor:(UIColor*)highlightColor target:(id)target selctor:(SEL)selctor
{
    
    return [self createTitleButton:title titleColor:color highlightColor:highlightColor font:G_NAVI_TITLEBUTTON_FONT target:target selctor:selctor];
}

+ (GNavigationItem *)createTitleButton:(NSString*)title titleColor:(UIColor*)color highlightColor:(UIColor*)highlightColor font:(UIFont*)font target:(id)target selctor:(SEL)selctor
{
    GNavigationButton *btn = [GNavigationButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn setTitleColor:highlightColor forState:UIControlStateHighlighted];
    btn.titleLabel.font = font;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:selctor forControlEvents:UIControlEventTouchUpInside];
    if (G_NAVI_DEBUG) {
        btn.backgroundColor  = GNAVRandomColor;
    }
    CGSize size = CGSizeMake(MAXFLOAT, 20.0f);
    CGSize buttonSize = [title boundingRectWithSize:size                          options:NSStringDrawingTruncatesLastVisibleLine  | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading                       attributes:@{ NSFontAttributeName:font}                                               context:nil].size;
    btn.frame = CGRectMake(0, 0, buttonSize.width, G_NAVI_ITEM_SIZE.height);
    [btn enlargeHitWithEdges:UIEdgeInsetsMake(10, 10, 10, 10)];
    GNavigationItem *item = [[GNavigationItem alloc] initWithRootView:btn];
    return item;
}

+ (GNavigationItem *)createCustomView:(__kindof UIView*)view
{
    GNavigationItem *item = [[GNavigationItem alloc] initWithRootView:view];
    item.subViewFrameAdjustChange = NO;
    return item;
}

- (UIImage*)drawCloseImageSize:(CGSize)size lineWidth:(CGFloat)lineWidth tintColor:(UIColor *)tintColor
{
    UIImage *resultImage = nil;
    tintColor = tintColor ? tintColor : [UIColor whiteColor];
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(size.width, size.height)];
    [path closePath];
    [path moveToPoint:CGPointMake(size.width, 0)];
    [path addLineToPoint:CGPointMake(0, size.height)];
    [path closePath];
    path.lineWidth = lineWidth;
    path.lineCapStyle = kCGLineCapRound;
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    [path stroke];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
