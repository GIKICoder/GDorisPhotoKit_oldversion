//
//  GDoirsPhotoPickerToolbar.m
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/5.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDoirsPhotoPickerToolbar.h"
#import "UIView+GDoris.h"
#import "GDorisPhotoHelper.h"
@interface GDoirsPhotoPickerToolbar()
@property (nonatomic, strong) UIView * container;
@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * centerButton;
@property (nonatomic, strong) UIButton * rightButton;
@end

@implementation GDoirsPhotoPickerToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:({
            _container = [UIView new];
            _container;
        })];
        [self.container addSubview:({
            _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_leftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _leftButton.enabled = NO;
            _leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [_leftButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [_leftButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
            [_leftButton setTitleColor:GDorisColorCreate(@"55595D") forState:UIControlStateDisabled];
            _leftButton.tag = DorisPhotoPickerToolbarLeft;
            _leftButton;
        })];
        [self.container addSubview:({
            _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_centerButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _centerButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [_centerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, -6)];
            [_centerButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [_centerButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
            _centerButton.tag = DorisPhotoPickerToolbarCenter;
            _centerButton;
        })];
        [self.container addSubview:({
            _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [_rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [_rightButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
            [_rightButton setTitleColor:GDorisColorCreate(@"4C744A") forState:UIControlStateDisabled];
            _rightButton.layer.cornerRadius = 4;
            _rightButton.layer.masksToBounds = YES;
            _rightButton.enabled = NO;
            _rightButton.tag = DorisPhotoPickerToolbarRight;
            UIImage *imageN = [GDorisPhotoHelper createImageWithColor:GDorisColorCreate(@"28CD84") size:CGSizeMake(62, 30)];
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
        CGFloat left = 0;
        CGFloat top = 0;
        CGFloat width = self.g_width;
        CGFloat height = self.g_height-GDoris_TabBarMargin;
        self.container.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat left = 12;
        CGFloat top = (self.container.g_height - 24)*0.5;
        CGFloat width = 94*0.5;
        CGFloat height = 24;
        self.leftButton.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 124*0.5;
        CGFloat height = 24;
        CGFloat left = (self.g_width-width)*0.5;
        CGFloat top = (self.container.g_height-height)*0.5;
        self.centerButton.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 124*0.5;
        CGFloat height = 30;
        CGFloat left = (self.g_width-width-12);
        CGFloat top = (self.container.g_height-height)*0.5;
        self.rightButton.frame = CGRectMake(left, top, width, height);
    }
}

- (void)buttonClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (self.photoToolbarClickBlock) {
        self.photoToolbarClickBlock(btn.tag);
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.leftButton.enabled = enabled;
    self.rightButton.enabled = enabled;
}

@end

