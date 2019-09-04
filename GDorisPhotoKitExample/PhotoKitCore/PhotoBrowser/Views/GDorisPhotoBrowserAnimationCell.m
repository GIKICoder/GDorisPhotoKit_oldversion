//
//  GDorisPhotoBrowserAnimationCell.m
//  GDoris
//
//  Created by GIKI on 2019/4/6.
//  Copyright © 2019年 GIKI. All rights reserved.
//

#import "GDorisPhotoBrowserAnimationCell.h"
#import "YYImage.h"

@interface GDorisPhotoBrowserAnimationCell ()
@property (nonatomic, strong) YYAnimatedImageView * animateImageView;
@end

@implementation GDorisPhotoBrowserAnimationCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.scrollView addSubview:({
            _animateImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
            _animateImageView.runloopMode = NSDefaultRunLoopMode;
            _animateImageView;
        })];
        [self fulFillImageView:self.animateImageView];
    }
    return self;
}

#pragma mark - override Method

- (__kindof UIView *)containerView
{
    return self.animateImageView;
}

- (void)configData:(id)data forItemAtIndexPath:(NSIndexPath*)indexPath
{
    [super configData:data forItemAtIndexPath:indexPath];
}

- (void)configDidEndDisplayingCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super configDidEndDisplayingCellData:data forItemAtIndexPath:indexPath];
    [self.animateImageView stopAnimating];
}

- (void)configWillDisplayCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super configWillDisplayCellData:data forItemAtIndexPath:indexPath];
    [self.animateImageView startAnimating];
}

@end
