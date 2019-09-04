//
//  GDorisPhotoBrowserAnimationCell.m
//  GDoris
//
//  Created by GIKI on 2019/4/6.
//  Copyright © 2019年 GIKI. All rights reserved.
//

#import "GDorisPhotoBrowserAnimationCell.h"
#import "YYImage.h"
#import "YYWebImage.h"
@interface GDorisPhotoBrowserAnimationCell ()
@property (nonatomic, strong) YYAnimatedImageView * animateImageView;
@property (nonatomic, strong) UIActivityIndicatorView * photoIndicatorView;
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

#pragma mark - getter Method

- (UIActivityIndicatorView *)photoIndicatorView
{
    if (!_photoIndicatorView) {
        _photoIndicatorView = [[UIActivityIndicatorView alloc] init];
        CGFloat width = 50;
        _photoIndicatorView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-width)*0.5, ([UIScreen mainScreen].bounds.size.height-width)*0.5, width,width);
        [self.scrollView addSubview:_photoIndicatorView];
    }
    return _photoIndicatorView;
}
#pragma mark - override Method

- (__kindof UIView *)containerView
{
    return self.animateImageView;
}

- (void)configData:(id)data forItemAtIndexPath:(NSIndexPath*)indexPath
{
    [super configData:data forItemAtIndexPath:indexPath];
    self.photoItem = data;
    [self resetScrollViewZoom];
    [self.photoIndicatorView startAnimating];
    self.contentImageView.image = nil;
    id<IGDorisPhotoItem> photo = self.photoItem;
    UIImage * placeHolder = [UIImage imageNamed:@"XC_photobrowser_placeholder"];
    if (Doris_Select(photo, @selector(placeholder)) && Doris_NOEmpty(photo.placeholder)) {
        placeHolder = [UIImage imageNamed:photo.placeholder];
    }
    if (Doris_Select(photo, @selector(thumbImage))) {
        UIImage * image = photo.thumbImage;
        if (image) {
            [self loadLocalImage:image];
        } else {
            if (placeHolder ) {
                [self loadPlaceHolderImage:placeHolder];
            }
        }
    } else {
        if (placeHolder ) {
            [self loadPlaceHolderImage:placeHolder];
        }
    }
    if (Doris_Select(photo,@selector(localImageName)) && Doris_NOEmpty(photo.localImageName)) {
        [self loadLocalImageName:photo.localImageName];
        return;
    }
    /// photo thumburl not return
    if (Doris_Select(photo,@selector(thumbUrl)) && Doris_NOEmpty(photo.thumbUrl)) {
        NSURL * url = [NSURL URLWithString:photo.thumbUrl];
        [self loadThumbImage:url];
    }
    if (Doris_Select(photo,@selector(photoUrl)) && Doris_NOEmpty(photo.photoUrl)) {
        NSURL * url = [NSURL URLWithString:photo.photoUrl];
        [self loadPreviewImage:url];
    }
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

#pragma mark - Private Method

- (void)loadLocalImage:(UIImage *)image
{
    if (self.contentImageView && image) {
        self.contentImageView.image = image;
        [self processSizeWithImage:image imageContainer:self.contentImageView];
    }
}

- (void)loadLocalImageName:(NSString *)imageName
{
    if (self.contentImageView && imageName) {
        YYImage * image = [YYImage imageNamed:imageName];
        [self processSizeWithImage:image imageContainer:self.contentImageView];
        self.contentImageView.image = image;
    }
    [self.photoIndicatorView stopAnimating];
}

- (void)loadThumbImage:(NSURL *)thumbURL
{
    if (thumbURL && self.contentImageView) {
        __weak __typeof(self) weakSelf = self;
        [self.contentImageView yy_setImageWithURL:thumbURL placeholder:nil options:(YYWebImageOptionIgnorePlaceHolder) completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            [weakSelf processSizeWithImage:image imageContainer:weakSelf.contentImageView];
        }];
    }
}

- (void)loadPlaceHolderImage:(UIImage *)placeHolder
{}

- (void)loadPreviewImage:(NSURL *)previewURL
{
    if (previewURL && self.contentImageView) {
        [self.scrollView bringSubviewToFront:self.photoIndicatorView];
        __weak __typeof(self) weakSelf = self;
        [self.contentImageView yy_setImageWithURL:previewURL placeholder:nil options:(YYWebImageOptionIgnorePlaceHolder) completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            [weakSelf.photoIndicatorView stopAnimating];
            if (image) {
                [weakSelf processSizeWithImage:image imageContainer:weakSelf.contentImageView];
                [weakSelf.contentImageView startAnimating];
            }
        }];
    }
}

@end
