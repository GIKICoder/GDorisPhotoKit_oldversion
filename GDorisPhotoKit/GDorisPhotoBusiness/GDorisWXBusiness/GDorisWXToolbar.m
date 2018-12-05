//
//  GDorisWXToolbar.m
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXToolbar.h"
#import "UIView+GDoris.h"
#import "GDorisPhotoHelper.h"
@interface GDorisWXToolbar()
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * centerButton;
@property (nonatomic, strong) UIButton * rightButton;
@end

@implementation GDorisWXToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectV = [[UIVisualEffectView alloc] initWithEffect:effect];
        self.effectView = effectV;
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = @[(__bridge id) [UIColor colorWithRed:(4)/255.0 green:(0)/255.0 blue:(18)/255.0 alpha:0.76].CGColor,(__bridge id)[UIColor colorWithRed:(4)/255.0 green:(0)/255.0 blue:(18)/255.0 alpha:0.58].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        [effectV.contentView.layer addSublayer:gradientLayer];
        [self addSubview:effectV];
        effectV.frame = self.bounds;
        [self addSubview:({
            _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_leftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _leftButton.enabled = NO;
            _leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [_leftButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [_leftButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
            [_leftButton setTitleColor:GDorisColorCreate(@"55595D") forState:UIControlStateDisabled];
            _leftButton.tag = DorisWXToolbarItemLeft;
            _leftButton;
        })];
        [self addSubview:({
            _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_centerButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _centerButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [_centerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, -6)];
            [_centerButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [_centerButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
            _centerButton.tag = DorisWXToolbarItemCenter;
            _centerButton;
        })];
        [self addSubview:({
            _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [_rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [_rightButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
            [_rightButton setTitleColor:GDorisColorCreate(@"4C744A") forState:UIControlStateDisabled];
            _rightButton.layer.cornerRadius = 4;
            _rightButton.layer.masksToBounds = YES;
            _rightButton.enabled = NO;
            _rightButton.tag = DorisWXToolbarItemRight;
            UIImage *imageN = [GDorisPhotoHelper createImageWithColor:GDorisColorCreate(@"20A115") size:CGSizeMake(62, 30)];
            UIImage *imageD = [GDorisPhotoHelper createImageWithColor:GDorisColorCreate(@"154212") size:CGSizeMake(62, 30)];
            [_rightButton setBackgroundImage:imageN forState:UIControlStateNormal];
            [_rightButton setBackgroundImage:imageD forState:UIControlStateDisabled];
            _rightButton;
        })];
       
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    {
        CGFloat left = 12;
        CGFloat top = (self.g_height - 24)*0.5;
        CGFloat width = 94*0.5;
        CGFloat height = 24;
        self.leftButton.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 124*0.5;
        CGFloat height = 24;
        CGFloat left = (self.g_width-width)*0.5;
        CGFloat top = (self.g_height-height)*0.5;
        self.centerButton.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 124*0.5;
        CGFloat height = 30;
        CGFloat left = (self.g_width-width-12);
        CGFloat top = (self.g_height-height)*0.5;
        self.rightButton.frame = CGRectMake(left, top, width, height);
    }
}

- (void)buttonClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (self.wxToolbarClickBlock) {
        self.wxToolbarClickBlock(btn.tag);
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.leftButton.enabled = enabled;
    self.rightButton.enabled = enabled;
}

@end
