//
//  GDorisPhotoBrowseGifCell.m
//  GDoris
//
//  Created by GIKI on 2018/9/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoBrowseGifCell.h"

@interface GDorisPhotoBrowseGifCell ()
#ifndef GDorisWithoutYYImageInclude
@property (nonatomic, strong) YYAnimatedImageView * animateImageView;
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
@property (nonatomic, strong) FLAnimatedImageView *fl_animateImageView;
#endif
#endif
@end

@implementation GDorisPhotoBrowseGifCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#ifndef GDorisWithoutYYImageInclude
        [self.scrollView addSubview:({
            _animateImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
            _animateImageView;
        })];
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
        [self.scrollView addSubview:({
            _fl_animateImageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectZero];
            _fl_animateImageView;
        })];
#endif
#endif
    }
    return self;
}

#pragma mark - override Method

- (__kindof UIView *)containerView
{
#ifndef GDorisWithoutYYImageInclude
    return self.animateImageView;
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
    return self.fl_animateImageView;
#else
    return self.imageView;
#endif
#endif
}

- (void)configData:(GDorisAsset *)data forItemAtIndexPath:(NSIndexPath*)indexPath
{
    self.imageView.hidden = NO;
    [super configData:data forItemAtIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    PHAsset * asset = data.asset;
#ifndef GDorisWithoutYYImageInclude
    [asset asyncImageData:^(NSData * _Nonnull result) {
        weakSelf.imageView.image = nil;
        weakSelf.imageView.hidden = YES;
        UIImage * gifData = [YYImage imageWithData:result];
        weakSelf.animateImageView.image = gifData;
        [weakSelf fitImageSize:gifData.size containerSize:self.scrollView.bounds.size Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
            weakSelf.scrollView.contentSize = scrollContentSize;
            weakSelf.animateImageView.frame = containerFrame;
        }];
    }];
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
    [asset asyncImageData:^(NSData * _Nonnull result) {
        weakSelf.imageView.image = nil;
        weakSelf.imageView.hidden = YES;
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:result];
        weakSelf.fl_animateImageView.hidden = NO;
        weakSelf.fl_animateImageView.animatedImage = image;
        [weakSelf fitImageSize:image.size containerSize:self.scrollView.bounds.size Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
            weakSelf.scrollView.contentSize = scrollContentSize;
            weakSelf.fl_animateImageView.frame = containerFrame;
        }];
    }];
#endif
#endif
}

- (void)configDidEndDisplayingCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super configDidEndDisplayingCellData:data forItemAtIndexPath:indexPath];
#ifndef GDorisWithoutYYImageInclude
    [self.animateImageView stopAnimating];
#endif
}

- (void)configWillDisplayCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super configWillDisplayCellData:data forItemAtIndexPath:indexPath];
#ifndef GDorisWithoutYYImageInclude
     [self.animateImageView startAnimating];
#endif
   
}

@end
