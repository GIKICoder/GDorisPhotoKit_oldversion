//
//  GDorisWXEditToolbar.m
//  GDoris
//
//  Created by GIKI on 2018/10/3.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXEditToolbar.h"
#import "UIView+GDoris.h"
#import "GDorisPhotoHelper.h"
@implementation GDorisWXEditToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        NSArray * array = @[@"涂鸦",@"表情",@"文字",@"马赛克",@"裁剪"];
        CGFloat widthItem = [UIScreen mainScreen].bounds.size.width / array.count;
        [array enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [self createButton:obj];
            button.tag = 1000+idx;
            [self addSubview:button];
            {
                CGFloat left = idx*widthItem;
                CGFloat top = 0;
                CGFloat width = widthItem;
                CGFloat height = 37;
                button.frame = CGRectMake(left, top, width, height);
            }
        }];
    }
    return self;
}


- (UIButton *)createButton:(NSString *)title
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [button setTitleColor:GDorisColorCreate(@"20A115") forState:(UIControlStateHighlighted)];
    [button setTitleColor:GDorisColorCreate(@"20A115") forState:(UIControlStateSelected)];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)buttonClick:(UIButton*)sender
{
    if (self.editToolbarClickBlock) {
        self.editToolbarClickBlock(sender.tag,sender);
    }
}


- (void)setToolbarSelected:(BOOL)selected itemType:(DorisEditToolbarItemType)itemType
{
    UIButton * draw = [self viewWithTag:DorisEditToolbarItemDraw];
    UIButton * mosaic = [self viewWithTag:DorisEditToolbarItemMosaic];
    draw.selected = NO;
    mosaic.selected = NO;
    UIButton * button = [self viewWithTag:itemType];
    button.selected = selected;
    
}
@end
