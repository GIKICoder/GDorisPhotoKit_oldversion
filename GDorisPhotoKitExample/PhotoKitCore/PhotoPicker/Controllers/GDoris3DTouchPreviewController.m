//
//  GDoris3DTouchPreviewController.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDoris3DTouchPreviewController.h"
#import "YYImage.h"
#import <PhotosUI/PhotosUI.h>
API_AVAILABLE(ios(9.1))
@interface GDoris3DTouchPreviewController ()
@property (nonatomic, strong) GDorisAssetItem * assetModel;
@property (nonatomic, strong) GDorisPhotoPickerConfiguration * configuration;
@property (nonatomic, strong) UIImageView *imagePreviewView;
@property (nonatomic, strong) YYAnimatedImageView * animatedImageView;
@property (nonatomic, strong) PHLivePhotoView * livePhotoView;
@end

@implementation GDoris3DTouchPreviewController

- (instancetype)initWithDorisAsset:(GDorisAssetItem *)assetModel configuration:(GDorisPhotoPickerConfiguration *)configuration
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
    CGSize assetSize = CGSizeMake(self.assetModel.asset.phAsset.pixelWidth, self.assetModel.asset.phAsset.pixelHeight);
    CGSize size = [self fitImageSize:assetSize size:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.preferredContentSize = size;
    CGRect fitRect = (CGRect){{0,0},size};
    if (self.assetModel.asset.assetSubType == XCAssetSubTypeLivePhoto && self.configuration.livePhotoEnabled) {
        [self.view addSubview:self.livePhotoView];
    
        if (@available(iOS 9.1, *)) {
            self.livePhotoView.frame = fitRect;
            [self.assetModel.asset requestLivePhotoWithCompletion:^(PHLivePhoto * _Nonnull livePhoto, NSDictionary<NSString *,id> * _Nonnull info) {
                if (livePhoto) {
                    weakSelf.livePhotoView.livePhoto = livePhoto;
                    [weakSelf.livePhotoView startPlaybackWithStyle:(PHLivePhotoViewPlaybackStyleFull)];
                }
            } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            }];
        } else {
            // Fallback on earlier versions
        }
    } else if (self.assetModel.asset.assetSubType == XCAssetSubTypeGIF && self.configuration.gifPhotoEnabled) {
        [self.view addSubview:self.animatedImageView];
        self.animatedImageView.frame = fitRect;
        [self.assetModel.asset requestImageData:^(NSData * _Nonnull imageData, NSDictionary<NSString *,id> * _Nonnull info, BOOL isGIF, BOOL isHEIC) {
            UIImage * gifData = [YYImage imageWithData:imageData];
            weakSelf.animatedImageView.image = gifData;
            [weakSelf.animatedImageView startAnimating];
        }];
    } else {
        [self.view addSubview:self.imagePreviewView];
        self.imagePreviewView.frame = fitRect;
        [self.assetModel.asset requestPreviewImageWithCompletion:^(UIImage * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
            if (result) {
                weakSelf.imagePreviewView.image = result;
            }
        } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
        }];
    }
}

- (UIImageView *)imagePreviewView
{
    if (!_imagePreviewView) {
        _imagePreviewView = [UIImageView new];
    }
    return _imagePreviewView;
}

- (YYAnimatedImageView *)animatedImageView
{
    if (!_animatedImageView) {
        _animatedImageView = [[YYAnimatedImageView alloc] init];
    }
    return _animatedImageView;
}

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
