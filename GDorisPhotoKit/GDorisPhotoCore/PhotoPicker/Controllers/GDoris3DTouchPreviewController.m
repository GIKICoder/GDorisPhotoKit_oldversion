//
//  GDoris3DTouchPreviewController.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDoris3DTouchPreviewController.h"

API_AVAILABLE(ios(9.1))
@interface GDoris3DTouchPreviewController ()
@property (nonatomic, strong) GDorisAsset * assetModel;
@property (nonatomic, strong) GDorisPhotoPickerConfiguration * configuration;
@property (nonatomic, strong) UIImageView *imagePreviewView;
#ifndef GDorisWithoutYYImageInclude
@property (nonatomic, strong) YYAnimatedImageView * animatedImageView;
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
@property (nonatomic, strong) FLAnimatedImageView *fl_animateImageView;
#endif
#endif
@property (nonatomic, strong) PHLivePhotoView * livePhotoView;
@end

@implementation GDoris3DTouchPreviewController

- (instancetype)initWithDorisAsset:(GDorisAsset *)assetModel configuration:(GDorisPhotoPickerConfiguration *)configuration
{
    self = [super init];
    if (self) {
        self.assetModel = assetModel;
        self.configuration = configuration;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

#pragma mark - loadUI

- (void)loadUI
{
    __weak typeof(self) weakSelf = self;
    CGSize size = [self fitImageSize:self.assetModel.imageSize size:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.preferredContentSize = size;
    CGRect fitRect = (CGRect){{0,0},size};
    if (self.assetModel.subType == GDorisImageSubTypeLivePhoto && self.configuration.livePhotoEnabled) {
        [self.view addSubview:self.livePhotoView];
        
        self.livePhotoView.frame = fitRect;
        if (@available(iOS 9.1, *)) {
            [self.assetModel.asset asyncLivePhotoWithSize:size completion:^(PHLivePhoto * _Nonnull result) {
                if (result) {
                    weakSelf.livePhotoView.livePhoto = result;
                    [weakSelf.livePhotoView startPlaybackWithStyle:(PHLivePhotoViewPlaybackStyleFull)];
                }
            }];
        } else {
            // Fallback on earlier versions
        }
    } else if (self.assetModel.meidaType == GDorisMediaTypeVideo) {
        
    } else if (self.assetModel.meidaType == GDorisMediaTypeAudio) {
        
    }
#ifndef GDorisWithoutYYImageInclude
    else if (self.assetModel.subType == GDorisImageSubTypeGIF && self.configuration.gifPhotoEnabled) {
        [self.view addSubview:self.animatedImageView];
        self.animatedImageView.frame = fitRect;
        [self.assetModel.asset asyncImageData:^(NSData * _Nonnull result) {
            UIImage * gifData = [YYImage imageWithData:result];
            self.animatedImageView.image = gifData;
            [self.animatedImageView startAnimating];
        }];
    }
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
    else if (self.assetModel.subType == GDorisImageSubTypeGIF && self.configuration.gifPhotoEnabled) {
        [self.view addSubview:self.fl_animateImageView];
        self.fl_animateImageView.frame = fitRect;
        [self.assetModel.asset asyncImageData:^(NSData * _Nonnull result) {
            if (result) {
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:result];
                self.fl_animateImageView.hidden = NO;
                self.fl_animateImageView.animatedImage = image;
            }
        }];
    }
#endif
#endif
    else {
        [self.view addSubview:self.imagePreviewView];
        self.imagePreviewView.frame = fitRect;
        self.imagePreviewView.image = [self.assetModel.asset thumbnailImageWithSize:fitRect.size];
        [self.assetModel.asset asyncPreviewImageWithCompletion:^(UIImage *  result, NSDictionary<NSString *,id> *  info) {
            if (result) {
                weakSelf.imagePreviewView.image = result;
            }
        } progressHandler:nil];
    }
}

- (UIImageView *)imagePreviewView
{
    if (!_imagePreviewView) {
        _imagePreviewView = [UIImageView new];
    }
    return _imagePreviewView;
}

#ifndef GDorisWithoutYYImageInclude
- (YYAnimatedImageView *)animatedImageView
{
    if (!_animatedImageView) {
        _animatedImageView = [[YYAnimatedImageView alloc] init];
    }
    return _animatedImageView;
}
#else
#ifndef GDorisWithoutFLAnimatedImageInclude
- (FLAnimatedImageView *)fl_animateImageView
{
    if (!_fl_animateImageView) {
        _fl_animateImageView = [[FLAnimatedImageView alloc] init];
    }
    return _fl_animateImageView;
}
#endif
#endif
- (PHLivePhotoView *)livePhotoView API_AVAILABLE(ios(9.1))
{
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
    }
    return _livePhotoView;
}

- (CGSize)fitPreviewSize:(CGSize)imageSize
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat imgWidth = imageSize.width;
    CGFloat imgHeight = imageSize.height;
    CGFloat w;
    CGFloat h;
    if (imgWidth > width) {
        h = width / imgWidth * imgHeight;
        w = width;
    }else {
        w = width;
        h = width / imgWidth * imgHeight;
    }
    if (h > height + 20) {
        h = height;
    }
    
    return CGSizeMake(w, h);
}

- (CGSize)fitImageSize:(CGSize)imageSize size:(CGSize)containerSize
{
    CGFloat targetAspect = containerSize.width / containerSize.height;
    CGFloat sourceAspect = imageSize.width / imageSize.height;
    CGRect rect = CGRectZero;
    
    if (targetAspect > sourceAspect) {
        rect.size.height = containerSize.height;
        rect.size.width = ceilf(rect.size.height * sourceAspect);
        rect.origin.x = ceilf((containerSize.width - rect.size.width) * 0.5);
    }
    else {
        rect.size.width = containerSize.width;
        rect.size.height = ceilf(rect.size.width / sourceAspect);
        rect.origin.y = ceilf((containerSize.height - rect.size.height) * 0.5);
    }
    
    return rect.size;
}


@end
