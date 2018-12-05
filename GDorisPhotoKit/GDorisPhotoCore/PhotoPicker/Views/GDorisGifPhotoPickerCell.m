//
//  GDorisGifPhotoPickerCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisGifPhotoPickerCell.h"
#import "GDorisPhotoKitManager.h"
@interface GDorisGifPhotoPickerCell ()
#ifndef GDorisWithoutYYImageInclude
@property (nonatomic, strong) YYAnimatedImageView * yy_animateImageView;
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
@property (nonatomic, strong) FLAnimatedImageView *fl_animateImageView;
#endif
#endif
@end

@implementation GDorisGifPhotoPickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)selectClick:(UIButton *)button
{
    [super selectClick:button];
}

#ifndef GDorisWithoutYYImageInclude

- (YYAnimatedImageView *)yy_animateImageView
{
    if (!_yy_animateImageView) {
        _yy_animateImageView = [[YYAnimatedImageView alloc] initWithFrame:self.contentView.bounds];
        _yy_animateImageView.hidden = YES;
        _yy_animateImageView.contentMode = UIViewContentModeScaleAspectFill;
        _yy_animateImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_yy_animateImageView];
        [self.contentView bringSubviewToFront:self.operationCotainer];
    }
    return _yy_animateImageView;
}

#else
#ifndef GDorisWithoutFLAnimatedImageInclude

- (FLAnimatedImageView *)fl_animateImageView
{
    if (!_fl_animateImageView) {
        _fl_animateImageView = [[FLAnimatedImageView alloc] init];
        _fl_animateImageView.hidden = YES;
        _fl_animateImageView.contentMode = UIViewContentModeScaleAspectFill;
        _fl_animateImageView.layer.masksToBounds = YES;
        _fl_animateImageView.frame = self.contentView.bounds;
        [self.contentView addSubview:_fl_animateImageView];
        [self.contentView bringSubviewToFront:self.operationCotainer];
    }
    return _fl_animateImageView;
}
#endif
#endif


- (void)configData:(GDorisAsset *)asset withIndex:(NSInteger)index
{
    [super configData:asset withIndex:index];
    
#ifndef GDorisWithoutYYImageInclude
    if (self.asset.isSelected && self.asset.subType == GDorisImageSubTypeGIF) {
        [self.asset.asset asyncImageData:^(NSData * _Nonnull result) {
            UIImage * gifData = [YYImage imageWithData:result];
            self.yy_animateImageView.hidden = NO;
            self.yy_animateImageView.image = gifData;
        }];
    } else {
        if (_yy_animateImageView) {
            self.yy_animateImageView.hidden = YES;
        }
    }
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
    if (self.asset.isSelected && self.asset.subType == GDorisImageSubTypeGIF) {
        [self.asset.asset asyncImageData:^(NSData * _Nonnull result) {
            if (result) {
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:result];
                self.fl_animateImageView.hidden = NO;
                self.fl_animateImageView.animatedImage = image;
            }
        }];
    } else {
        if (_fl_animateImageView.hidden) {
            self.fl_animateImageView.hidden = YES;
        }
    }
#endif
#endif
}

@end
