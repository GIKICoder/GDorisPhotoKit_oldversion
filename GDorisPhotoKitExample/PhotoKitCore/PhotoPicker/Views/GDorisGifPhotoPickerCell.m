//
//  GDorisGifPhotoPickerCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisGifPhotoPickerCell.h"
#import "XCAssetsManager.h"
#import "YYImage.h"
@interface GDorisGifPhotoPickerCell ()
@property (nonatomic, strong) YYAnimatedImageView * yy_animateImageView;
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


- (void)configData:(GDorisAssetItem *)assetItem withIndex:(NSInteger)index
{
    [super configData:assetItem withIndex:index];
    XCAsset * xcasset = assetItem.asset;
    if (self.assetItem.isSelected && xcasset.assetSubType == XCAssetSubTypeGIF) {
        [xcasset requestImageData:^(NSData * _Nonnull imageData, NSDictionary<NSString *,id> * _Nonnull info, BOOL isGIF, BOOL isHEIC) {
            UIImage * gifData = [YYImage imageWithData:imageData];
            self.yy_animateImageView.hidden = NO;
            self.yy_animateImageView.image = gifData;
        }];
    } else {
        if (_yy_animateImageView) {
            self.yy_animateImageView.hidden = YES;
        }
    }
}

@end
